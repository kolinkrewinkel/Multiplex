//
//  DVTSourceTextView+MPXTabMovement.h
//  Multiplex
//
//  Created by Kolin Krewinkel on 10/24/15.
//  Copyright © 2015 Kolin Krewinkel. All rights reserved.
//


#import <DVTKit/DVTTextStorage.h>

#import "DVTSourceTextView+MPXEditorExtensions.h"
#import "DVTSourceTextView+MPXIndentation.h"
#import "MPXSelection.h"
#import "MPXSelectionManager.h"
#import "MPXSelectionMutation.h"

#import "DVTSourceTextView+MPXDocumentMovement.h"

@implementation DVTSourceTextView (MPXDocumentMovement)

- (BOOL)handleInsertBackTab
{
    return [self mpx_handleTabInDirection:NSSelectionAffinityUpstream];
}

- (BOOL)handleInsertTab
{
    if ([self mpx_handleTabInDirection:NSSelectionAffinityDownstream]) {
        return YES;
    }

    [self insertText:[self mpx_tabString]];

    return YES;
}

- (BOOL)mpx_handleTabInDirection:(NSSelectionAffinity)direction
{
    if ([self.mpx_selectionManager.finalizedSelections count] == 1) {
        MPXSelection *selection = [self.mpx_selectionManager.finalizedSelections firstObject];

        // Use the actual line to allow skipping to a placeholder that's only soft word-wrapped.
        NSRange lineRange = [self.string lineRangeForRange:selection.range];

        BOOL forward = direction == NSSelectionAffinityDownstream;

        // Get the next placeholder within the line.
        NSRange placeholderOnSameLine = [self rangeOfPlaceholderFromCharacterIndex:selection.range.location
                                                                           forward:forward
                                                                              wrap:NO
                                                                             limit:NSMaxRange(lineRange)];

        if (placeholderOnSameLine.length > 0) {
            MPXSelectionMutationBlock transformBlock = ^MPXSelectionMutation *(MPXSelection *selectionToModify) {
                // Select the entirety of the next placeholder for quick typing-over/deletion.
                MPXSelection *selection = [[MPXSelection alloc] initWithSelectionRange:placeholderOnSameLine
                                                                 indexWantedWithinLine:MPXNoStoredLineIndex
                                                                                origin:placeholderOnSameLine.location];

                return [[MPXSelectionMutation alloc] initWithInitialSelection:selectionToModify
                                                               finalSelection:selection
                                                                  mutatedText:NO];
            };
            
            [self.mpx_selectionManager mapSelectionsWithMovementDirection:NSSelectionAffinityDownstream
                                                      modifyingSelections:NO
                                                               usingBlock:transformBlock];

            return YES;
        }
    }

    return NO;
}

@end
