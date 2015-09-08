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

- (NSUInteger)locationForSelection:(MPXSelection *)selection movedFromLine:(NSRange)fromLine toLine:(NSRange)toLine
{
    NSUInteger indexWantedWithinLine = selection.indexWantedWithinLine;

    if (indexWantedWithinLine == MPXNoStoredLineIndex) {
        indexWantedWithinLine = selection.insertionIndex - fromLine.location;
    }

    if (toLine.length > indexWantedWithinLine) {
        return toLine.location + indexWantedWithinLine;
    }

    return NSMaxRange(toLine) - 1;
}

- (MPXSelection *)selection:(MPXSelection *)selection movedFromLine:(NSRange)fromLine toLine:(NSRange)toLine
{
    NSUInteger indexWantedWithinLine = selection.indexWantedWithinLine;

    if (indexWantedWithinLine == MPXNoStoredLineIndex) {
        indexWantedWithinLine = selection.insertionIndex - fromLine.location;
    }

    NSUInteger location = [self locationForSelection:selection movedFromLine:fromLine toLine:toLine];

    if (toLine.length > indexWantedWithinLine) {
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
        return [self selection:selection movedFromLine:lineRange toLine:lineAboveRange];
    }];
}

- (void)moveUpAndModifySelection:(id)sender
{
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
        return [self selection:selection movedFromLine:lineRange toLine:lineBelowRange];
    }];
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

        NSUInteger location = [self locationForSelection:selection movedFromLine:lineRange toLine:lineBelowRange];
        NSRange range = [selection modifySelectionDownstreamByAmount:location - selection.insertionIndex];

        NSUInteger indexWantedWithinLine = selection.indexWantedWithinLine;
        if (indexWantedWithinLine == MPXNoStoredLineIndex) {
            indexWantedWithinLine = selection.insertionIndex - lineRange.location;
        }

        return [[MPXSelection alloc] initWithSelectionRange:range
                                      indexWantedWithinLine:indexWantedWithinLine
                                                     origin:selection.origin];
    }];
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
                                                     origin:selection.origin];
    }];
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
    }];
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
                                                     origin:selection.origin];
    }];
}

- (void)moveForwardAndModifySelection:(id)sender
{
    [self moveRightAndModifySelection:sender];
}

- (void)moveRightAndModifySelection:(id)sender
{
    [self mpx_mapAndFinalizeSelectedRanges:^MPXSelection *(MPXSelection *selection) {
        return [[MPXSelection alloc] initWithSelectionRange:[selection modifySelectionDownstreamByAmount:1]
                                      indexWantedWithinLine:MPXNoStoredLineIndex
                                                     origin:selection.origin];
    }];
}

@end
