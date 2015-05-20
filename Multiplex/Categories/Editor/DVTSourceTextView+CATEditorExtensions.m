//
//  IDESourceCodeEditor+CATViewReplacement.m
//  Multiplex
//
//  Created by Kolin Krewinkel on 9/25/14.
//  Copyright (c) 2014 Kolin Krewinkel. All rights reserved.
//

@import QuartzCore;

#import "DVTSourceTextView+CATEditorExtensions.h"

#import "MPXSelection.h"
#import "PLYSwizzling.h"

static IMP CAT_DVTSourceTextView_Original_Init = nil;
static IMP CAT_DVTSourceTextView_Original_MouseDragged = nil;
static IMP CAT_DVTSourceTextView_Original_MouseDown = nil;
static IMP CAT_DVTSourceTextView_Original_DidInsertCompletionTextAtRange = nil;
static IMP CAT_DVTSourceTextView_Original_AdjustTypeOverCompletionForEditedRangeChangeInLength = nil;

NS_INLINE NSRange MPXSelectionJoinRanges(NSRange originalRange, NSRange newRange)
{
    NSRange joinedRange = newRange;

    if (newRange.location < originalRange.location)
    {
        joinedRange.length = NSMaxRange(originalRange) - newRange.location;
    }
    else
    {
        joinedRange.length = NSMaxRange(newRange) - originalRange.location;
        joinedRange.location = originalRange.location;
    }

    return joinedRange;
}

static const NSInteger MPXLeftArrowSelectionOffset = -1;
static const NSInteger MPXRightArrowSelectionOffset = 1;

@implementation DVTSourceTextView (CATEditorExtensions)

@synthesizeAssociation(DVTSourceTextView, cat_blinkTimer);
@synthesizeAssociation(DVTSourceTextView, cat_blinkState);
@synthesizeAssociation(DVTSourceTextView, cat_rangeInProgressStart);
@synthesizeAssociation(DVTSourceTextView, cat_rangeInProgress);
@synthesizeAssociation(DVTSourceTextView, cat_finalizingRanges);
@synthesizeAssociation(DVTSourceTextView, cat_selectedRanges);
@synthesizeAssociation(DVTSourceTextView, cat_selectionViews);

#pragma mark -
#pragma mark NSObject

+ (void)load
{
    CAT_DVTSourceTextView_Original_Init = PLYPoseSwizzle(self, @selector(_commonInitDVTSourceTextView), self, @selector(cat_commonInitDVTSourceTextView), YES);
    CAT_DVTSourceTextView_Original_MouseDragged = PLYPoseSwizzle(self, @selector(mouseDragged:), self, @selector(cat_mouseDragged:), YES);
    CAT_DVTSourceTextView_Original_MouseDown = PLYPoseSwizzle(self, @selector(mouseDown:), self, @selector(cat_mouseDown:), YES);
    CAT_DVTSourceTextView_Original_DidInsertCompletionTextAtRange = PLYPoseSwizzle(self, @selector(didInsertCompletionTextAtRange:), self, @selector(cat_didInsertCompletionTextAtRange:), YES);
    CAT_DVTSourceTextView_Original_AdjustTypeOverCompletionForEditedRangeChangeInLength = PLYPoseSwizzle(self, @selector(adjustTypeOverCompletionForEditedRange:changeInLength:), self, @selector(cat_adjustTypeOverCompletionForEditedRange:changeInLength:), YES);
}

#pragma mark -
#pragma mark Initializer

- (void)cat_commonInitDVTSourceTextView
{
    CAT_DVTSourceTextView_Original_Init(self, @selector(_commonInitDVTSourceTextView));

    self.cat_rangeInProgress = [MPXSelection selectionWithRange:NSMakeRange(NSNotFound, 0)];
    self.cat_rangeInProgressStart = [MPXSelection selectionWithRange:NSMakeRange(NSNotFound, 0)];

    self.selectedTextAttributes = nil;

    [self cat_startBlinking];
}

#pragma mark -
#pragma mark Cursors

- (BOOL)isSelectable
{
    return YES;
}

- (void)cat_blinkCursors:(NSTimer *)sender
{
    if ([self.cat_selectionViews count] == 0)
    {
        return;
    }

    BOOL previous = self.cat_blinkState;

    [self.cat_selectionViews enumerateObjectsUsingBlock:^(NSView *view,
                                                          NSUInteger idx,
                                                          BOOL *stop)
    {
         if (self.window.isKeyWindow)
         {
             view.hidden = !previous;
         }
         else
         {
             view.hidden = YES;
         }
     }];

    self.cat_blinkState = !previous;
}

- (void)cat_startBlinking
{
    if (self.cat_blinkTimer.valid)
    {
        return;
    }

    self.cat_blinkTimer = [NSTimer timerWithTimeInterval:0.5
                                                  target:self
                                                selector:@selector(cat_blinkCursors:)
                                                userInfo:nil
                                                 repeats:YES];

    [[NSRunLoop mainRunLoop] addTimer:self.cat_blinkTimer
                              forMode:NSRunLoopCommonModes];
}

- (void)cat_stopBlinking
{
    [self.cat_blinkTimer invalidate];
}

- (void)cat_adjustTypeOverCompletionForEditedRange:(struct _NSRange)arg1 changeInLength:(long long)arg2
{
    CAT_DVTSourceTextView_Original_AdjustTypeOverCompletionForEditedRangeChangeInLength(self, @selector(adjustTypeOverCompletionForEditedRange:changeInLength:), arg1, arg2);

    [self cat_updateSelectionVisualizations];
}

#pragma mark -
#pragma mark Setters/Getters

