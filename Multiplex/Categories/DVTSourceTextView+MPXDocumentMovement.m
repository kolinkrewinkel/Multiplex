//
//  DVTSourceTextView+MPXDocumentMovement.h"
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

#import "DVTSourceTextView+MPXDocumentMovement.h"

@implementation DVTSourceTextView (MPXDocumentMovement)

- (void)moveToBeginningOfDocument:(id)sender
{
    // This is a pretty straightforward mapping back to 0,0.
    MPXSelectionMutationBlock transformBlock = ^MPXSelectionMutation *(MPXSelection *selectionToModify) {
        MPXSelection *newSelection = [[MPXSelection alloc] initWithSelectionRange:NSMakeRange(0, 0)
                                                            indexWantedWithinLine:MPXNoStoredLineIndex
                                                                           origin:0];

        return [[MPXSelectionMutation alloc] initWithInitialSelection:selectionToModify
                                                       finalSelection:newSelection
                                                          mutatedText:NO];
    };

    [self.mpx_selectionManager mapSelectionsWithMovementDirection:NSSelectionAffinityUpstream
                                              modifyingSelections:NO
                                                       usingBlock:transformBlock];
}

- (void)moveToBeginningOfDocumentAndModifySelection:(id)sender
{
    MPXSelectionMutationBlock transformBlock = ^MPXSelectionMutation *(MPXSelection *selectionToModify) {
        // Moving back to 0, we can just decrement by the location of the caret; set the origin to the trailing edge of
        // the selection.
        NSRange newRange = [selectionToModify modifySelectionUpstreamByAmount:selectionToModify.insertionIndex];
        MPXSelection *newSelection = [[MPXSelection alloc] initWithSelectionRange:newRange
                                                            indexWantedWithinLine:MPXNoStoredLineIndex
                                                                           origin:NSMaxRange(newRange)];

        return [[MPXSelectionMutation alloc] initWithInitialSelection:selectionToModify
                                                       finalSelection:newSelection
                                                          mutatedText:NO];
    };

    [self.mpx_selectionManager mapSelectionsWithMovementDirection:NSSelectionAffinityUpstream
                                              modifyingSelections:YES
                                                       usingBlock:transformBlock];
}

- (void)moveToEndOfDocument:(id)sender
{
    MPXSelectionMutationBlock transformBlock = ^MPXSelectionMutation *(MPXSelection *selectionToModify) {
        NSUInteger endOfDocument = [self.textStorage.string length];
        MPXSelection *newSelection = [[MPXSelection alloc] initWithSelectionRange:NSMakeRange(endOfDocument, 0)
                                                            indexWantedWithinLine:MPXNoStoredLineIndex
                                                                           origin:endOfDocument];

        return [[MPXSelectionMutation alloc] initWithInitialSelection:selectionToModify
                                                       finalSelection:newSelection
                                                          mutatedText:NO];
    };

    [self.mpx_selectionManager mapSelectionsWithMovementDirection:NSSelectionAffinityDownstream
                                              modifyingSelections:NO
                                                       usingBlock:transformBlock];
}

- (void)moveToEndOfDocumentAndModifySelection:(id)sender
{
    MPXSelectionMutationBlock transformBlock = ^MPXSelectionMutation *(MPXSelection *selectionToModify) {
        NSUInteger deltaToEnd = [self.textStorage.string length] - selectionToModify.insertionIndex;
        NSRange newRange = [selectionToModify modifySelectionDownstreamByAmount:deltaToEnd];

        MPXSelection *newSelection = [[MPXSelection alloc] initWithSelectionRange:newRange
                                                            indexWantedWithinLine:MPXNoStoredLineIndex
                                                                           origin:newRange.location];

        return [[MPXSelectionMutation alloc] initWithInitialSelection:selectionToModify
                                                       finalSelection:newSelection
                                                          mutatedText:NO];
    };

    [self.mpx_selectionManager mapSelectionsWithMovementDirection:NSSelectionAffinityDownstream
                                              modifyingSelections:YES
                                                       usingBlock:transformBlock];
}

@end
