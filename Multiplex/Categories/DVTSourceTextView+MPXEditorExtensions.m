//
//  IDESourceCodeEditor+CATViewReplacement.m
//  Multiplex
//
//  Created by Kolin Krewinkel on 9/25/14.
//  Copyright (c) 2014 Kolin Krewinkel. All rights reserved.
//

@import MPXFoundation;
@import MPXSelectionCore;
@import QuartzCore;
@import JRSwizzle;

#import <DVTKit/DVTTextStorage.h>
#import <DVTKit/DVTLayoutManager.h>
#import <DVTKit/DVTFontAndColorTheme.h>
#import <DVTKit/DVTFoldingManager.h>
#import <DVTKit/DVTUndoManager.h>

#import "DVTSourceTextView+MPXEditorExtensions.h"

@implementation DVTSourceTextView (MPXEditorExtensions)

@synthesizeAssociation(DVTSourceTextView, mpx_inUndoGroup);
@synthesizeAssociation(DVTSourceTextView, mpx_shouldCloseGroupOnNextChange);
@synthesizeAssociation(DVTSourceTextView, mpx_selectionManager);
@synthesizeAssociation(DVTSourceTextView, mpx_definitionLongPressTimer);
@synthesizeAssociation(DVTSourceTextView, mpx_textViewSelectionDecorator);

@synthesizeAssociation(DVTSourceTextView, mpx_rangeInProgressStart);
@synthesizeAssociation(DVTSourceTextView, mpx_rangeInProgress);

#pragma mark - Initializer

- (void)mpx_commonInitDVTSourceTextView
{
    [self mpx_commonInitDVTSourceTextView];

    self.mpx_textViewSelectionDecorator = [[MPXTextViewSelectionDecorator alloc] initWithTextView:self];

    self.mpx_selectionManager = [[MPXSelectionManager alloc] initWithTextView:self];
    self.mpx_selectionManager.visualizationDelegate = self.mpx_textViewSelectionDecorator;

    self.mpx_rangeInProgress = [MPXSelection selectionWithRange:NSMakeRange(NSNotFound, 0)];
    self.mpx_rangeInProgressStart = [MPXSelection selectionWithRange:NSMakeRange(NSNotFound, 0)];

    self.selectedTextAttributes = @{};
}

- (void)undo:(id)sender
{
    if (self.mpx_inUndoGroup) {
        self.mpx_inUndoGroup = NO;
        [self.undoManager endUndoGrouping];
    }

    [self.undoManager undoNestedGroup];
}

#pragma mark - NSView

- (void)mpx_viewWillMoveToWindow:(NSWindow *)window
{
    [self mpx_viewWillMoveToWindow:window];

    // Observe the window's state while the view resides in it
    if (window) {
        [[NSNotificationCenter defaultCenter] addObserver:self.mpx_textViewSelectionDecorator selector:@selector(startBlinking) name:NSWindowDidBecomeKeyNotification object:window];
        [[NSNotificationCenter defaultCenter] addObserver:self.mpx_textViewSelectionDecorator selector:@selector(stopBlinking) name:NSWindowDidResignKeyNotification object:window];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidBecomeKeyNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResignKeyNotification object:nil];
    }
}

#pragma mark - Cursors

- (BOOL)isSelectable
{
    return YES;
}

#pragma mark - Keyboard Events

- (void)insertText:(id)insertObject
{
    // Prevents random stuff being thrown in.
    if (![insertObject isKindOfClass:[NSString class]]) {
        return;
    }

    if (self.mpx_shouldCloseGroupOnNextChange && self.mpx_inUndoGroup) {
        self.mpx_inUndoGroup = NO;
        [self.undoManager endUndoGrouping];
        self.mpx_shouldCloseGroupOnNextChange = NO;
    }


    if (!self.mpx_inUndoGroup) {
        self.mpx_inUndoGroup = YES;

        [self.undoManager beginUndoGrouping];

        NSArray *currState = self.mpx_selectionManager.finalizedSelections;
        [self.undoManager registerUndoWithTarget:self handler:^(id  _Nonnull target) {
            self.mpx_selectionManager.finalizedSelections = currState;
            [self.mpx_textViewSelectionDecorator startBlinking];
        }];
    }

    NSString *insertString = (NSString *)insertObject;

    // Sequential (negative) offset of characters added.
    __block NSInteger totalDelta = 0;
    [self mpx_mapAndFinalizeSelectedRanges:^MPXSelection *(MPXSelection *selection) {
        NSRange range = selection.range;
        NSUInteger insertStringLength = [insertString length];

        // Offset by the previous mutations made (+/- doesn't matter, as long as the different maths at each point correspond to the relative offset made by inserting a # of chars.)
        NSRange offsetRange = NSMakeRange(range.location + totalDelta, range.length);

        [self.textStorage replaceCharactersInRange:offsetRange withString:insertString withUndoManager:self.undoManager];

        // Offset the following ones by noting the original length and updating for the replacement's length, moving cursors following forward/backward.
        NSInteger delta = range.length - insertStringLength;
        totalDelta -= delta;

        NSRange lineRange;
        (void)[self.layoutManager lineFragmentRectForGlyphAtIndex:NSMaxRange(offsetRange) effectiveRange:&lineRange];

        NSUInteger relativeLinePosition = selection.interLineDesiredIndex;

        if (relativeLinePosition == NSNotFound)
        {
            relativeLinePosition = NSMaxRange(offsetRange) - lineRange.location;
        }

        // Move cursor (or range-selection) to the end of what was just added with 0-length.
        NSRange newInsertionPointRange = NSMakeRange(offsetRange.location + insertStringLength, 0);
        return [[MPXSelection alloc] initWithSelectionRange:newInsertionPointRange
                                      interLineDesiredIndex:relativeLinePosition
                                                     origin:newInsertionPointRange.location];
    } sequentialModification:YES];

    [self.mpx_textViewSelectionDecorator startBlinking];
}