- (NSArray *)cat_effectiveSelectedRanges
{
    if (self.cat_finalizingRanges)
    {
        return self.cat_finalizingRanges;
    }

    return self.cat_selectedRanges ?: @[];
}

#pragma mark -
#pragma mark Keyboard Events

- (void)insertText:(id)insertObject
{
    // Prevents random stuff being thrown in.
    if (![insertObject isKindOfClass:[NSString class]])
    {
        return;
    }

    NSString *insertString = (NSString *)insertObject;

    // Sequential (negative) offset of characters added.
    __block NSInteger totalDelta = 0;
    [self cat_mapAndFinalizeSelectedRanges:^MPXSelection *(MPXSelection *selection)
    {
        NSRange range = selection.range;
        NSUInteger insertStringLength = [insertString length];

        // Offset by the previous mutations made (+/- doesn't matter, as long as the different maths at each point correspond to the relative offset made by inserting a # of chars.)
        NSRange offsetRange = NSMakeRange(range.location + totalDelta, range.length);
        [self insertText:insertString replacementRange:offsetRange];

        // Offset the following ones by noting the original length and updating for the replacement's length, moving cursors following forward/backward.
        NSInteger delta = range.length - insertStringLength;
        totalDelta -= delta;

        NSRange lineRange;
        (void)[self.layoutManager lineFragmentRectForGlyphAtIndex:NSMaxRange(offsetRange)
                                                   effectiveRange:&lineRange];

        NSUInteger relativeLinePosition = selection.intralineDesiredIndex;

        if (relativeLinePosition == NSNotFound)
        {
            relativeLinePosition = NSMaxRange(offsetRange) - lineRange.location;
        }

        // Move cursor (or range-selection) to the end of what was just added with 0-length.
        NSRange newInsertionPointRange = NSMakeRange(offsetRange.location + insertStringLength, 0);
        return [[MPXSelection alloc] initWithSelectionRange:newInsertionPointRange
                                           intralineDesiredIndex:relativeLinePosition];
    }];
}

- (void)deleteBackward:(id)sender
{
    // Sequential (negative) offset of characters added.
    __block NSInteger totalDelta = 0;

    [self cat_mapAndFinalizeSelectedRanges:^MPXSelection *(MPXSelection *selection)
    {
        // Update the base range with the delta'd amount of change from previous mutations.
        NSRange range = [selection range];
        NSRange offsetRange = NSMakeRange(range.location + totalDelta, range.length);

        NSRange deletingRange = NSMakeRange(0, 0);
        if (offsetRange.length == 0)
        {
            deletingRange = NSMakeRange(offsetRange.location - 1, 1);
        }
        else
        {
            deletingRange = NSMakeRange(offsetRange.location, offsetRange.length);
        }

        // Delete the characters
        [self insertText:@"" replacementRange:deletingRange];

        // New range for the beam (to the beginning of the range we replaced)
        NSRange newInsertionPointRange = NSMakeRange(deletingRange.location, 0);
        MPXSelection *newSelection = [MPXSelection selectionWithRange:newInsertionPointRange];

        // Increment/decrement the delta by how much we trimmed.
        totalDelta -= deletingRange.length;

        return newSelection;
    }];
}

#pragma mark Indentations/Other insertions

- (void)insertNewline:(id)sender
{
    NSUndoManager *undoManager = self.undoManager;
    DVTTextStorage *textStorage = (DVTTextStorage *)self.textStorage;

    [self insertText:@"\n"];

    [self cat_mapAndFinalizeSelectedRanges:^MPXSelection *(MPXSelection *selection) {
        NSRange range = selection.range;

        [textStorage indentAtBeginningOfLineForCharacterRange:range undoManager:undoManager];

        {
            NSLayoutManager *layoutManager = [self layoutManager];
            NSRange lineRange;
            NSUInteger desiredIndex = [layoutManager glyphIndexForCharacterAtIndex:NSMaxRange(range) + 1];
            NSUInteger lineNumber = 0;
            NSUInteger numberOfLines = 0;

            for (NSUInteger index = 0; index < [layoutManager numberOfGlyphs]; numberOfLines++)
            {
                (void) [layoutManager lineFragmentRectForGlyphAtIndex:index
                                                       effectiveRange:&lineRange];

                if (desiredIndex >= lineRange.location && desiredIndex <= NSMaxRange(lineRange))
                {
                    lineNumber = numberOfLines;
                    break;
                }

                index = NSMaxRange(lineRange);
            }

            NSUInteger firstNonBlank = [textStorage firstNonblankForLine:lineNumber - 1 convertTabs:YES];

            NSRange effectiveRange;
            (void)[self.layoutManager lineFragmentRectForGlyphAtIndex:desiredIndex
                                                       effectiveRange:&effectiveRange];
            return [MPXSelection selectionWithRange:NSMakeRange(effectiveRange.location + firstNonBlank, 0)];
        }

        return selection;
    }];
}

- (void)paste:(id)sender
{
    NSString *clipboardContents = [[NSPasteboard generalPasteboard] stringForType:NSPasteboardTypeString];
    if (!clipboardContents)
    {
        return;
    }

    [self insertText:clipboardContents];
}

#pragma mark Document Navigation

