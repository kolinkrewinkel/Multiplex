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

#pragma mark - Convenience

static NSUInteger MPXLocationForSelection(MPXSelection *selection, NSRange fromLineRange, NSRange toLineRange)
{
    NSUInteger indexWantedWithinLine = selection.indexWantedWithinLine;

    // If a previously stored index doesn't exist, get its position within the line.
    if (indexWantedWithinLine == MPXNoStoredLineIndex) {
        indexWantedWithinLine = selection.insertionIndex - fromLineRange.location;
    }

    // Only try and place it within the line if it can fit within the new line's length.
    if (toLineRange.length > indexWantedWithinLine) {
        return toLineRange.location + indexWantedWithinLine;
    }

    // Default to showing it at the end of the line.
    return NSMaxRange(toLineRange) - 1;
}

static MPXSelection *MPXSelectionMove(MPXSelection *selection, NSRange fromLineRange, NSRange toLineRange)
{
    NSUInteger indexWantedWithinLine = selection.indexWantedWithinLine;

    if (indexWantedWithinLine == MPXNoStoredLineIndex) {
        indexWantedWithinLine = selection.insertionIndex - fromLineRange.location;
    }

    NSUInteger location = MPXLocationForSelection(selection, fromLineRange, toLineRange);
    if (toLineRange.length > indexWantedWithinLine) {
        return [[MPXSelection alloc] initWithSelectionRange:NSMakeRange(location, 0)
                                      indexWantedWithinLine:MPXNoStoredLineIndex
                                                     origin:location];
    }

    return [[MPXSelection alloc] initWithSelectionRange:NSMakeRange(location, 0)
                                  indexWantedWithinLine:indexWantedWithinLine
                                                 origin:location];
}

- (NSRange)lineRangeForCharacterIndex:(NSUInteger)characterIndex
{
    NSUInteger glyphIndex = [self.layoutManager glyphIndexForCharacterAtIndex:characterIndex];

    NSRange lineRange;
    [self.layoutManager lineFragmentRectForGlyphAtIndex:glyphIndex effectiveRange:&lineRange];

    return lineRange;
}

#pragma mark - Directional Movemnts

- (void)moveUp:(id)sender
{
    [self mpx_mapAndFinalizeSelectedRanges:^MPXSelection *(MPXSelection *selection) {
        NSRange lineRange = [self lineRangeForCharacterIndex:selection.insertionIndex];

        if (lineRange.location == 0) {
            NSRange newRange = NSMakeRange(0, 0);
            return [[MPXSelection alloc] initWithSelectionRange:newRange
                                          indexWantedWithinLine:MPXNoStoredLineIndex
                                                         origin:newRange.location];
        }

        NSRange lineAboveRange = [self lineRangeForCharacterIndex:lineRange.location - 1];
        return MPXSelectionMove(selection, lineRange, lineAboveRange);
    } sequentialModification:YES modifyingExistingSelections:NO movementDirection:NSSelectionAffinityUpstream];
}

- (void)moveUpAndModifySelection:(id)sender
{
    [self mpx_mapAndFinalizeSelectedRanges:^MPXSelection *(MPXSelection *selection) {
        if (selection.insertionIndex == 0) {
            return selection;
        }

        NSRange lineRange = [self lineRangeForCharacterIndex:selection.insertionIndex];
        NSUInteger beginningOfLine = lineRange.location;

        if (beginningOfLine == 0) {
            NSRange newRange = [selection modifySelectionUpstreamByAmount:selection.insertionIndex];
            return [[MPXSelection alloc] initWithSelectionRange:newRange
                                          indexWantedWithinLine:0
                                                         origin:selection.origin];
        }

        NSRange lineAboveRange = [self lineRangeForCharacterIndex:beginningOfLine - 1];

        NSUInteger location = MPXLocationForSelection(selection, lineRange, lineAboveRange);
        NSRange range = [selection modifySelectionUpstreamByAmount:selection.insertionIndex - location];

        NSUInteger indexWantedWithinLine = selection.indexWantedWithinLine;
        if (indexWantedWithinLine == MPXNoStoredLineIndex) {
            indexWantedWithinLine = selection.insertionIndex - lineRange.location;
        }

        return [[MPXSelection alloc] initWithSelectionRange:range
                                      indexWantedWithinLine:indexWantedWithinLine
                                                     origin:selection.origin];
    } sequentialModification:YES modifyingExistingSelections:YES movementDirection:NSSelectionAffinityUpstream];
}

