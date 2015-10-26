//
//  DVTSourceTextView+MPXArrowKeyMovement.m
//  Multiplex
//
//  Created by Kolin Krewinkel on 8/26/15.
//  Copyright © 2015 Kolin Krewinkel. All rights reserved.
//

@import JRSwizzle;

#import <DVTKit/DVTLayoutManager.h>
#import <DVTKit/DVTTextStorage.h>

#import "DVTSourceTextView+MPXEditorExtensions.h"
#import "MPXSelection.h"
#import "MPXSelectionManager.h"
#import "MPXSelectionMutation.h"

#import "DVTSourceTextView+MPXArrowKeyMovement.h"

@implementation DVTSourceTextView (MPXArrowKeyMovement)

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
    MPXSelectionMutationBlock transformBlock = ^MPXSelectionMutation *(MPXSelection *selectionToModify) {
        NSRange lineRange = [self lineRangeForCharacterIndex:selectionToModify.insertionIndex];
        
        MPXSelection *newSelection = nil;
        if (lineRange.location == 0) {
            NSRange newRange = NSMakeRange(0, 0);
            newSelection = [[MPXSelection alloc] initWithSelectionRange:newRange
                                          indexWantedWithinLine:MPXNoStoredLineIndex
                                                         origin:newRange.location];
        } else {
            NSRange lineAboveRange = [self lineRangeForCharacterIndex:lineRange.location - 1];
            newSelection = MPXSelectionMove(selectionToModify, lineRange, lineAboveRange);
        }

        return [[MPXSelectionMutation alloc] initWithInitialSelection:selectionToModify
                                                       finalSelection:newSelection
                                                          mutatedText:NO];
    };
    
    [self.mpx_selectionManager mapSelectionsWithMovementDirection:NSSelectionAffinityUpstream
                                              modifyingSelections:NO
                                                       usingBlock:transformBlock];
}

- (void)moveUpAndModifySelection:(id)sender
{
    MPXSelectionMutationBlock transformBlock = ^MPXSelectionMutation *(MPXSelection *selection) {
        if (selection.insertionIndex == 0) {
            return [[MPXSelectionMutation alloc] initWithInitialSelection:selection
                                                           finalSelection:selection
                                                              mutatedText:NO];
        }

        NSRange lineRange = [self lineRangeForCharacterIndex:selection.insertionIndex];
        NSUInteger beginningOfLine = lineRange.location;
        
        if (beginningOfLine == 0) {
            NSRange newRange = [selection modifySelectionUpstreamByAmount:selection.insertionIndex];
            MPXSelection *newSelection = [[MPXSelection alloc] initWithSelectionRange:newRange
                                          indexWantedWithinLine:0
                                                         origin:selection.origin];

            return [[MPXSelectionMutation alloc] initWithInitialSelection:selection
                                                           finalSelection:newSelection
                                                              mutatedText:NO];
        }

        NSRange lineAboveRange = [self lineRangeForCharacterIndex:beginningOfLine - 1];
        
        NSUInteger location = MPXLocationForSelection(selection, lineRange, lineAboveRange);
        NSRange range = [selection modifySelectionUpstreamByAmount:selection.insertionIndex - location];
        
        NSUInteger indexWantedWithinLine = selection.indexWantedWithinLine;
        if (indexWantedWithinLine == MPXNoStoredLineIndex) {
            indexWantedWithinLine = selection.insertionIndex - lineRange.location;
        }
        
        MPXSelection *newSelection = [[MPXSelection alloc] initWithSelectionRange:range
                                                            indexWantedWithinLine:indexWantedWithinLine
                                                                           origin:selection.origin];
        
        return [[MPXSelectionMutation alloc] initWithInitialSelection:selection
                                                       finalSelection:newSelection
                                                          mutatedText:NO];
    };
    
    [self.mpx_selectionManager mapSelectionsWithMovementDirection:NSSelectionAffinityUpstream
                                              modifyingSelections:YES
                                                       usingBlock:transformBlock];
}