- (void)cat_moveToRange:(NSRange)newRange modifyingSelection:(BOOL)modifySelection
{
    // It would be possible to just take the longest range and unionize from there, but this is the most uniform approach.
    // Iterate over, join them to the start, and let the filter take care of joining them all into one.
    // In cases where the selection isn't being modified, they'll all just be set to 0,0 and they'll be de-duplicated.
    [self cat_mapAndFinalizeSelectedRanges:^MPXSelection *(MPXSelection *selection)
     {
         NSRange previousAbsoluteRange = selection.range;
         NSRange newAbsoluteRange = newRange;

         if (modifySelection)
         {
             newAbsoluteRange = MPXSelectionJoinRanges(previousAbsoluteRange, newAbsoluteRange);
         }

         return [MPXSelection selectionWithRange:newAbsoluteRange];
     }];
}

- (void)cat_moveToBeginningOfDocumentModifyingSelection:(BOOL)modifySelection
{
    [self cat_moveToRange:NSMakeRange(0, 0) modifyingSelection:modifySelection];
}

- (void)cat_moveToEndOfDocumentModifyingSelection:(BOOL)modifySelection
{
    [self cat_moveToRange:NSMakeRange([self.textStorage length] - 1, 0) modifyingSelection:modifySelection];
}

- (void)moveToBeginningOfDocument:(id)sender
{
    [self cat_moveToBeginningOfDocumentModifyingSelection:NO];
}

- (void)moveToBeginningOfDocumentAndModifySelection:(id)sender
{
    [self cat_moveToBeginningOfDocumentModifyingSelection:YES];
}

- (void)moveToEndOfDocument:(id)sender
{
    [self cat_moveToEndOfDocumentModifyingSelection:NO];
}

- (void)moveToEndOfDocumentAndModifySelection:(id)sender
{
    [self cat_moveToEndOfDocumentModifyingSelection:YES];
}

#pragma mark Line Movements

- (void)cat_moveSelectionsToRelativePositionWithinLine:(CATRelativePosition)relativePosition
                                    modifyingSelection:(BOOL)modifySelection
{
    NSCAssert(relativePosition != CATRelativePositionTop, @"Paragraph methods should be used to move up lines.");
    NSCAssert(relativePosition != CATRelativePositionBottom, @"Paragraph methods should be used to move down lines.");

    [self cat_mapAndFinalizeSelectedRanges:^MPXSelection *(MPXSelection *selection)
    {
        NSRange previousAbsoluteRange = selection.range;

        // The cursors are being pushed to the line's relative location of 0 or .length.
        NSRange rangeOfContainingLine = ({
            NSRange range;
            NSUInteger locationToBaseFrom = previousAbsoluteRange.location;

            if (relativePosition == CATRelativePositionRight)
            {
                locationToBaseFrom = NSMaxRange(previousAbsoluteRange);
            }

            [self.layoutManager lineFragmentRectForGlyphAtIndex:locationToBaseFrom
                                                 effectiveRange:&range];
            range;
        });

        NSRange cursorRange = NSMakeRange(rangeOfContainingLine.location, 0);

        if (relativePosition == CATRelativePositionRight)
        {
            cursorRange.location += rangeOfContainingLine.length - 1;
        }

        if (modifySelection)
        {
            cursorRange = MPXSelectionJoinRanges(previousAbsoluteRange, cursorRange);
        }

        return [MPXSelection selectionWithRange:cursorRange];
    }];
}

- (void)cat_moveToLeftEndOfLineModifyingSelection:(BOOL)modifySelection
{
    [self cat_moveSelectionsToRelativePositionWithinLine:CATRelativePositionLeft
                                      modifyingSelection:modifySelection];
}

- (void)cat_moveToRightEndOfLineModifyingSelection:(BOOL)modifySelection
{
    [self cat_moveSelectionsToRelativePositionWithinLine:CATRelativePositionRight
                                      modifyingSelection:modifySelection];
}

#pragma mark Line Movement Forwarding (Directional)

- (void)moveToLeftEndOfLine:(id)sender
{
    [self cat_moveToLeftEndOfLineModifyingSelection:NO];
}

- (void)moveToLeftEndOfLineAndModifySelection:(id)sender
{
    [self cat_moveToLeftEndOfLineModifyingSelection:YES];
}

- (void)moveToRightEndOfLine:(id)sender
{
    [self cat_moveToRightEndOfLineModifyingSelection:NO];
}

- (void)moveToRightEndOfLineAndModifySelection:(id)sender
{
    [self cat_moveToRightEndOfLineModifyingSelection:YES];
}

#pragma mark Line Movement Forwarding (Semantic)

- (void)moveToBeginningOfLine:(id)sender
{
    [self moveToLeftEndOfLine:sender];
}

- (void)moveToBeginningOfLineAndModifySelection:(id)sender
{
    [self moveToLeftEndOfLineAndModifySelection:sender];
}

- (void)moveToEndOfLine:(id)sender
{
    [self moveToRightEndOfLine:sender];
}

- (void)moveToEndOfLineAndModifySelection:(id)sender
{
    [self moveToRightEndOfLineAndModifySelection:sender];
}

#pragma mark -

