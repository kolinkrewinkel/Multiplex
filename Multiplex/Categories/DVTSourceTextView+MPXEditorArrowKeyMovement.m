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

#import "DVTSourceTextView+MPXEditorArrowKeyMovement.h"

@implementation DVTSourceTextView (MPXEditorArrowKeyMovement)

- (void)mpx_moveLeftModifyingSelection:(BOOL)modifySelection
{
    [self mpx_mapAndFinalizeSelectedRanges:^MPXSelection *(MPXSelection *selection) {
        NSRange existingRange = selection.range;

        // Ensure the location is positive/rational.
        NSUInteger newLocation = existingRange.location > 0 ? existingRange.location - 1 : 0;
        NSRange newRange = NSMakeRange(newLocation, 0);

        // The selection should reach out and touch where it originated from.
        if (modifySelection) {
            switch (selection.selectionAffinity) {
                case NSSelectionAffinityUpstream:
                    newRange = NSMakeRange(existingRange.location - 1, existingRange.length + 1);
                    break;
                case NSSelectionAffinityDownstream:

                    if (existingRange.length > 0) {
                        newRange = NSMakeRange(existingRange.location, existingRange.length - 1);
                    } else {
                        newRange = NSMakeRange(existingRange.location - 1, existingRange.length + 1);
                    }

                    break;
            }


        }

        return [[MPXSelection alloc] initWithSelectionRange:newRange
                                      indexWantedWithinLine:selection.origin
                                                     origin:selection.origin];
    }];
}

- (void)mpx_moveRightModifyingSelection:(BOOL)modifySelection
{
    [self mpx_mapAndFinalizeSelectedRanges:^MPXSelection *(MPXSelection *selection) {
        NSRange existingRange = selection.range;

        NSRange newRange = NSMakeRange(existingRange.location + 1, 0);

        if (modifySelection) {
            switch (selection.selectionAffinity) {
                case NSSelectionAffinityUpstream:
                    newRange = NSMakeRange(existingRange.location + 1, existingRange.length - 1);
                    break;
                case NSSelectionAffinityDownstream:
                    newRange = NSMakeRange(existingRange.location, existingRange.length + 1);
                    break;
            }
        }

        return [[MPXSelection alloc] initWithSelectionRange:newRange
                                      indexWantedWithinLine:selection.origin
                                                     origin:selection.origin];
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

- (void)moveRight:(id)sender
{
    [self mpx_moveRightModifyingSelection:NO];
}

- (void)moveRightAndModifySelection:(id)sender
{
    [self mpx_moveRightModifyingSelection:YES];
}

#pragma mark Up and Down/Line-Movements

- (void)mpx_shiftSelectionLineWithSelectionAffinity:(NSSelectionAffinity)selectionAffinity
                                 modifyingSelection:(BOOL)modifySelection
{
    DVTLayoutManager *layoutManager = self.layoutManager;

    [self mpx_mapAndFinalizeSelectedRanges:^MPXSelection *(MPXSelection *selection) {
        // "Previous" refers exclusively to time, not location.
        NSRange previousAbsoluteRange = selection.range;

        NSUInteger locationToMoveLineFrom = selection.insertionIndex;

        // You can't move down a line from the end of the text.
        // We don't bother calculating the line range to save time and to avoid spreading the special logic because the
        // max of the selection is at an index that is technically beyond the *existing contents* of the text storage.
        if (locationToMoveLineFrom == self.textStorage.length
            && selectionAffinity == NSSelectionAffinityDownstream) {
            return [MPXSelection selectionWithRange:NSMakeRange(locationToMoveLineFrom, 0)];
        }

        // Effective range is used because lineRangeForRange does not handle the custom linebreaking/word-wrapping that the text view does.
        NSRange previousLineRange;
        NSUInteger glyphIndex = [layoutManager glyphIndexForCharacterAtIndex:locationToMoveLineFrom];

        if (glyphIndex == [layoutManager numberOfGlyphs]) {
            if (layoutManager.extraLineFragmentTextContainer) {
                NSRange newLineRange;
                NSUInteger glyphIndex = [layoutManager glyphIndexForCharacterAtIndex:locationToMoveLineFrom - 1];
                [layoutManager lineFragmentRectForGlyphAtIndex:glyphIndex effectiveRange:&newLineRange];

                return [[MPXSelection alloc] initWithSelectionRange:NSMakeRange(newLineRange.location, 0)
                                              indexWantedWithinLine:selection.indexWantedWithinLine
                                                             origin:locationToMoveLineFrom];
            } else {
                glyphIndex--;
            }
        }

        [layoutManager lineFragmentRectForGlyphAtIndex:glyphIndex effectiveRange:&previousLineRange];

        // The index of the selection relative to the start of the line in the entire string
        NSUInteger previousRelativeIndex = locationToMoveLineFrom - previousLineRange.location;

        // Where the cursor is placed is not where it originally came from, so we should aim to place it there.
        if (selection.indexWantedWithinLine != previousRelativeIndex
            && selection.indexWantedWithinLine != NSNotFound) {
            previousRelativeIndex = selection.indexWantedWithinLine;
        }

        // The selection is in the first/zero-th line, so there is no above line to find.
        // Sublime Text and OS X behavior is to jump to the start of the document.
        if (previousLineRange.location == 0 && selectionAffinity == NSSelectionAffinityUpstream) {
            return [MPXSelection selectionWithRange:NSMakeRange(0, 0)];
        } else if (NSMaxRange(previousLineRange) == self.textStorage.length
                   && selectionAffinity == NSSelectionAffinityDownstream) {
            return [MPXSelection selectionWithRange:NSMakeRange(self.textStorage.length, 0)];
        }

        NSRange newLineRange = ({
            NSRange range;

            if (selectionAffinity == NSSelectionAffinityUpstream) {
                NSUInteger glyphIndex = [layoutManager glyphIndexForCharacterAtIndex:previousLineRange.location - 1];
                [layoutManager lineFragmentRectForGlyphAtIndex:glyphIndex
                                                effectiveRange:&range];
            } else {
                NSUInteger glyphIndex = [layoutManager glyphIndexForCharacterAtIndex:NSMaxRange(previousLineRange)];
                [layoutManager lineFragmentRectForGlyphAtIndex:glyphIndex
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

            return [[MPXSelection alloc] initWithSelectionRange:newAbsoluteRange
                                          indexWantedWithinLine:previousRelativeIndex
                                                         origin:selection.origin];
        }

        NSRange newAbsoluteRange = NSMakeRange(NSMaxRange(newLineRange) - 1, 0);
        if (modifySelection) {
            if (selectionAffinity == NSSelectionAffinityUpstream) {
                newAbsoluteRange = NSMakeRange(newLineRange.location, NSMaxRange(previousAbsoluteRange) - newLineRange.location);
            } else {

            }
        }

        // This will place it at the end of the line, aiming to be placed at the original position.
        return [[MPXSelection alloc] initWithSelectionRange:newAbsoluteRange
                                      indexWantedWithinLine:previousRelativeIndex
                                                     origin:selection.origin];
    }];
}

- (void)mpx_moveSelectionsUpModifyingSelection:(BOOL)modifySelection
{
    [self mpx_shiftSelectionLineWithSelectionAffinity:NSSelectionAffinityUpstream
                                   modifyingSelection:modifySelection];
}

- (void)mpx_moveSelectionsDownModifyingSelection:(BOOL)modifySelection
{
    [self mpx_shiftSelectionLineWithSelectionAffinity:NSSelectionAffinityDownstream
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
