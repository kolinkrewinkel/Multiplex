//
//  DVTSourceTextView+MPXWordMovement.m
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

#import "DVTSourceTextView+MPXWordMovement.h"

@implementation DVTSourceTextView (MPXWordMovement)

- (void)mpx_moveSelectionsToWordWithAffinity:(NSSelectionAffinity)affinity
                             modifySelection:(BOOL)modifySelection
{
    MPXSelectionMutationBlock transformBlock = ^MPXSelectionMutation *(MPXSelection *selection) {
        // The built in method is relative to back/forwards. Right means forward.
        BOOL wordForward = affinity == NSSelectionAffinityDownstream;
        
        // Get the new word index from the text storage.
        // The "nextWord..." method is specific to the DVTTextStorage class.
        NSUInteger wordIndex = [self.textStorage nextWordFromIndex:selection.insertionIndex forward:wordForward];
        
        NSRange newRange;
        
        if (modifySelection) {
            if (wordForward) {
                newRange = [selection modifySelectionDownstreamByAmount:wordIndex - selection.insertionIndex];
            } else {
                newRange = [selection modifySelectionUpstreamByAmount:selection.insertionIndex - wordIndex];
            }
        } else {
            newRange = NSMakeRange(wordIndex, 0);
        }
        
        NSUInteger origin = NSUIntegerMax;
        
        // Unionize the ranges if we're expanding the selection.
        if (modifySelection) {
            origin = selection.origin != NSUIntegerMax ? selection.origin : selection.insertionIndex;
        } else {
            origin = newRange.location;
        }
        
        MPXSelection *newSelection = [[MPXSelection alloc] initWithSelectionRange:newRange
                                                            indexWantedWithinLine:MPXNoStoredLineIndex
                                                                           origin:origin];

        return [[MPXSelectionMutation alloc] initWithInitialSelection:selection
                                                       finalSelection:newSelection
                                                          mutatedText:NO];
    };
    
    [self.mpx_selectionManager mapSelectionsWithMovementDirection:affinity
                                              modifyingSelections:modifySelection
                                                       usingBlock:transformBlock];
}

#pragma mark - Directional Movements

- (void)mpx_moveWordLeftModifyingSelection:(BOOL)modifySelection
{
    [self mpx_moveSelectionsToWordWithAffinity:NSSelectionAffinityUpstream modifySelection:modifySelection];
}

- (void)mpx_moveWordRightModifyingSelection:(BOOL)modifySelection
{
    [self mpx_moveSelectionsToWordWithAffinity:NSSelectionAffinityDownstream modifySelection:modifySelection];
}

- (void)moveWordLeft:(id)sender
{
    [self mpx_moveWordLeftModifyingSelection:NO];
}

- (void)moveWordLeftAndModifySelection:(id)sender
{
    [self mpx_moveWordLeftModifyingSelection:YES];
}

- (void)moveWordRight:(id)sender
{
    [self mpx_moveWordRightModifyingSelection:NO];
}

- (void)moveWordRightAndModifySelection:(id)sender
{
    [self mpx_moveWordRightModifyingSelection:YES];
}

#pragma mark - Semantic Movements

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

@end