- (void)cat_moveLinePositionIncludingLength:(BOOL)includeLength
                            modifySelection:(BOOL)modifySelection
{
    DVTTextStorage *textStorage = (DVTTextStorage *)self.textStorage;

    [self cat_mapAndFinalizeSelectedRanges:^MPXSelection *(MPXSelection *selection)
    {
        NSRange previousAbsoluteRange = selection.range;
        NSRange previousLineRange = [textStorage.string lineRangeForRange:previousAbsoluteRange];

        NSRange newAbsoluteRange = previousAbsoluteRange;

        if (includeLength)
        {
            // It's at the end of the line and needs to be moved down
            if (NSMaxRange(previousAbsoluteRange) == (NSMaxRange(previousLineRange) - 1) && NSMaxRange(previousLineRange) < [self.textStorage length])
            {
                NSRange newLineRange = [textStorage.string lineRangeForRange:NSMakeRange(NSMaxRange(previousLineRange), 0)];
                newAbsoluteRange = NSMakeRange(NSMaxRange(newLineRange) - 1, 0);
            }
            else
            {
                newAbsoluteRange = NSMakeRange(NSMaxRange(previousLineRange) - 1, 0);
            }
        }
        else
        {
            // It's at the beginning of the line and needs to be moved up
            if (previousAbsoluteRange.location == previousLineRange.location && previousLineRange.location > 0)
            {
                NSRange newLineRange = [textStorage.string lineRangeForRange:NSMakeRange(previousLineRange.location - 1, 0)];
                newAbsoluteRange = NSMakeRange(newLineRange.location, 0);
            }
            else
            {
                newAbsoluteRange = NSMakeRange(previousLineRange.location, 0);
            }
        }

        if (modifySelection)
        {
            return [MPXSelection selectionWithRange:MPXSelectionJoinRanges(previousAbsoluteRange, newAbsoluteRange)];
        }

        return [MPXSelection selectionWithRange:newAbsoluteRange];
    }];
}

- (void)moveToBeginningOfParagraph:(id)sender
{
    [self cat_moveLinePositionIncludingLength:NO
                              modifySelection:NO];
}

- (void)moveToBeginningOfParagraphAndModifySelection:(id)sender
{
    [self cat_moveLinePositionIncludingLength:NO
                              modifySelection:YES];
}

- (void)moveToEndOfParagraph:(id)sender
{
    [self cat_moveLinePositionIncludingLength:YES
                              modifySelection:NO];
}

- (void)moveToEndOfParagraphAndModifySelection:(id)sender
{
    [self cat_moveLinePositionIncludingLength:YES
                              modifySelection:YES];
}

- (void)moveParagraphBackwardAndModifySelection:(id)sender
{
    [self cat_moveLinePositionIncludingLength:NO
                              modifySelection:YES];
}

- (void)moveParagraphForwardAndModifySelection:(id)sender
{
    [self cat_moveLinePositionIncludingLength:YES
                              modifySelection:YES];
}

#pragma mark Word Movement

- (void)cat_moveSelectionsToWordWithRelativePosition:(CATRelativePosition)relativePosition
                                     modifySelection:(BOOL)modifySelection
{
    // Sanity checks. The up/down ones should call the paragraph ones, instead.
    NSCAssert(relativePosition != CATRelativePositionTop, @"Selections may not be moved up with reference to words.");
    NSCAssert(relativePosition != CATRelativePositionBottom, @"Selections may not be moved down with reference to words.");

    // The built in method is relative to back/forwards. Right means forward.
    BOOL wordForward = relativePosition == CATRelativePositionRight;

    [self cat_mapAndFinalizeSelectedRanges:^MPXSelection *(MPXSelection *selection)
    {
        NSRange selectionRange = selection.range;

        // Going forward, we should seek the next word from the end of the range.
        NSUInteger seekingFromIndex = NSMaxRange(selectionRange);

        if (wordForward == NO)
        {
            // However, when traversing in reverse, we should use the minimum
            // of the range as the guidepost.
            seekingFromIndex = selectionRange.location;
        }

        // Get the new word index from the text storage.
        // The "nextWord..." method is specific to the DVTTextStorage class.
        DVTTextStorage *textStorage = (DVTTextStorage *)self.textStorage;
        NSUInteger wordIndex = [textStorage nextWordFromIndex:seekingFromIndex
                                                      forward:wordForward];

        NSRange newRange = NSMakeRange(wordIndex, 0);

        // Unionize the ranges if we're expanding the selection.
        if (modifySelection)
        {
            newRange = MPXSelectionJoinRanges(selectionRange, newRange);
        }

        return [MPXSelection selectionWithRange:newRange];
    }];
}

#pragma mark Word Movement Forwarding (Directional)

- (void)cat_moveWordLeftModifyingSelection:(BOOL)modifySelection
{
    [self cat_moveSelectionsToWordWithRelativePosition:CATRelativePositionLeft
                                       modifySelection:modifySelection];
}

- (void)cat_moveWordRightModifyingSelection:(BOOL)modifySelection
{
    [self cat_moveSelectionsToWordWithRelativePosition:CATRelativePositionRight
                                       modifySelection:modifySelection];
}

- (void)moveWordLeft:(id)sender
{
    [self cat_moveWordLeftModifyingSelection:NO];
}

- (void)moveWordLeftAndModifySelection:(id)sender
{
    [self cat_moveWordLeftModifyingSelection:YES];
}

- (void)moveWordRight:(id)sender
{
    [self cat_moveWordRightModifyingSelection:NO];
}

- (void)moveWordRightAndModifySelection:(id)sender
{
    [self cat_moveWordRightModifyingSelection:YES];
}

#pragma mark Word Movement Forwarding (Semantic)

- (void)moveWordBackward:(id)sender
{
    [self moveWordLeft:sender];
}

- (void)moveWordBackwardAndModifySelection:(id)sender
{
    [self moveWordLeftAndModifySelection:sender];
}

- (void)moveWordForward:(id)sender
{
    [self moveWordRight:sender];
}

- (void)moveWordForwardAndModifySelection:(id)sender
{
    [self moveWordRightAndModifySelection:sender];
}

#pragma mark Scrolling

- (void)centerSelectionInVisibleArea:(id)sender
{
#warning Unimplemented method '-centerSelectionInVisibleArea:'
    NSLog(@"Center selection requested from %@", sender);
}

