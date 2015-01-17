//
//  IDESourceCodeEditor+CATViewReplacement.m
//  Catalyst
//
//  Created by Kolin Krewinkel on 9/25/14.
//  Copyright (c) 2014 Kolin Krewinkel. All rights reserved.
//

@import QuartzCore;

#import <INPopoverController/INPopoverController.h>
#import <libextobjc/extobjc.h>
#import <pop/POP.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

#import "DVTSourceTextView+CATEditorExtensions.h"

#import "CATNextNavigator.h"
#import "CATNavigatorTarget.h"
#import "CATSelectionRange.h"
#import "PLYSwizzling.h"

static IMP CAT_DVTSourceTextView_Original_Init = nil;
static IMP CAT_DVTSourceTextView_Original_MouseDragged = nil;

NS_INLINE NSRange CAT_SelectionJoinRanges(NSRange originalRange, NSRange newRange)
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

static const NSInteger CAT_LeftArrowSelectionOffset = -1;
static const NSInteger CAT_RightArrowSelectionOffset = 1;

@implementation DVTSourceTextView (CATEditorExtensions)

@synthesizeAssociation(DVTSourceTextView, cat_blinkTimer);
@synthesizeAssociation(DVTSourceTextView, cat_blinkState);
@synthesizeAssociation(DVTSourceTextView, cat_rangeInProgressStart);
@synthesizeAssociation(DVTSourceTextView, cat_rangeInProgress);
@synthesizeAssociation(DVTSourceTextView, cat_finalizingRanges);
@synthesizeAssociation(DVTSourceTextView, cat_selectedRanges);
@synthesizeAssociation(DVTSourceTextView, cat_selectionViews);
@synthesizeAssociation(DVTSourceTextView, cat_nextNavigator);

#pragma mark -
#pragma mark NSObject

+ (void)load
{
    CAT_DVTSourceTextView_Original_Init = PLYPoseSwizzle(self, @selector(_commonInitDVTSourceTextView), self, @selector(cat_commonInitDVTSourceTextView), YES);
    CAT_DVTSourceTextView_Original_MouseDragged = PLYPoseSwizzle(self, @selector(mouseDragged:), self, @selector(cat_mouseDragged:), YES);
}

#pragma mark -
#pragma mark Initializer

- (void)cat_commonInitDVTSourceTextView
{
    self.cat_rangeInProgress = [CATSelectionRange selectionWithRange:NSMakeRange(NSNotFound, 0)];
    self.cat_rangeInProgressStart = [CATSelectionRange selectionWithRange:NSMakeRange(NSNotFound, 0)];

    [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyDownMask handler:^NSEvent *(NSEvent *event)
     {
         if (![self cat_validateKeyDownEventForNavigator:event])
         {
             return event;
         }

         NSMutableArray *items = [[NSMutableArray alloc] init];
         DVTTextStorage *textStorage = (DVTTextStorage *)self.textStorage;

         [[self cat_effectiveSelectedRanges] enumerateObjectsUsingBlock:^(CATSelectionRange *selectionRange,
                                                                          NSUInteger idx,
                                                                          BOOL *stop)
          {
              NSRange range = selectionRange.range;

              DVTSourceModelItem *modelItem = [textStorage.sourceModelService sourceModelItemAtCharacterIndex:range.location];

              NSUInteger count = 0;
              NSRectArray rects = [self.layoutManager rectArrayForCharacterRange:modelItem.range
                                                    withinSelectedCharacterRange:modelItem.range inTextContainer:self.textContainer
                                                                       rectCount:&count];

              CATNavigatorTarget *target = [[CATNavigatorTarget alloc] initWithRect:rects[count - 1]
                                                                          modelItem:modelItem];
              [items addObject:target];
          }];

         self.cat_nextNavigator = [[CATNextNavigator alloc] initWithView:self.superview
                                                             targetItems:items
                                                           layoutManager:self.layoutManager];
         [self.cat_nextNavigator showItems:items];


         return nil;
     }];

    CAT_DVTSourceTextView_Original_Init(self, @selector(_commonInitDVTSourceTextView));

    [self cat_startBlinking];
}

#pragma mark -
#pragma mark Cursors

