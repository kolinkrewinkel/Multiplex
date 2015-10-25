//
//  DVTSourceTextView+MPXLineMovement.m
//  Multiplex
//
//  Created by Kolin Krewinkel on 8/26/15.
//  Copyright © 2015 Kolin Krewinkel. All rights reserved.
//

#import <DVTKit/DVTTextStorage.h>
#import <DVTKit/DVTLayoutManager.h>

#import "DVTSourceTextView+MPXEditorExtensions.h"
#import "MPXSelection.h"
#import "MPXSelectionManager.h"
#import "MPXSelectionMutation.h"

#import "DVTSourceTextView+MPXLineMovement.h"

@implementation DVTSourceTextView (MPXLineMovement)

#pragma mark - Convenience

/**
 * @return Range of characters for the word-wrapped line containing the index.
 */
 - (NSRange)mpx_rangeOfWordWrappedLineContainingIndex:(NSUInteger)index
{
    // Use -lineFragmentRectForGlyphAtIndex:effectiveRange: instead of -lineRangeForRange: on NSString because we want
    // line movements to occur relative to word-wrapped lines. Otherwise, for example, Command-Left Arrow on a word-
    // wrapped line would jump it to the (visual) line above.
    NSRange lineRange;
    [self.layoutManager lineFragmentRectForGlyphAtIndex:index effectiveRange:&lineRange];
    
    return lineRange;
}

#pragma mark - Directional Movements

- (void)moveToLeftEndOfLine:(id)sender
{
    MPXSelectionMutationBlock transformBlock = ^MPXSelectionMutation *(MPXSelection *selection) {
        // Move to the beginning of the line.
        NSRange lineRange = [self mpx_rangeOfWordWrappedLineContainingIndex:selection.insertionIndex];
        NSRange newCursorRange = NSMakeRange(lineRange.location, 0);

        // Because it's a plain caret selection, the origin needs to be moved/reset to wherever the caret is so
        // subsequent modifications are performed about this location.
        MPXSelection *newSelection = [[MPXSelection alloc] initWithSelectionRange:newCursorRange
                                                            indexWantedWithinLine:MPXNoStoredLineIndex
                                                                           origin:NSMaxRange(newCursorRange)];

        return [[MPXSelectionMutation alloc] initWithInitialSelection:selection
                                                       finalSelection:newSelection
                                                          mutatedText:NO];
    };
    
    [self.mpx_selectionManager mapSelectionsWithMovementDirection:NSSelectionAffinityUpstream
                                              modifyingSelections:NO
                                                       usingBlock:transformBlock];
}

- (void)moveToLeftEndOfLineAndModifySelection:(id)sender
{
    MPXSelectionMutationBlock transformBlock = ^MPXSelectionMutation *(MPXSelection *selection) {
        NSRange lineRange = [self mpx_rangeOfWordWrappedLineContainingIndex:selection.insertionIndex];
        
        // The selection should be moved upstream about the insertion index (and not the location) because the logic
        // used to modify it in -modifySelectionUpstreamByAmount: will need to start from the trailing end and "clear"
        // entire trailing side before getting to the origin, then progressing upstream the remaing amount to the
        // desired location.
        NSRange newRange = [selection modifySelectionUpstreamByAmount:selection.insertionIndex - lineRange.location];

        MPXSelection *newSelection = [[MPXSelection alloc] initWithSelectionRange:newRange
                                                            indexWantedWithinLine:MPXNoStoredLineIndex
                                                                           origin:NSMaxRange(newRange)];
        
        return [[MPXSelectionMutation alloc] initWithInitialSelection:selection
                                                       finalSelection:newSelection
                                                          mutatedText:NO];
    };
    
    [self.mpx_selectionManager mapSelectionsWithMovementDirection:NSSelectionAffinityUpstream
                                              modifyingSelections:YES
                                                       usingBlock:transformBlock];
}

- (void)moveToRightEndOfLine:(id)sender
{
    MPXSelectionMutationBlock transformBlock = ^MPXSelectionMutation *(MPXSelection *selection) {
        NSRange lineRange = [self mpx_rangeOfWordWrappedLineContainingIndex:selection.insertionIndex];
        
        // Subtract one from lineRange's max so the cursor isn't placed after the newline.
        NSRange newCursorRange = NSMakeRange(NSMaxRange(lineRange) - 1, 0);
        MPXSelection *newSelection = [[MPXSelection alloc] initWithSelectionRange:newCursorRange
                                                            indexWantedWithinLine:MPXNoStoredLineIndex
                                                                           origin:NSMaxRange(newCursorRange)];
        
        return [[MPXSelectionMutation alloc] initWithInitialSelection:selection
                                                       finalSelection:newSelection
                                                          mutatedText:NO];
    };
    
    [self.mpx_selectionManager mapSelectionsWithMovementDirection:NSSelectionAffinityDownstream
                                              modifyingSelections:NO
                                                       usingBlock:transformBlock];
}

- (void)moveToRightEndOfLineAndModifySelection:(id)sender
{
    MPXSelectionMutationBlock transformBlock = ^MPXSelectionMutation *(MPXSelection *selection) {
        NSRange lineRange = [self mpx_rangeOfWordWrappedLineContainingIndex:selection.insertionIndex];
        
        // As in -moveToLeftEndOfLineAndModifySelection:, the selection has to be incremented by enough to account for
        // a leading edge and then extending out to the end of the line from the trailing edge. 
        NSUInteger endOfLine = NSMaxRange(lineRange) - 1;
        NSRange newRange = [selection modifySelectionDownstreamByAmount:endOfLine - selection.insertionIndex];
        
        MPXSelection *newSelection = [[MPXSelection alloc] initWithSelectionRange:newRange
                                                            indexWantedWithinLine:MPXNoStoredLineIndex
                                                                           origin:newRange.location];
        
        return [[MPXSelectionMutation alloc] initWithInitialSelection:selection
                                                       finalSelection:newSelection
                                                          mutatedText:NO];
    };
    
    [self.mpx_selectionManager mapSelectionsWithMovementDirection:NSSelectionAffinityDownstream
                                              modifyingSelections:YES
                                                       usingBlock:transformBlock];
}

#pragma mark - Semantic Movements

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

@end
