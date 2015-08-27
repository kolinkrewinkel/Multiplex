//
//  DVTSourceTextView+MPXEditorClipboardSupport.m
//  Multiplex
//
//  Created by Kolin Krewinkel on 8/26/15.
//  Copyright © 2015 Kolin Krewinkel. All rights reserved.
//

@import JRSwizzle;
@import MPXSelectionCore;

#import <DVTKit/DVTLayoutManager.h>
#import <DVTKit/DVTTextStorage.h>

#import "DVTSourceTextView+MPXEditorExtensions.h"

#import "DVTSourceTextView+MPXSwizzling.h"

@implementation DVTSourceTextView (MPXSwizzling)

- (void)mpx_offsetSelectionsDefaultingLengthsToZero:(NSInteger)amount modifySelection:(BOOL)modifySelection
{
    [self mpx_mapAndFinalizeSelectedRanges:^MPXSelection *(MPXSelection *selection) {
         NSRange existingRange = selection.range;

         // Start the new range from the existing point, resetting the length to 0.
         NSRange newRange = existingRange;
         newRange.length = 0;

         // Push the range forward or move it backwards.
         if (amount > 0) {
             newRange.location = NSMaxRange(existingRange) + amount;
         } else {
             newRange.location = existingRange.location + amount;
         }

         // Validate the range at the edges
         if (newRange.location == NSUIntegerMax) {
             newRange.location = 0;
         } else if (newRange.location > [self.textStorage length]) {
             newRange.location = self.textStorage.length - 1;
         }

         // The selection should reach out and touch where it originated from.
         if (modifySelection) {
             newRange = NSUnionRange(existingRange, newRange);
         }

         return [MPXSelection selectionWithRange:newRange];
     }];
}

- (void)moveLeft:(id)sender
{
    [self mpx_moveLeftModifyingSelection:NO];
}

- (void)moveLeftAndModifySelection:(id)sender
{
    [self mpx_moveLeftModifyingSelection:YES];
}

- (void)mpx_moveLeftModifyingSelection:(BOOL)modifySelection
{
    [self mpx_offsetSelectionsDefaultingLengthsToZero:-1 modifySelection:modifySelection];
}

- (void)moveRight:(id)sender
{
    [self mpx_moveRightModifyingSelection:NO];
}

- (void)moveRightAndModifySelection:(id)sender
{
    [self mpx_moveRightModifyingSelection:YES];
}

- (void)mpx_moveRightModifyingSelection:(BOOL)modifySelection
{
    [self mpx_offsetSelectionsDefaultingLengthsToZero:1 modifySelection:modifySelection];
}

#pragma mark Up and Down/Line-Movements

- (void)mpx_shiftSelectionLineWithRelativePosition:(CATRelativePosition)position
                                modifyingSelection:(BOOL)modifySelection
{
    NSCAssert(position != CATRelativePositionLeft, @"Use beginning/end of line methods.");
    NSCAssert(position != CATRelativePositionRight, @"Use beginning/end of line methods.");

    DVTLayoutManager *layoutManager = self.layoutManager;

    [self mpx_mapAndFinalizeSelectedRanges:^MPXSelection *(MPXSelection *selection) {
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
         if (selection.interLineDesiredIndex != previousRelativeIndex
             && selection.interLineDesiredIndex != NSNotFound) {
             previousRelativeIndex = selection.interLineDesiredIndex;
         }

         // The selection is in the first/zero-th line, so there is no above line to find.
         // Sublime Text and OS X behavior is to jump to the start of the document.
         if (previousLineRange.location == 0 && position == CATRelativePositionTop) {
             return [MPXSelection selectionWithRange:NSMakeRange(0, 0)];
         } else if (NSMaxRange(previousLineRange) == self.textStorage.length && position == CATRelativePositionBottom) {
             return [MPXSelection selectionWithRange:NSMakeRange(self.textStorage.length, 0)];
         }

         NSRange newLineRange = ({
             NSRange range;

             if (position == CATRelativePositionTop) {
                 [layoutManager lineFragmentRectForGlyphAtIndex:previousLineRange.location - 1
                                                 effectiveRange:&range];
             } else {
                 [layoutManager lineFragmentRectForGlyphAtIndex:NSMaxRange(previousLineRange)
                                                 effectiveRange:&range];
             }

             range;
         });

         // The line is long enough to show at the original relative-index
         if (newLineRange.length > previousRelativeIndex) {
             NSUInteger desiredPosition = newLineRange.location + previousRelativeIndex;

             NSRange newAbsoluteRange = NSMakeRange(desiredPosition, 0);
             if (modifySelection) {
                 newAbsoluteRange = NSUnionRange(previousAbsoluteRange, newAbsoluteRange);
             }

             return [MPXSelection selectionWithRange:newAbsoluteRange];
         }

         NSRange newAbsoluteRange = NSMakeRange(NSMaxRange(newLineRange) - 1, 0);
         if (modifySelection) {
             newAbsoluteRange = NSUnionRange(previousAbsoluteRange, newAbsoluteRange);
         }

         // This will place it at the end of the line, aiming to be placed at the original position.
         return [[MPXSelection alloc] initWithSelectionRange:newAbsoluteRange
                                       interLineDesiredIndex:previousRelativeIndex
                                                      origin:newAbsoluteRange.location];
     }];
}

- (void)mpx_moveSelectionsUpModifyingSelection:(BOOL)modifySelection
{
    [self mpx_shiftSelectionLineWithRelativePosition:CATRelativePositionTop
                                  modifyingSelection:modifySelection];
}

- (void)mpx_moveSelectionsDownModifyingSelection:(BOOL)modifySelection
{
    [self mpx_shiftSelectionLineWithRelativePosition:CATRelativePositionBottom
                                  modifyingSelection:modifySelection];
}

#pragma mark - Directional Movemnts

- (void)moveUp:(id)sender
{
    [self mpx_moveSelectionsUpModifyingSelection:NO];
}

- (void)moveUpAndModifySelection:(id)sender
{
    [self mpx_moveSelectionsUpModifyingSelection:YES];
}

- (void)moveDown:(id)sender
{
    [self mpx_moveSelectionsDownModifyingSelection:NO];
}

- (void)moveDownAndModifySelection:(id)sender
{
    [self mpx_moveSelectionsDownModifyingSelection:YES];
}

#pragma mark - Semantic Movements

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

@end