#pragma mark -
#pragma mark Basic Directional Arrows
#pragma mark -

#pragma mark Simple Index-Movement

- (void)cat_offsetSelectionsDefaultingLengthsToZero:(NSInteger)amount modifySelection:(BOOL)modifySelection
{
    [self cat_mapAndFinalizeSelectedRanges:^MPXSelection *(MPXSelection *selection)
     {
         NSRange existingRange = selection.range;

         // Start the new range from the existing point, resetting the length to 0.
         NSRange newRange = existingRange;
         newRange.length = 0;

         // Push the range forward or move it backwards.
         if (amount > 0)
         {
             newRange.location = NSMaxRange(existingRange) + amount;
         }
         else
         {
             newRange.location = existingRange.location + amount;
         }

         // Validate the range at the edges
         if (newRange.location == NSUIntegerMax)
         {
             newRange.location = 0;
         }
         else if (newRange.location > [self.textStorage length])
         {
             newRange.location = self.textStorage.length - 1;
         }

         // The selection should reach out and touch where it originated from.
         if (modifySelection)
         {
             newRange = MPXSelectionJoinRanges(existingRange, newRange);
         }

         return [MPXSelection selectionWithRange:newRange];
     }];
}

- (void)moveLeft:(id)sender
{
    [self cat_moveLeftModifyingSelection:NO];
}

- (void)moveLeftAndModifySelection:(id)sender
{
    [self cat_moveLeftModifyingSelection:YES];
}

- (void)cat_moveLeftModifyingSelection:(BOOL)modifySelection
{
    [self cat_offsetSelectionsDefaultingLengthsToZero:MPXLeftArrowSelectionOffset
                                      modifySelection:modifySelection];
}

- (void)moveRight:(id)sender
{
    [self cat_moveRightModifyingSelection:NO];
}

- (void)moveRightAndModifySelection:(id)sender
{
    [self cat_moveRightModifyingSelection:YES];
}

- (void)cat_moveRightModifyingSelection:(BOOL)modifySelection
{
    [self cat_offsetSelectionsDefaultingLengthsToZero:MPXRightArrowSelectionOffset
                                      modifySelection:modifySelection];
}

#pragma mark Up and Down/Line-Movements

- (void)cat_shiftSelectionLineWithRelativePosition:(CATRelativePosition)position
                                modifyingSelection:(BOOL)modifySelection
{
    NSCAssert(position != CATRelativePositionLeft, @"Use beginning/end of line methods.");
    NSCAssert(position != CATRelativePositionRight, @"Use beginning/end of line methods.");

    NSLayoutManager *layoutManager = self.layoutManager;

    [self cat_mapAndFinalizeSelectedRanges:^MPXSelection *(MPXSelection *selection)
    {
        // "Previous" refers exclusively to time, not location.
        NSRange previousAbsoluteRange = selection.range;

        // Effective range is used because lineRangeForRange does not handle the custom linebreaking/word-wrapping that the text view does.
        NSRange previousLineRange = ({
            NSRange range;
            [layoutManager lineFragmentRectForGlyphAtIndex:NSMaxRange(previousAbsoluteRange)
                                            effectiveRange:&range];
            range;
        });

        // The index of the selection relative to the start of the line in the entire string
        NSUInteger previousRelativeIndex = NSMaxRange(previousAbsoluteRange) - previousLineRange.location;

        // Where the cursor is placed is not where it originally came from, so we should aim to place it there.
        if (selection.intralineDesiredIndex != previousRelativeIndex &&
            selection.intralineDesiredIndex != NSNotFound)
        {
            previousRelativeIndex = selection.intralineDesiredIndex;
        }

        // The selection is in the first/zero-th line, so there is no above line to find.
        // Sublime Text and OS X behavior is to jump to the start of the document.
        if (previousLineRange.location == 0 &&
            position == CATRelativePositionTop)
        {
            return [MPXSelection selectionWithRange:NSMakeRange(0, 0)];
        }
        else if (NSMaxRange(previousLineRange) == self.textStorage.length &&
                 position == CATRelativePositionBottom)
        {
            return [MPXSelection selectionWithRange:NSMakeRange(self.textStorage.length, 0)];
        }


        NSRange newLineRange = ({
            NSRange range;

            if (position == CATRelativePositionTop)
            {
                [layoutManager lineFragmentRectForGlyphAtIndex:previousLineRange.location - 1
                                                effectiveRange:&range];
            }
            else
            {
                [layoutManager lineFragmentRectForGlyphAtIndex:NSMaxRange(previousLineRange)
                                                effectiveRange:&range];
            }


            range;
        });

        // The line is long enough to show at the original relative-index
        if (newLineRange.length > previousRelativeIndex)
        {
            NSUInteger desiredPosition = newLineRange.location + previousRelativeIndex;

            NSRange newAbsoluteRange = NSMakeRange(desiredPosition, 0);
            if (modifySelection)
            {
                newAbsoluteRange = MPXSelectionJoinRanges(previousAbsoluteRange, newAbsoluteRange);
            }

            return [MPXSelection selectionWithRange:newAbsoluteRange];
        }

        NSRange newAbsoluteRange = NSMakeRange(NSMaxRange(newLineRange) - 1, 0);
        if (modifySelection)
        {
            newAbsoluteRange = MPXSelectionJoinRanges(previousAbsoluteRange, newAbsoluteRange);
        }

        // This will place it at the end of the line, aiming to be placed at the original position.
        return [[MPXSelection alloc] initWithSelectionRange:newAbsoluteRange
                                           intralineDesiredIndex:previousRelativeIndex];
    }];
}