- (void)deleteBackward:(id)sender
{
    // Sequential (negative) offset of characters added.
    __block NSInteger totalDelta = 0;

    [self mpx_mapAndFinalizeSelectedRanges:^MPXSelection *(MPXSelection *selection) {
        // Update the base range with the delta'd amount of change from previous mutations.
        NSRange range = [selection range];
        NSRange offsetRange = NSMakeRange(range.location + totalDelta, range.length);

        NSRange deletingRange = NSMakeRange(0, 0);
        if (offsetRange.length == 0) {
            deletingRange = NSMakeRange(offsetRange.location - 1, 1);
        } else {
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

    [self mpx_mapAndFinalizeSelectedRanges:^MPXSelection *(MPXSelection *selection) {
        NSRange range = selection.range;

        [textStorage indentAtBeginningOfLineForCharacterRange:range undoManager:undoManager];

        NSLayoutManager *layoutManager = [self layoutManager];
        NSRange lineRange;
        NSUInteger desiredIndex = [layoutManager glyphIndexForCharacterAtIndex:NSMaxRange(range)];
        NSUInteger lineNumber = 0;
        NSUInteger numberOfLines = 0;

        for (NSUInteger index = 0; index < [layoutManager numberOfGlyphs]; numberOfLines++) {
            (void)[layoutManager lineFragmentRectForGlyphAtIndex:index effectiveRange:&lineRange];

            if (desiredIndex >= lineRange.location && desiredIndex <= NSMaxRange(lineRange)) {
                lineNumber = numberOfLines;
                break;
            }

            index = NSMaxRange(lineRange);
        }

        NSUInteger firstNonBlank = [textStorage firstNonblankForLine:lineNumber + 1 convertTabs:YES];

        NSRange effectiveRange;
        (void)[self.layoutManager lineFragmentRectForGlyphAtIndex:desiredIndex
                                                   effectiveRange:&effectiveRange];
        return [MPXSelection selectionWithRange:NSMakeRange(effectiveRange.location + firstNonBlank, 0)];
    }];
}

#pragma mark Scrolling

- (void)centerSelectionInVisibleArea:(id)sender
{
}

#pragma mark - Mouse Events

- (void)mpx_mouseDragged:(NSEvent *)theEvent
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(mpx_performOriginalJump:) object:nil];

    [self.mpx_textViewSelectionDecorator stopBlinking];

    NSRange rangeInProgress = self.mpx_rangeInProgress.range;
    NSRange rangeInProgressOrigin = self.mpx_rangeInProgressStart.range;

    if (rangeInProgress.location == NSNotFound || rangeInProgressOrigin.location == NSNotFound) {
        return;
    }

    CGPoint clickLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSUInteger index = [self characterIndexForInsertionAtPoint:clickLocation];
    NSRange newRange;

    if (index > rangeInProgressOrigin.location) {
        newRange = NSMakeRange(rangeInProgressOrigin.location, index - rangeInProgressOrigin.location);
    } else {
        newRange = NSMakeRange(index, (rangeInProgressOrigin.location + rangeInProgressOrigin.length) - index);
    }

    // Update the model value for when it is used combinatorily.
    self.mpx_rangeInProgress = [MPXSelection selectionWithRange:newRange];

    [self.mpx_selectionManager setTemporarySelections:[self.mpx_selectionManager.finalizedSelections arrayByAddingObject:[MPXSelection selectionWithRange:newRange]]];
}

- (void)mpx_performOriginalJump:(NSTimer *)sender
{
    NSEvent *mouseDownEvent = sender.userInfo;
    if (!CGPointEqualToPoint(self.window.mouseLocationOutsideOfEventStream, [mouseDownEvent locationInWindow])) {
        return;     
    }

    [self.mpx_selectionManager setTemporarySelections:nil];
    self.mpx_rangeInProgress = [MPXSelection selectionWithRange:NSMakeRange(NSNotFound, 0)];
    self.mpx_rangeInProgressStart = [MPXSelection selectionWithRange:NSMakeRange(NSNotFound, 0)];

    [self _didClickOnTemporaryLinkWithEvent:mouseDownEvent];
}

- (void)mpx_mouseDown:(NSEvent *)theEvent
{
    NSUInteger index = ({
        CGPoint clickLocation = [self convertPoint:[theEvent locationInWindow]
                                          fromView:nil];
        [self characterIndexForInsertionAtPoint:clickLocation];
    });

    if (index == NSNotFound) {
        return;
    }

    NSInteger clickCount = theEvent.clickCount;
    BOOL commandKeyHeld = (theEvent.modifierFlags & NSCommandKeyMask) != 0;

    NSArray *selections = self.mpx_selectionManager.visualSelections;
    NSRange resultRange = NSMakeRange(NSNotFound, 0);
    DVTTextStorage *textStorage = (DVTTextStorage *)self.textStorage;

    switch (clickCount) {
            // Selects only the single point at the approximate location of the cursor
        case 1:
            resultRange = NSMakeRange(index, 0);
            break;
        case 2: {
            if ([((DVTLayoutManager *)self.layoutManager).foldingManager firstFoldTouchingCharacterIndex:index]) {
                [self mpx_mouseDown:theEvent];
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

    if (resultRange.location == NSNotFound) {
        return;
    }

    [self.mpx_textViewSelectionDecorator stopBlinking];
    [self.mpx_textViewSelectionDecorator setCursorsVisible:YES];

    MPXSelection *selection = [MPXSelection selectionWithRange:resultRange];
    self.mpx_rangeInProgress = selection;
    self.mpx_rangeInProgressStart = selection;

    if (commandKeyHeld) {
        [self.mpx_selectionManager setTemporarySelections:[selections arrayByAddingObject:selection]];

        self.mpx_definitionLongPressTimer = [NSTimer timerWithTimeInterval:0.333
                                                                    target:self
                                                                  selector:@selector(mpx_performOriginalJump:)
                                                                  userInfo:theEvent
                                                                   repeats:NO];

        [[NSRunLoop mainRunLoop] addTimer:self.mpx_definitionLongPressTimer forMode:NSDefaultRunLoopMode];
    } else {
        // Because the click was singular, the other selections will *not* come back under any circumstances.
        // Thus, it must be finalized at the point where it's at is if it's a zero-length selection.
        // Otherwise, they'll be re-added during dragging.
        self.mpx_selectionManager.finalizedSelections = @[selection];

        self.mpx_shouldCloseGroupOnNextChange = YES;

        // In the event the user drags, however, it needs to unfinalized so that it can be extended again.
        [self.mpx_selectionManager setTemporarySelections:@[selection]];
    }
}

- (void)mpx_mouseUp:(NSEvent *)theEvent
{
    [self.mpx_definitionLongPressTimer invalidate];

    self.mpx_selectionManager.finalizedSelections = self.mpx_selectionManager.visualSelections;
    self.mpx_rangeInProgress = [MPXSelection selectionWithRange:NSMakeRange(NSNotFound, 0)];
    self.mpx_rangeInProgressStart = [MPXSelection selectionWithRange:NSMakeRange(NSNotFound, 0)];

    [self.mpx_textViewSelectionDecorator startBlinking];
}

#pragma mark - Range Manipulation

- (void)selectAll:(id)sender
{
    self.mpx_selectionManager.finalizedSelections = @[[MPXSelection selectionWithRange:NSMakeRange(0, [self.textStorage.string length])]];
}

- (void)mpx_mapAndFinalizeSelectedRanges:(MPXSelection * (^)(MPXSelection *selection))mapBlock
{
    [self mpx_mapAndFinalizeSelectedRanges:mapBlock sequentialModification:NO];
}

- (void)mpx_mapAndFinalizeSelectedRanges:(MPXSelection * (^)(MPXSelection *selection))mapBlock
                  sequentialModification:(BOOL)sequentialModification
{
    NSArray *mappedValues = [[[self.mpx_selectionManager.visualSelections rac_sequence] map:mapBlock] array];
    self.mpx_selectionManager.finalizedSelections = mappedValues;

    [self.mpx_textViewSelectionDecorator startBlinking];
}

- (void)_drawInsertionPointInRect:(CGRect)rect color:(NSColor *)color
{

}

@end
