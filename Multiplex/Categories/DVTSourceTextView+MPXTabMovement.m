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
#import "MPXSelectionManager.h"
#import "MPXSelection.h"

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
            [self mpx_mapAndFinalizeSelectedRanges:^MPXSelection *(MPXSelection *selection) {
                // Select the entirety of the next placeholder for quick typing-over/deletion.
                return [[MPXSelection alloc] initWithSelectionRange:placeholderOnSameLine
                                              indexWantedWithinLine:MPXNoStoredLineIndex
                                                             origin:placeholderOnSameLine.location];
            } sequentialModification:NO modifyingExistingSelections:NO movementDirection:NSSelectionAffinityDownstream];

            return YES;
        }
    }

    return NO;
}

@end