- (void)cat_moveSelectionsUpModifyingSelection:(BOOL)modifySelection
{
    [self cat_shiftSelectionLineWithRelativePosition:CATRelativePositionTop
                                  modifyingSelection:modifySelection];
}

- (void)cat_moveSelectionsDownModifyingSelection:(BOOL)modifySelection
{
    [self cat_shiftSelectionLineWithRelativePosition:CATRelativePositionBottom
                                  modifyingSelection:modifySelection];
}

#pragma mark Up/Down Forwarding Methods

- (void)moveUp:(id)sender
{
    [self cat_moveSelectionsUpModifyingSelection:NO];
}

- (void)moveUpAndModifySelection:(id)sender
{
    [self cat_moveSelectionsUpModifyingSelection:YES];
}

- (void)moveDown:(id)sender
{
    [self cat_moveSelectionsDownModifyingSelection:NO];
}

- (void)moveDownAndModifySelection:(id)sender
{
    [self cat_moveSelectionsDownModifyingSelection:YES];
}

#pragma mark Semantic Directional Movements (alias to explicit ones)

- (void)moveBackward:(id)sender
{
    [self moveLeft:sender];
}

- (void)moveBackwardAndModifySelection:(id)sender
{
    [self moveLeftAndModifySelection:sender];
}

- (void)moveForward:(id)sender
{
    [self moveRight:sender];
}

- (void)moveForwardAndModifySelection:(id)sender
{
    [self moveRightAndModifySelection:sender];
}

#pragma mark -

#pragma mark -
#pragma mark Mouse Events

- (void)cat_mouseDragged:(NSEvent *)theEvent
{
    [self cat_stopBlinking];

    NSRange rangeInProgress = self.cat_rangeInProgress.range;
    NSRange rangeInProgressOrigin = self.cat_rangeInProgressStart.range;

    if (rangeInProgress.location == NSNotFound || rangeInProgressOrigin.location == NSNotFound)
    {
        return;
    }

    CGPoint clickLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSUInteger index = [self characterIndexForInsertionAtPoint:clickLocation];
    NSRange newRange;

    if (index > rangeInProgressOrigin.location)
    {
        newRange = NSMakeRange(rangeInProgressOrigin.location, index - rangeInProgressOrigin.location);
    }
    else
    {
        newRange = NSMakeRange(index, (rangeInProgressOrigin.location + rangeInProgressOrigin.length) - index);
    }

    // Update the model value for when it is used combinatorily.
    self.cat_rangeInProgress = [MPXSelection selectionWithRange:newRange];

    [self cat_setSelectedRanges:[self.cat_selectedRanges arrayByAddingObject:[MPXSelection selectionWithRange:newRange]]
                       finalize:NO];
}

- (void)cat_mouseDown:(NSEvent *)theEvent
{
    NSUInteger index = ({
        CGPoint clickLocation = [self convertPoint:[theEvent locationInWindow]
                                          fromView:nil];
        [self characterIndexForInsertionAtPoint:clickLocation];
    });

    if (index == NSNotFound)
    {
        return;
    }

    NSInteger clickCount = theEvent.clickCount;
    BOOL commandKeyHeld = (theEvent.modifierFlags & NSCommandKeyMask) != 0;
    BOOL altKeyHeld = (theEvent.modifierFlags & NSAlternateKeyMask) != 0;

    if (altKeyHeld)
    {
        CAT_DVTSourceTextView_Original_MouseDown(self, @selector(mouseDown:), theEvent);
        return;
    }

    NSArray *selections = [self cat_effectiveSelectedRanges];
    NSRange resultRange = NSMakeRange(NSNotFound, 0);
    DVTTextStorage *textStorage = (DVTTextStorage *)self.textStorage;

    switch (clickCount) {
        // Selects only the single point at the approximate location of the cursor
        case 1:
            resultRange = NSMakeRange(index, 0);
            break;
        case 2:
        {
            if ([((DVTLayoutManager *)self.layoutManager) foldCellAtCharacterIndex:index])
            {
                CAT_DVTSourceTextView_Original_MouseDown(self, @selector(mouseDown:), theEvent);
                return;
            }

            resultRange = [textStorage doubleClickAtIndex:index];
            break;
        }
        case 3:
            resultRange = [textStorage.string lineRangeForRange:NSMakeRange(index, 0)];
            break;
        default:
            return;
    }

    if (resultRange.location == NSNotFound)
    {
        return;
    }

    MPXSelection *selection = [MPXSelection selectionWithRange:resultRange];
    self.cat_rangeInProgress = selection;
    self.cat_rangeInProgressStart = selection;

    if (commandKeyHeld)
    {
        [self cat_setSelectedRanges:[selections arrayByAddingObject:selection]
                           finalize:NO];
    }
    else
    {
        /* Because the click was singular, the other selections will *not* come back under any circumstances. Thus, it must be finalized at the point where it's at is if it's a zero-length selection. Otherwise, they'll be re-added during dragging. */
        [self cat_setSelectedRanges:@[selection]
                           finalize:YES];

        /* In the event the user drags, however, it needs to unfinalized so that it can be extended again. */
        [self cat_setSelectedRanges:@[selection]
                           finalize:NO];
    }
}

- (void)mouseUp:(NSEvent *)theEvent
{
    [self cat_setSelectedRanges:[self cat_effectiveSelectedRanges] finalize:YES];
    self.cat_rangeInProgress = [MPXSelection selectionWithRange:NSMakeRange(NSNotFound, 0)];
    self.cat_rangeInProgressStart = [MPXSelection selectionWithRange:NSMakeRange(NSNotFound, 0)];

    [self cat_startBlinking];
}