- (void)cat_blinkCursors:(NSTimer *)sender
{
    if ([self.cat_selectionViews count] == 0)
    {
        return;
    }

    BOOL previous = self.cat_blinkState;

    [self.cat_selectionViews enumerateKeysAndObjectsUsingBlock:^(id key,
                                                                 NSView *view,
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

    self.cat_blinkState = !self.cat_blinkState;
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

#pragma mark -
#pragma mark Navigator

- (BOOL)cat_validateKeyDownEventForNavigator:(NSEvent *)event
{
    if ([[self window] firstResponder] != self)
    {
        return NO;
    }

    return (event.modifierFlags & NSAlternateKeyMask && [event.charactersIgnoringModifiers isEqualToString:@" "]);
}

#pragma mark -
#pragma mark Setters/Getters

- (BOOL)isSelectable
{
    return NO;
}

- (NSArray *)cat_effectiveSelectedRanges
{
    if (self.cat_finalizingRanges)
    {
        return self.cat_finalizingRanges;
    }

    return self.cat_selectedRanges;
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
    [self cat_mapAndFinalizeSelectedRanges:^CATSelectionRange *(CATSelectionRange *selection)
    {
        NSRange range = selection.range;
        NSUInteger insertStringLength = [insertString length];

        // Offset by the previous mutations made (+/- doesn't matter, as long as the different maths at each point correspond to the relative offset made by inserting a # of chars.)
        NSRange offsetRange = NSMakeRange(range.location + totalDelta, range.length);
        [self insertText:insertString replacementRange:offsetRange];

        // Offset the following ones by noting the original length and updating for the replacement's length, moving cursors following forward/backward.
        NSInteger delta = range.length - insertStringLength;
        totalDelta -= delta;

        // Move cursor (or range-selection) to the end of what was just added with 0-length.
        NSRange newInsertionPointRange = NSMakeRange(offsetRange.location + insertStringLength, 0);
        return [CATSelectionRange selectionWithRange:newInsertionPointRange];
    }];
}

- (void)deleteBackward:(id)sender
{
    // Sequential (negative) offset of characters added.
    __block NSInteger totalDelta = 0;

    // Replacement insertion-pointer ranges
    NSMutableArray *newRanges = [[NSMutableArray alloc] init];

    // _Never_ concurrent. Always synchronous-in order.
    [self.cat_selectedRanges enumerateObjectsUsingBlock:^(CATSelectionRange *selectionRange,
                                                          NSUInteger idx,
                                                          BOOL *stop)
     {
         // Update the base range with the delta'd amount of change from previous mutations.
         NSRange range = [selectionRange range];
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
         [newRanges addObject:[CATSelectionRange selectionWithRange:newInsertionPointRange]];

         // Increment/decrement the delta by how much we trimmed.
         totalDelta -= deletingRange.length;
     }];

    // Update the ranges, and force finalization.
    [self cat_setSelectedRanges:newRanges finalize:YES];
}

- (void)moveToBeginningOfDocument:(id)sender
{
    [self cat_setSelectedRanges:@[[CATSelectionRange selectionWithRange:NSMakeRange(0, 0)]]
                       finalize:YES];
}

- (void)moveToEndOfDocument:(id)sender
{
    NSUInteger documentLength = [self.textStorage.string length];
    [self cat_setSelectedRanges:@[[CATSelectionRange selectionWithRange:NSMakeRange(documentLength - 1, 0)]]
                       finalize:YES];
}

- (void)cat_moveSelectionsToBeginningOrEndOfLine:(BOOL)endOfLine
{
    NSMutableArray *newRanges = [[NSMutableArray alloc] init];
    [[self cat_effectiveSelectedRanges] enumerateObjectsUsingBlock:^(CATSelectionRange *selectionRange,
                                                                     NSUInteger idx,
                                                                     BOOL *stop)
     {
         NSRange range = selectionRange.range;

         // The cursors are being pushed to the line's relative location of 0 or .length.
         NSRange rangeOfContainingLine = [self.textStorage.string lineRangeForRange:range];
         NSRange cursorRange = NSMakeRange(rangeOfContainingLine.location, 0);

         if (endOfLine)
         {
             cursorRange.location += rangeOfContainingLine.length - 1;
         }

         // Add the range with length of 0 at the position on the line.
         [newRanges addObject:[CATSelectionRange selectionWithRange:cursorRange]];
     }];

    [self cat_setSelectedRanges:newRanges
                       finalize:YES];
}

- (void)moveToLeftEndOfLine:(id)sender
{
    [self cat_moveSelectionsToBeginningOrEndOfLine:NO];
}

- (void)moveToRightEndOfLine:(id)sender
{
    [self cat_moveSelectionsToBeginningOrEndOfLine:YES];
}

- (void)moveToBeginningOfLine:(id)sender
{
    [self moveToLeftEndOfLine:sender];
}

- (void)moveToEndOfLine:(id)sender
{
    [self moveToRightEndOfLine:sender];
}

- (void)cat_jumpToLinePositionMovingVerticallyIncludingLength:(BOOL)includeLength
{
    NSLayoutManager *layoutManager = self.layoutManager;

    NSMutableArray *newRanges = [[NSMutableArray alloc] init];
    [[self cat_effectiveSelectedRanges] enumerateObjectsUsingBlock:^(CATSelectionRange *selectionRange,
                                                                     NSUInteger idx,
                                                                     BOOL *stop)
     {
         NSRange previousAbsoluteRange = selectionRange.range;

         // Effective range is used because lineRangeForRange does not handle the custom linebreaking/word-wrapping that the text view does.
         NSRange previousLineRange = ({
             NSRange range;
             [layoutManager lineFragmentRectForGlyphAtIndex:previousAbsoluteRange.location
                                             effectiveRange:&range];
             range;
         });

         if (includeLength)
         {
             // It's at the end of the line and needs to be moved down
             if (previousAbsoluteRange.location == (NSMaxRange(previousLineRange) - 1) && NSMaxRange(previousLineRange) < [self.textStorage length])
             {
                 NSRange newLineRange = ({
                     NSRange range;
                     [layoutManager lineFragmentRectForGlyphAtIndex:NSMaxRange(previousLineRange)
                                                     effectiveRange:&range];
                     range;
                 });

                 [newRanges addObject:[CATSelectionRange selectionWithRange:NSMakeRange(NSMaxRange(newLineRange) - 1, 0)]];
             }
             else
             {
                 [newRanges addObject:[CATSelectionRange selectionWithRange:NSMakeRange(NSMaxRange(previousLineRange) - 1, 0)]];
             }
         }
         else
         {
             // It's at the beginning of the line and needs to be moved up
             if (previousAbsoluteRange.location == previousLineRange.location && previousLineRange.location > 0)
             {
                 NSRange newLineRange = ({
                     NSRange range;
                     [layoutManager lineFragmentRectForGlyphAtIndex:previousLineRange.location - 1
                                                     effectiveRange:&range];
                     range;
                 });

                 [newRanges addObject:[CATSelectionRange selectionWithRange:NSMakeRange(newLineRange.location, 0)]];
             }
             else
             {
                 [newRanges addObject:[CATSelectionRange selectionWithRange:NSMakeRange(previousLineRange.location, 0)]];
             }
         }
     }];

    [self cat_setSelectedRanges:newRanges
                       finalize:YES];
}

- (void)moveToBeginningOfParagraph:(id)sender
{
    [self cat_jumpToLinePositionMovingVerticallyIncludingLength:NO];
}

- (void)moveToEndOfParagraph:(id)sender
{
    [self cat_jumpToLinePositionMovingVerticallyIncludingLength:YES];
}

- (void)moveToLeftEndOfLineAndModifySelection:(id)sender
{
#warning not complete
}

- (void)moveToRightEndOfLineAndModifySelection:(id)sender
{
#warning not complete
}

- (void)cat_moveWordLeft:(BOOL)moveLeft
{
    DVTTextStorage *textStorage = (DVTTextStorage *)self.textStorage;
    NSMutableArray *newSelections = [[NSMutableArray alloc] init];
    [[self cat_effectiveSelectedRanges] enumerateObjectsUsingBlock:^(CATSelectionRange *selection,
                                                                     NSUInteger idx,
                                                                     BOOL *stop)
    {
        NSRange selectionRange = selection.range;

        unsigned long long nextIndex = [textStorage nextWordFromIndex:NSMaxRange(selectionRange) forward:!moveLeft];
        [newSelections addObject:[CATSelectionRange selectionWithRange:NSMakeRange(nextIndex, 0)]];
    }];

    [self cat_setSelectedRanges:newSelections finalize:YES];
}

- (void)moveWordLeft:(id)sender
{
    [self cat_moveWordLeft:YES];
}

- (void)moveWordRight:(id)sender
{
    [self cat_moveWordLeft:NO];
}

#pragma mark Basic Directional Arrows

- (void)cat_offsetSelectionsDefaultingLengthsToZero:(NSInteger)amount modifySelection:(BOOL)modifySelection
{
    [self cat_mapAndFinalizeSelectedRanges:^CATSelectionRange *(CATSelectionRange *selection)
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
             newRange = CAT_SelectionJoinRanges(existingRange, newRange);
         }

         return [CATSelectionRange selectionWithRange:newRange];
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
    [self cat_offsetSelectionsDefaultingLengthsToZero:CAT_LeftArrowSelectionOffset
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
    [self cat_offsetSelectionsDefaultingLengthsToZero:CAT_RightArrowSelectionOffset
                                      modifySelection:modifySelection];
}

- (void)cat_verticalShiftUp:(BOOL)up
{
    NSLayoutManager *layoutManager = self.layoutManager;

    NSMutableArray *candidateRanges = [[NSMutableArray alloc] init];
    [[self cat_effectiveSelectedRanges] enumerateObjectsUsingBlock:^(CATSelectionRange *selection,
                                                                     NSUInteger idx,
                                                                     BOOL *stop)
     {
         // "Previous" refers exclusively to time, not location.
         NSRange previousAbsoluteRange = selection.range;

         // Effective range is used because lineRangeForRange does not handle the custom linebreaking/word-wrapping that the text view does.
         NSRange previousLineRange = ({
             NSRange range;
             [layoutManager lineFragmentRectForGlyphAtIndex:previousAbsoluteRange.location
                                             effectiveRange:&range];
             range;
         });

         // The index of the selection relative to the start of the line in the entire string
         NSUInteger previousRelativeIndex = previousAbsoluteRange.location - previousLineRange.location;

         // Where the cursor is placed is not where it originally came from, so we should aim to place it there.
         if (selection.intralineDesiredIndex != previousRelativeIndex && selection.intralineDesiredIndex != NSNotFound)
         {
             previousRelativeIndex = selection.intralineDesiredIndex;
         }

         // The selection is in the first/zero-th line, so there is no above line to find.
         // Sublime Text and OS X behavior is to jump to the start of the document.
         if (previousLineRange.location == 0 && up == YES)
         {
             [candidateRanges addObject:[CATSelectionRange selectionWithRange:NSMakeRange(0, 0)]];
             return;
         }
         else if (NSMaxRange(previousLineRange) == self.textStorage.length && up == NO)
         {
             [candidateRanges addObject:[CATSelectionRange selectionWithRange:NSMakeRange(self.textStorage.length, 0)]];
             return;
         }


         NSRange newLineRange = ({
             NSRange range;

             if (up)
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
             [candidateRanges addObject:[CATSelectionRange selectionWithRange:NSMakeRange(desiredPosition, 0)]];
         }
         else
         {
             // This will place it at the end of the line, aiming to be placed at the original position.
             [candidateRanges addObject:[[CATSelectionRange alloc] initWithSelectionRange:NSMakeRange(NSMaxRange(newLineRange) - 1, 0)
                                                                    intralineDesiredIndex:previousRelativeIndex]];
         }
     }];
    
    [self cat_setSelectedRanges:candidateRanges finalize:(self.cat_finalizingRanges == nil)];
}

- (void)moveUp:(id)sender
{
    [self cat_verticalShiftUp:YES];
}

- (void)moveDown:(id)sender
{
    [self cat_verticalShiftUp:NO];
}

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
    self.cat_rangeInProgress = [CATSelectionRange selectionWithRange:newRange];

    [self cat_setSelectedRanges:[self.cat_selectedRanges arrayByAddingObject:[CATSelectionRange selectionWithRange:newRange]]
                       finalize:NO];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    NSInteger clickCount = [theEvent clickCount];
    CGPoint clickLocation = [self convertPoint:[theEvent locationInWindow]
                                      fromView:nil];
    BOOL commandKeyHeld = (theEvent.modifierFlags & NSCommandKeyMask) != 0;

    NSArray *existingSelections = ({
        NSArray *selections = [self cat_effectiveSelectedRanges];
        if (!selections)
        {
            selections = @[];
        }

        selections;
    });
    NSUInteger index = [self characterIndexForInsertionAtPoint:clickLocation];

    if (index == NSNotFound)
    {
        return;
    }

    CATSelectionRange *selection = nil;

    // Selects only the single point at the approximate location of the cursor
    if (clickCount == 1)
    {
        NSRange cursorLocationRange = NSMakeRange(index, 0);
        CATSelectionRange *cursorSelection = [CATSelectionRange selectionWithRange:cursorLocationRange];
        selection = cursorSelection;
    }
    // Selects the local expression
    else if (clickCount == 2)
    {
        DVTTextStorage *textStorage = (DVTTextStorage *)self.textStorage;
        NSRange wordRange = [textStorage doubleClickAtIndex:index];

        selection = [CATSelectionRange selectionWithRange:wordRange];
    }
    // Selects the entire line
    else if (clickCount == 3)
    {
        selection = [CATSelectionRange selectionWithRange:[self.textStorage.string lineRangeForRange:NSMakeRange(index, 0)]];
    }

    if (selection && selection.range.location != NSIntegerMax)
    {
        self.cat_rangeInProgress = selection;
        self.cat_rangeInProgressStart = selection;

        if (commandKeyHeld)
        {

            [self cat_setSelectedRanges:[existingSelections arrayByAddingObject:selection]
                               finalize:NO];
        }
        else
        {
            [self cat_setSelectedRanges:@[selection]
                               finalize:NO];
        }
    }
}

- (void)mouseUp:(NSEvent *)theEvent
{
    [self cat_setSelectedRanges:[self cat_effectiveSelectedRanges] finalize:YES];
    self.cat_rangeInProgress = [CATSelectionRange selectionWithRange:NSMakeRange(NSNotFound, 0)];
    self.cat_rangeInProgressStart = [CATSelectionRange selectionWithRange:NSMakeRange(NSNotFound, 0)];

    [self cat_startBlinking];
}

- (void)mouseMoved:(NSEvent *)theEvent
{
    NSRect frameRelativeToWindow = [self convertRect:self.frame
                                              toView:nil];
    NSRect frameRelativeToScreen = [self.window convertRectToScreen:frameRelativeToWindow];

    if (CGRectContainsPoint(frameRelativeToScreen, [NSEvent mouseLocation])
        && [NSCursor currentCursor] != [NSCursor IBeamCursor])
    {
        [[NSCursor IBeamCursor] push];
    }
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    [[NSCursor IBeamCursor] push];
}

- (void)mouseExited:(NSEvent *)theEvent
{
    [[NSCursor IBeamCursor] pop];
}

#pragma mark -
#pragma mark Range Manipulation

- (void)cat_mapAndFinalizeSelectedRanges:(CATSelectionRange * (^)(CATSelectionRange *selection))mapBlock
{
    NSArray *mappedValues = [[[[self cat_effectiveSelectedRanges] rac_sequence] map:mapBlock] array];
    [self cat_setSelectedRanges:mappedValues
                       finalize:YES];
}

- (NSArray *)cat_sortRanges:(NSArray *)ranges
{
    // Standard sorting logic.
    // Do not include the length so that iteration can do sequential iteration thereafter and do reducing.
    return [ranges sortedArrayUsingComparator:^NSComparisonResult(CATSelectionRange *selectionRange1,
                                                                  CATSelectionRange *selectionRange2)
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
    NSMutableArray *reducedRanges = [[NSMutableArray alloc] init];
    NSMutableArray *shouldCompare = [[NSMutableArray alloc] init];
    NSMutableArray *modifiedSelections = [[NSMutableArray alloc] init];

    [sortedRanges enumerateObjectsUsingBlock:^(id obj,
                                               NSUInteger idx,
                                               BOOL *stop)
     {
         [shouldCompare addObject:@YES];
         [modifiedSelections addObject:@NO];
     }];

    [sortedRanges enumerateObjectsWithOptions:0 usingBlock:^(CATSelectionRange *selectionRange1,
                                                             NSUInteger idx,
                                                             BOOL *stop)
     {
         if (![shouldCompare[idx] boolValue])
         {
             return;
         }

         NSRange range1 = [selectionRange1 range];

         __block NSRange rangeToAdd = range1;
         __block BOOL shouldAdd = YES;

         [sortedRanges enumerateObjectsWithOptions:0 usingBlock:^(CATSelectionRange *selectionRange2, NSUInteger idx2, BOOL *stop2)
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
                      self.cat_rangeInProgress = [CATSelectionRange selectionWithRange:rangeToAdd];
                  }
              }
          }];

         [reducedRanges enumerateObjectsUsingBlock:^(CATSelectionRange *selectionRange2, NSUInteger idx, BOOL *stop)
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
             [reducedRanges addObject:[CATSelectionRange selectionWithRange:rangeToAdd]];
         }
         else if (shouldAdd && !modifiedSelection)
         {
             [reducedRanges addObject:[[CATSelectionRange alloc] initWithSelectionRange:rangeToAdd
                                                                  intralineDesiredIndex:selectionRange1.intralineDesiredIndex]];
         }
     }];
    
    return [[NSArray alloc] initWithArray:reducedRanges];
}

- (NSArray *)prepareRanges:(NSArray *)ranges
{
    NSArray *sortedRanges = [self cat_sortRanges:ranges];
    NSArray *reducedRanges = [self cat_reduceSortedRanges:sortedRanges];

    return reducedRanges;
}

- (void)cat_setSelectedRanges:(NSArray *)ranges finalize:(BOOL)finalized
{
    ranges = [self prepareRanges:ranges];

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

    [ranges enumerateObjectsUsingBlock:^(CATSelectionRange *selectionRange, NSUInteger idx, BOOL *stop)
     {
         if (idx == 0)
         {
             NSRange range = [selectionRange range];
             self.selectedRange = range;
         }
         else
         {
             *stop = YES;
         }
     }];

    DVTTextStorage *textStorage = (DVTTextStorage *)self.textStorage;
    NSColor *backgroundColor = textStorage.fontAndColorTheme.sourceTextBackgroundColor;

    [self.layoutManager addTemporaryAttribute:NSBackgroundColorAttributeName value:backgroundColor forCharacterRange:NSMakeRange(0, [textStorage.string length])];

    [self.cat_selectionViews enumerateKeysAndObjectsUsingBlock:^(CATSelectionRange *value,
                                                                 NSView *view,
                                                                 BOOL *stop)
     {
         [view removeFromSuperview];
     }];

    self.cat_selectionViews =
    ({
        DVTTextStorage *textStorage = (DVTTextStorage *)self.textStorage;
        NSMutableDictionary *selectionViews = [[NSMutableDictionary alloc] init];

        [[self cat_effectiveSelectedRanges] enumerateObjectsUsingBlock:^(CATSelectionRange *selectionRange, NSUInteger idx, BOOL *stop)
         {
             NSRange range = [selectionRange range];

             NSRange rangeToDraw = range;

             if (range.length > 0)
             {
                 rangeToDraw = NSMakeRange(range.location + range.length, 0);

                 DVTTextStorage *textStorage = (DVTTextStorage *)self.textStorage;
                 NSColor *backgroundColor = textStorage.fontAndColorTheme.sourceTextSelectionColor;

                 [self.layoutManager addTemporaryAttribute:NSBackgroundColorAttributeName value:backgroundColor forCharacterRange:range];
             }

             CGRect lineLocation = [self.layoutManager lineFragmentRectForGlyphAtIndex:rangeToDraw.location effectiveRange:NULL];
             CGPoint location = [self.layoutManager locationForGlyphAtIndex:rangeToDraw.location];

             NSView *view = [[NSView alloc] init];
             view.wantsLayer = YES;
             view.layer.backgroundColor = [textStorage.fontAndColorTheme.sourceTextInsertionPointColor CGColor];

             CGRect rect = CGRectMake(CGRectGetMinX(lineLocation) + location.x, CGRectGetMaxY(lineLocation) - CGRectGetHeight(lineLocation), 1.f, CGRectGetHeight(lineLocation));
             
             [self addSubview:view];
             
             selectionViews[[NSValue valueWithRect:rect]] = view;
         }];
        
        selectionViews;
    });
}

#pragma mark -
#pragma mark NSView

- (void)layout
{
    [self.cat_selectionViews enumerateKeysAndObjectsUsingBlock:^(NSValue *vRect,
                                                                 NSView *view,
                                                                 BOOL *stop)
     {
         CGRect rect = [vRect CGRectValue];
         view.frame = rect;
     }];
    
    [super layout];
}

@end
