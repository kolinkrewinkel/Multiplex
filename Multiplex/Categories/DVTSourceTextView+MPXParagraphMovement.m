//
//  DVTSourceTextView+MPXParagraphMovement.m
//  Multiplex
//
//  Created by Kolin Krewinkel on 8/26/15.
//  Copyright © 2015 Kolin Krewinkel. All rights reserved.
//

#import <DVTKit/DVTTextStorage.h>

#import "DVTSourceTextView+MPXEditorExtensions.h"
#import "MPXSelection.h"
#import "MPXSelectionManager.h"
#import "MPXSelectionMutation.h"

#import "DVTSourceTextView+MPXParagraphMovement.h"

@implementation DVTSourceTextView (MPXParagraphMovement)

#pragma mark - Upstream

- (void)moveToBeginningOfParagraph:(id)sender
{
    MPXSelectionMutationBlock transformBlock = ^MPXSelectionMutation *(MPXSelection *selection) {
        NSRange rangeOfLine = [self.textStorage.string lineRangeForRange:selection.range];
        
        MPXSelection *newSelection = [[MPXSelection alloc] initWithSelectionRange:NSMakeRange(rangeOfLine.location, 0)
                                                            indexWantedWithinLine:MPXNoStoredLineIndex
                                                                           origin:rangeOfLine.location];
        
        return [[MPXSelectionMutation alloc] initWithInitialSelection:selection
                                                       finalSelection:newSelection
                                                          mutatedText:NO];
    };
    
    [self.mpx_selectionManager mapSelectionsWithMovementDirection:NSSelectionAffinityUpstream
                                              modifyingSelections:NO
                                                       usingBlock:transformBlock];
}

- (void)moveParagraphBackwardAndModifySelection:(id)sender
{
    MPXSelectionMutationBlock transformBlock = ^MPXSelectionMutation *(MPXSelection *selection) {
        if (selection.insertionIndex == 0) {
            return [[MPXSelectionMutation alloc] initWithInitialSelection:selection
                                                           finalSelection:selection
                                                              mutatedText:NO];
        }

        NSRange searchRange = NSMakeRange(selection.insertionIndex - 1, 0);
        NSRange rangeOfLine = [self.textStorage.string lineRangeForRange:searchRange];
        
        NSRange newRange = [selection modifySelectionUpstreamByAmount:selection.insertionIndex - rangeOfLine.location];
        MPXSelection *newSelection = [[MPXSelection alloc] initWithSelectionRange:newRange
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

#pragma mark - Downstream

- (void)moveToEndOfParagraph:(id)sender
{
    MPXSelectionMutationBlock transformBlock = ^MPXSelectionMutation *(MPXSelection *selection) {
        NSRange rangeOfLine = [self.textStorage.string lineRangeForRange:selection.range];
        NSRange endOfLineCaret = NSMakeRange(NSMaxRange(rangeOfLine) - 1, 0);
        
        MPXSelection *newSelection = [[MPXSelection alloc] initWithSelectionRange:endOfLineCaret
                                                            indexWantedWithinLine:MPXNoStoredLineIndex
                                                                           origin:endOfLineCaret.location];
        
        return [[MPXSelectionMutation alloc] initWithInitialSelection:selection
                                                       finalSelection:newSelection
                                                          mutatedText:NO];
    };
    
    [self.mpx_selectionManager mapSelectionsWithMovementDirection:NSSelectionAffinityDownstream
                                              modifyingSelections:NO
                                                       usingBlock:transformBlock];
}

- (void)moveParagraphForwardAndModifySelection:(id)sender
{
    MPXSelectionMutationBlock transformBlock = ^MPXSelectionMutation *(MPXSelection *selection) {
        // Prevent trying to move beyond the end of the text.
        if (selection.insertionIndex + 1 > [self.textStorage.string length]) {
            return [[MPXSelectionMutation alloc] initWithInitialSelection:selection
                                                           finalSelection:selection
                                                              mutatedText:NO];
        }
    
        // Check the position after the end of the range because when at the end of a line, we want to move forward onto
        // the next line.
        NSRange searchRange = NSMakeRange(selection.insertionIndex + 1, 0);

        NSRange rangeOfLine = [self.textStorage.string lineRangeForRange:searchRange];
        NSUInteger endOfLine = NSMaxRange(rangeOfLine) - 1;
        
        NSRange newRange = [selection modifySelectionDownstreamByAmount:endOfLine - selection.insertionIndex];
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