#pragma mark -
#pragma mark Range Manipulation

- (void)selectAll:(id)sender
{
    [self cat_setSelectedRanges:@[[MPXSelection selectionWithRange:NSMakeRange(0, [self.textStorage.string length])]]
                       finalize:YES];
}

- (void)cat_mapAndFinalizeSelectedRanges:(MPXSelection * (^)(MPXSelection *selection))mapBlock
{
    NSArray *mappedValues = [[[[self cat_effectiveSelectedRanges] rac_sequence] map:mapBlock] array];
    [self cat_setSelectedRanges:mappedValues
                       finalize:YES];
}

- (NSArray *)cat_sortRanges:(NSArray *)ranges
{
    // Standard sorting logic.
    // Do not include the length so that iteration can do sequential iteration thereafter and do reducing.
    return [ranges sortedArrayUsingComparator:^NSComparisonResult(MPXSelection *selectionRange1,
                                                                  MPXSelection *selectionRange2)
            {
                NSRange range1 = [selectionRange1 range];
                NSInteger range1Loc = range1.location;

                NSRange range2 = [selectionRange2 range];
                NSInteger range2Loc = range2.location;

                if (range2Loc > range1Loc)
                {
                    return NSOrderedAscending;
                }
                else if (range2Loc < range1Loc)
                {
                    return NSOrderedDescending;
                }

                return NSOrderedSame;
            }];
}

- (NSArray *)cat_reduceSortedRanges:(NSArray *)sortedRanges
{

    RACSequence *sortedSequence = [sortedRanges rac_sequence];
    NSArray *reducedRanges = [sortedSequence map:^MPXSelection *(MPXSelection *selection)
    {
         NSRange range1 = [selection range];

         __block NSRange rangeToAdd = range1;
         __block BOOL shouldAdd = YES;
        
         [sortedRanges enumerateObjectsWithOptions:0 usingBlock:^(MPXSelection *selectionRange2, NSUInteger idx2, BOOL *stop2)
          {
              NSRange range2 = [selectionRange2 range];

              BOOL literallyTheSameRange = idx == idx2;

              if (literallyTheSameRange)
              {
                  return;
              }

              BOOL endsBeyondStartOfRange = range2.location + range2.length >= rangeToAdd.location;
              BOOL startsBeforeOrWithinRange = range2.location <= rangeToAdd.location + rangeToAdd.length;

              if (endsBeyondStartOfRange && startsBeforeOrWithinRange)
              {
                  NSRange originalRangeToAdd = rangeToAdd;
                  shouldCompare[idx2] = @NO;

                  NSInteger relativeIncrease = (rangeToAdd.location + rangeToAdd.length) - range2.location;
                  if (relativeIncrease < range2.length)
                  {
                      rangeToAdd.length += range2.length - relativeIncrease;
                      modifiedSelections[idx2] = @YES;
                  }

                  if (NSEqualRanges(originalRangeToAdd, self.cat_rangeInProgress.range))
                  {
#warning Logic here does not transfer intraline index
                      self.cat_rangeInProgress = [MPXSelection selectionWithRange:rangeToAdd];
                  }
              }
          }];

         [reducedRanges enumerateObjectsUsingBlock:^(MPXSelection *selectionRange2, NSUInteger idx, BOOL *stop)
          {
              NSRange range2 = [selectionRange2 range];
              BOOL equivalentRanges = NSEqualRanges(rangeToAdd, range2);
              if (equivalentRanges)
              {
                  shouldAdd = NO;
                  *stop = YES;
                  return;
              }
          }];


         BOOL modifiedSelection = [modifiedSelections[idx] boolValue];
         if (shouldAdd && modifiedSelection)
         {
             [reducedRanges addObject:[MPXSelection selectionWithRange:rangeToAdd]];
         }
         else if (shouldAdd && !modifiedSelection)
         {
             [reducedRanges addObject:[[MPXSelection alloc] initWithSelectionRange:rangeToAdd
                                                             intralineDesiredIndex:selectionRange1.intralineDesiredIndex]];
         }
    }].array;

    return [[NSArray alloc] initWithArray:reducedRanges];
}

- (NSArray *)prepareRanges:(NSArray *)ranges
{
    NSArray *sortedRanges = [self cat_sortRanges:ranges];
    NSArray *reducedRanges = [self cat_reduceSortedRanges:sortedRanges];

    return reducedRanges;
}

- (void)cat_setSelectedRanges:(NSArray *)selectedRanges finalize:(BOOL)finalized
{
    /* Sort and reduce the ranges passed in */
    NSArray *ranges = [self prepareRanges:selectedRanges];

    if (finalized)
    {
        if ([self.cat_selectedRanges isEqual:ranges] && self.cat_finalizingRanges == nil)
        {
            return;
        }

        self.cat_selectedRanges = ranges;
        self.cat_finalizingRanges = nil;
    }
    else
    {
        if ([ranges isEqualToArray:self.cat_finalizingRanges])
        {
            return;
        }

        self.cat_finalizingRanges = ranges;
    }
    
    self.selectedTextAttributes = nil;

    /* Set the selected range for the breadcrumb bar. */
    if ([ranges count] > 0)
    {
        MPXSelection *firstSelection = (MPXSelection *)[ranges firstObject];
        self.selectedRange = firstSelection.range;
    }
    else
    {
        self.selectedRange = NSMakeRange(0, 0);
    }

    [self cat_updateSelectionVisualizations];
}