- (void)moveDown:(id)sender
{
    MPXSelectionMutationBlock transformBlock = ^MPXSelectionMutation *(MPXSelection *selection) {
        NSRange lineRange = [self lineRangeForCharacterIndex:selection.insertionIndex];
        NSUInteger endOfLine = NSMaxRange(lineRange);
        
        MPXSelection *newSelection = nil;
        if (endOfLine == self.textStorage.length - 1) {
            NSRange newRange = NSMakeRange(endOfLine, 0);
            newSelection = [[MPXSelection alloc] initWithSelectionRange:newRange
                                          indexWantedWithinLine:MPXNoStoredLineIndex
                                                         origin:newRange.location];
        } else {
            NSRange lineBelowRange = [self lineRangeForCharacterIndex:endOfLine];
            newSelection = MPXSelectionMove(selection, lineRange, lineBelowRange);
        }
        
        return [[MPXSelectionMutation alloc] initWithInitialSelection:selection
                                                       finalSelection:newSelection
                                                          mutatedText:NO];
    };    
    
    [self.mpx_selectionManager mapSelectionsWithMovementDirection:NSSelectionAffinityDownstream
                                              modifyingSelections:NO
                                                       usingBlock:transformBlock];
}

- (void)moveDownAndModifySelection:(id)sender
{
    MPXSelectionMutationBlock transformBlock = ^MPXSelectionMutation *(MPXSelection *selection) {
        if (selection.insertionIndex == self.textStorage.length) {
            return [[MPXSelectionMutation alloc] initWithInitialSelection:selection
                                                           finalSelection:selection
                                                              mutatedText:NO];
        }

        NSRange lineRange = [self lineRangeForCharacterIndex:selection.insertionIndex];
        NSUInteger endOfLine = NSMaxRange(lineRange);
        
        if (endOfLine == self.textStorage.length) {
            NSRange newRange = [selection modifySelectionDownstreamByAmount:endOfLine - selection.insertionIndex];
            MPXSelection *newSelection = [[MPXSelection alloc] initWithSelectionRange:newRange
                                                                indexWantedWithinLine:lineRange.length
                                                                               origin:selection.origin];
            
            return [[MPXSelectionMutation alloc] initWithInitialSelection:selection
                                                           finalSelection:newSelection
                                                              mutatedText:NO];
        }
        
        NSRange lineBelowRange = [self lineRangeForCharacterIndex:endOfLine];
        
        NSUInteger location = MPXLocationForSelection(selection, lineRange, lineBelowRange);
        NSRange range = [selection modifySelectionDownstreamByAmount:location - selection.insertionIndex];
        
        NSUInteger indexWantedWithinLine = selection.indexWantedWithinLine;
        if (indexWantedWithinLine == MPXNoStoredLineIndex) {
            indexWantedWithinLine = selection.insertionIndex - lineRange.location;
        }
        
        MPXSelection *newSelection = [[MPXSelection alloc] initWithSelectionRange:range
                                      indexWantedWithinLine:indexWantedWithinLine
                                                     origin:selection.origin];

        return [[MPXSelectionMutation alloc] initWithInitialSelection:selection
                                                       finalSelection:newSelection
                                                          mutatedText:NO];
    };
    
    [self.mpx_selectionManager mapSelectionsWithMovementDirection:NSSelectionAffinityDownstream
                                              modifyingSelections:YES
                                                       usingBlock:transformBlock];
}

#pragma mark - Left/Right Movements

- (void)moveBackward:(id)sender
{
    [self moveLeft:sender];
}