- (void)moveDown:(id)sender
{
    [self mpx_mapAndFinalizeSelectedRanges:^MPXSelection *(MPXSelection *selection) {
        NSRange lineRange = [self lineRangeForCharacterIndex:selection.insertionIndex];
        NSUInteger endOfLine = NSMaxRange(lineRange);

        if (endOfLine == self.textStorage.length - 1) {
            NSRange newRange = NSMakeRange(endOfLine, 0);
            return [[MPXSelection alloc] initWithSelectionRange:newRange
                                          indexWantedWithinLine:MPXNoStoredLineIndex
                                                         origin:newRange.location];
        }

        NSRange lineBelowRange = [self lineRangeForCharacterIndex:endOfLine];
        return MPXSelectionMove(selection, lineRange, lineBelowRange);
    } sequentialModification:YES modifyingExistingSelections:NO movementDirection:NSSelectionAffinityDownstream];
}

- (void)moveDownAndModifySelection:(id)sender
{
    [self mpx_mapAndFinalizeSelectedRanges:^MPXSelection *(MPXSelection *selection) {
        if (selection.insertionIndex == self.textStorage.length) {
            return selection;
        }

        NSRange lineRange = [self lineRangeForCharacterIndex:selection.insertionIndex];
        NSUInteger endOfLine = NSMaxRange(lineRange);

        if (endOfLine == self.textStorage.length) {
            NSRange newRange = [selection modifySelectionDownstreamByAmount:endOfLine - selection.insertionIndex];
            return [[MPXSelection alloc] initWithSelectionRange:newRange
                                          indexWantedWithinLine:lineRange.length
                                                         origin:selection.origin];
        }

        NSRange lineBelowRange = [self lineRangeForCharacterIndex:endOfLine];

        NSUInteger location = MPXLocationForSelection(selection, lineRange, lineBelowRange);
        NSRange range = [selection modifySelectionDownstreamByAmount:location - selection.insertionIndex];

        NSUInteger indexWantedWithinLine = selection.indexWantedWithinLine;
        if (indexWantedWithinLine == MPXNoStoredLineIndex) {
            indexWantedWithinLine = selection.insertionIndex - lineRange.location;
        }

        return [[MPXSelection alloc] initWithSelectionRange:range
                                      indexWantedWithinLine:indexWantedWithinLine
                                                     origin:selection.origin];
    } sequentialModification:YES modifyingExistingSelections:YES movementDirection:NSSelectionAffinityDownstream];
}

#pragma mark - Left/Right Movements

- (void)moveBackward:(id)sender
{
    [self moveLeft:sender];
}

- (void)moveLeft:(id)sender
{
    [self mpx_mapAndFinalizeSelectedRanges:^MPXSelection *(MPXSelection *selection) {
        NSUInteger newIndex = MAX(selection.insertionIndex - 1, 0);
        return [[MPXSelection alloc] initWithSelectionRange:NSMakeRange(newIndex, 0)
                                      indexWantedWithinLine:selection.indexWantedWithinLine
                                                     origin:newIndex];
    } sequentialModification:YES modifyingExistingSelections:NO movementDirection:NSSelectionAffinityUpstream];
}

- (void)moveBackwardAndModifySelection:(id)sender
{
    [self moveLeftAndModifySelection:sender];
}

- (void)moveLeftAndModifySelection:(id)sender
{
    [self mpx_mapAndFinalizeSelectedRanges:^MPXSelection *(MPXSelection *selection) {
        return [[MPXSelection alloc] initWithSelectionRange:[selection modifySelectionUpstreamByAmount:1]
                                      indexWantedWithinLine:MPXNoStoredLineIndex
                                                     origin:selection.origin];
    } sequentialModification:YES modifyingExistingSelections:YES movementDirection:NSSelectionAffinityUpstream];
}

- (void)moveForward:(id)sender
{
    [self moveRight:sender];
}

- (void)moveRight:(id)sender
{
    [self mpx_mapAndFinalizeSelectedRanges:^MPXSelection *(MPXSelection *selection) {
        NSUInteger newIndex = MIN(selection.insertionIndex + 1, self.textStorage.length);
        return [[MPXSelection alloc] initWithSelectionRange:NSMakeRange(newIndex, 0)
                                      indexWantedWithinLine:selection.indexWantedWithinLine
                                                     origin:newIndex];
    } sequentialModification:YES modifyingExistingSelections:NO movementDirection:NSSelectionAffinityDownstream];
}

- (void)moveForwardAndModifySelection:(id)sender
{
    [self moveRightAndModifySelection:sender];
}

- (void)moveRightAndModifySelection:(id)sender
{
    [self mpx_mapAndFinalizeSelectedRanges:^MPXSelection *(MPXSelection *selection) {
        if (NSMaxRange(selection.range) == self.textStorage.length) {
            return selection;
        }

        NSRange newRange = [selection modifySelectionDownstreamByAmount:1];
        return [[MPXSelection alloc] initWithSelectionRange:newRange
                                      indexWantedWithinLine:MPXNoStoredLineIndex
                                                     origin:selection.origin];
    } sequentialModification:YES modifyingExistingSelections:YES movementDirection:NSSelectionAffinityDownstream];
}

@end