- (void)cat_updateSelectionVisualizations
{
    DVTTextStorage *textStorage = (DVTTextStorage *)self.textStorage;
    NSArray *ranges = [self cat_effectiveSelectedRanges];

    /* Reset the background color of all the source text. */
    NSColor *backgroundColor = textStorage.fontAndColorTheme.sourceTextBackgroundColor;
    [self.layoutManager setTemporaryAttributes:@{NSBackgroundColorAttributeName: backgroundColor}
                             forCharacterRange:NSMakeRange(0, self.string.length)];


    /* Remove any onscreen cursors */
    [self.cat_selectionViews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    RACSequence *rangeSequence = [ranges rac_sequence];
    self.cat_selectionViews = [[rangeSequence map:^NSView *(MPXSelection *selection)
    {
        NSRange range = [selection range];

        if (range.length > 0)
        {
            NSColor *backgroundColor = textStorage.fontAndColorTheme.sourceTextSelectionColor;

            [self.layoutManager setTemporaryAttributes:@{NSBackgroundColorAttributeName: backgroundColor}
                                     forCharacterRange:range];
        }

        NSRange glyphRange = [self.layoutManager glyphRangeForCharacterRange:range
                                                        actualCharacterRange:nil];

        NSRect glyphRect = [self.layoutManager boundingRectForGlyphRange:NSMakeRange(glyphRange.location + glyphRange.length, 0)
                                                         inTextContainer:self.textContainer];

        CGRect caretRect = CGRectOffset(CGRectMake(glyphRect.origin.x, glyphRect.origin.y, 1.f, CGRectGetHeight(glyphRect)),
                                        self.textContainerOrigin.x,
                                        self.textContainerOrigin.y);

        NSView *caretView = [[NSView alloc] initWithFrame:caretRect];
        caretView.wantsLayer = YES;
        caretView.layer.backgroundColor = [textStorage.fontAndColorTheme.sourceTextInsertionPointColor CGColor];

        return caretView;
    }] array];

    [self.cat_selectionViews enumerateObjectsUsingBlock:^(NSView *caret,
                                                          NSUInteger idx,
                                                          BOOL *stop)
    {
        [self addSubview:caret];
    }];
}

- (void)_drawInsertionPointInRect:(CGRect)rect color:(NSColor *)color
{

}

#pragma mark -
#pragma mark Autocompletion

- (void)cat_didInsertCompletionTextAtRange:(NSRange)completedTextRange
{
    __block NSInteger offset = 0;

    /* The first range is the one which needs to be outright replaced from the start.
     What's passed back with `completedTextRange` is the first range's replacement. */

    NSArray *selections =
    ({
        NSMutableArray *selections = [[NSMutableArray alloc] initWithArray:[self cat_effectiveSelectedRanges]];

        MPXSelection *existingSelection = selections[0];

        offset += NSMaxRange(completedTextRange) - NSMaxRange(existingSelection.range);

        selections[0] = [MPXSelection selectionWithRange:completedTextRange];
        selections;
    });

    NSString *completionText = [self.string substringWithRange:completedTextRange];

    /* Now, the remaining ranges need to be adjusted to include the text (and adjust the selection.) */

    __block NSUInteger idx = 0;
    NSArray *newSelections = [[selections rac_sequence] map:^MPXSelection *(MPXSelection *selection)
    {
        NSRange selectionRange = selection.range;

        if (idx > 0)
        {
            selectionRange.location += offset;

            /* First, one needs to reverse-enumerate over the completion text. We're looking for the first match of a character, and then traversing back from there. Then we'll know what, if anything, is already available as a base to complete. If nothing is there, the whole string needs to be inserted.
             */
            NSInteger completionStringIndex = [completionText length] - 1;

            /* Used as the pointer to walk-back from the selection and see what matches. Essentially, we're wanting to find the first substring to match and go back from there to see if it matches the "full" partial substring to the beginning of it. For instance:

             (Completing for the word `category`)

             cate| vs. nate|

             Only chcking the first char before the selection would not be accurate.
             */

            NSInteger selectionRelativeIndex = 0;

            while (completionStringIndex >= 0)
            {
                unichar completionChar = [completionText characterAtIndex:completionStringIndex];
                unichar compareStorageChar = [self.string characterAtIndex:(NSMaxRange(selectionRange) - 1) + selectionRelativeIndex];

                if (completionChar == compareStorageChar)
                {
                    selectionRelativeIndex--;
                }

                /* Always decrement, as we're seeking the first match within the completion string that is found in the text. If a match was found, we need to continue walking back.
                 */
                completionStringIndex--;
            }

            NSInteger completionStringStartIndex = -selectionRelativeIndex;
            NSInteger insertedStringLength = ([completionText length]) - completionStringStartIndex;
            
            [self insertText:[completionText substringFromIndex:completionStringStartIndex]
            replacementRange:NSMakeRange(NSMaxRange(selectionRange), 0)];

            offset += insertedStringLength;
        }

        NSRange indentedRange = [self _indentInsertedTextIfNecessaryAtRange:selectionRange];
        
        NSRange firstPlaceholder = [self rangeOfPlaceholderFromCharacterIndex:indentedRange.location
                                                                      forward:YES
                                                                         wrap:YES
                                                                        limit:indentedRange.length];

        idx++;

        if (firstPlaceholder.location == NSUIntegerMax)
        {
            NSRange finalEndOfCompletionRange = NSMakeRange(NSMaxRange(indentedRange), 0);
            return [MPXSelection selectionWithRange:finalEndOfCompletionRange];
        }

        return [MPXSelection selectionWithRange:firstPlaceholder];
    }].array;

    [self cat_setSelectedRanges:newSelections
                       finalize:YES];
}

@end