- (void)moveLeft:(id)sender
{
    MPXSelectionMutationBlock transformBlock = ^MPXSelectionMutation *(MPXSelection *selectionToModify) {
        NSUInteger newIndex = MAX(selectionToModify.insertionIndex - 1, 0);

        // When the selection is more than just a 0-length caret, the behavior in OS X is to snap to the leftmost index
        // within that selection range (its `location`), regardless of the direction/affinity of the selection.
        NSRange range = selectionToModify.range;
        if (range.length > 0) {
            newIndex = range.location;
        }

        MPXSelection *newSelection = [[MPXSelection alloc] initWithSelectionRange:NSMakeRange(newIndex, 0)
                                                            indexWantedWithinLine:selectionToModify.indexWantedWithinLine
                                                                           origin:newIndex];
        
        return [[MPXSelectionMutation alloc] initWithInitialSelection:selectionToModify
                                                       finalSelection:newSelection
                                                          mutatedText:NO];
    };
    
    [self.mpx_selectionManager mapSelectionsWithMovementDirection:NSSelectionAffinityUpstream
                                              modifyingSelections:NO
                                                       usingBlock:transformBlock];
}

- (void)moveBackwardAndModifySelection:(id)sender
{
    [self moveLeftAndModifySelection:sender];
}

- (void)moveLeftAndModifySelection:(id)sender
{
    MPXSelectionMutationBlock transformBlock = ^MPXSelectionMutation *(MPXSelection *selection) {
        MPXSelection *newSelection = [[MPXSelection alloc] initWithSelectionRange:[selection modifySelectionUpstreamByAmount:1]
                                                            indexWantedWithinLine:MPXNoStoredLineIndex
                                                                           origin:selection.origin];
        
        return [[MPXSelectionMutation alloc] initWithInitialSelection:selection
                                                       finalSelection:newSelection
                                                          mutatedText:NO];
    };
    
    [self.mpx_selectionManager mapSelectionsWithMovementDirection:NSSelectionAffinityUpstream
                                              modifyingSelections:YES
                                                       usingBlock:transformBlock];
}

- (void)moveForward:(id)sender
{
    [self moveRight:sender];
}

- (void)moveRight:(id)sender
{
    MPXSelectionMutationBlock transformBlock = ^MPXSelectionMutation *(MPXSelection *fromSelection) {
        NSUInteger newIndex = MIN(fromSelection.insertionIndex + 1, self.textStorage.length);
        
        // When the selection is more than just a 0-length caret, the behavior in OS X is to snap to the rightmost index
        // within that selection range (its max), regardless of the direction/affinity of the selection.
        NSRange range = fromSelection.range;
        if (range.length > 0) {
            newIndex = NSMaxRange(range);
        }
        
        MPXSelection *newSelection = [[MPXSelection alloc] initWithSelectionRange:NSMakeRange(newIndex, 0)
                                                            indexWantedWithinLine:fromSelection.indexWantedWithinLine
                                                                           origin:newIndex];
        
        return [[MPXSelectionMutation alloc] initWithInitialSelection:fromSelection
                                                       finalSelection:newSelection
                                                          mutatedText:NO];            
    };
    
    [self.mpx_selectionManager mapSelectionsWithMovementDirection:NSSelectionAffinityDownstream
                                              modifyingSelections:NO
                                                       usingBlock:transformBlock];
}

- (void)moveForwardAndModifySelection:(id)sender
{
    [self moveRightAndModifySelection:sender];
}

- (void)moveRightAndModifySelection:(id)sender
{
    MPXSelectionMutationBlock transformBlock = ^MPXSelectionMutation *(MPXSelection *selection) {
        if (NSMaxRange(selection.range) == self.textStorage.length) {
            return [[MPXSelectionMutation alloc] initWithInitialSelection:selection
                                                           finalSelection:selection
                                                              mutatedText:NO];
        }

        NSRange newRange = [selection modifySelectionDownstreamByAmount:1];
        MPXSelection *newSelection = [[MPXSelection alloc] initWithSelectionRange:newRange
                                                            indexWantedWithinLine:MPXNoStoredLineIndex
                                                                           origin:selection.origin];
        return [[MPXSelectionMutation alloc] initWithInitialSelection:selection
                                                       finalSelection:newSelection
                                                          mutatedText:NO];
    };
    
    [self.mpx_selectionManager mapSelectionsWithMovementDirection:NSSelectionAffinityDownstream
                                              modifyingSelections:YES
                                                       usingBlock:transformBlock];
}

@end
