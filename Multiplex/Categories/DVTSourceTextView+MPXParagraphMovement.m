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

- (void)mpx_moveLinePositionIncludingLength:(BOOL)includeLength modifySelection:(BOOL)modifySelection
{
    MPXSelectionMutationBlock transformBlock = ^MPXSelectionMutation *(MPXSelection *selection) {
        NSRange previousAbsoluteRange = selection.range;
        NSRange previousLineRange = [self.textStorage.string lineRangeForRange:previousAbsoluteRange];
        
        NSRange newAbsoluteRange = previousAbsoluteRange;
        
        if (includeLength) {
            // It's at the end of the line and needs to be moved down
            if (NSMaxRange(previousAbsoluteRange) == (NSMaxRange(previousLineRange) - 1)
                && NSMaxRange(previousLineRange) < [self.textStorage length]) {
                NSRange newLineRange = [self.textStorage.string lineRangeForRange:NSMakeRange(NSMaxRange(previousLineRange), 0)];
                newAbsoluteRange = NSMakeRange(NSMaxRange(newLineRange) - 1, 0);
            } else {
                newAbsoluteRange = NSMakeRange(NSMaxRange(previousLineRange) - 1, 0);
            }
        } else {
            // It's at the beginning of the line and needs to be moved up
            if (previousAbsoluteRange.location == previousLineRange.location && previousLineRange.location > 0) {
                NSRange newLineRange = [self.textStorage.string lineRangeForRange:NSMakeRange(previousLineRange.location - 1, 0)];
                newAbsoluteRange = NSMakeRange(newLineRange.location, 0);
            } else {
                newAbsoluteRange = NSMakeRange(previousLineRange.location, 0);
            }
        }
        
        MPXSelection *newSelection = nil;
        if (modifySelection) {
            newSelection = [[MPXSelection alloc] initWithSelectionRange:NSUnionRange(previousAbsoluteRange, newAbsoluteRange)
                                                  indexWantedWithinLine:MPXNoStoredLineIndex
                                                                 origin:newAbsoluteRange.location];
        } else {
            newSelection = [[MPXSelection alloc] initWithSelectionRange:newAbsoluteRange
                                                  indexWantedWithinLine:MPXNoStoredLineIndex
                                                                 origin:newAbsoluteRange.location];
        }
        
        return [[MPXSelectionMutation alloc] initWithInitialSelection:selection
                                                       finalSelection:newSelection
                                                          mutatedText:NO];
    };
    
    [self.mpx_selectionManager mapSelectionsWithMovementDirection:includeLength ? NSSelectionAffinityDownstream : NSSelectionAffinityUpstream
                                              modifyingSelections:modifySelection
                                                       usingBlock:transformBlock];
}

- (void)moveToBeginningOfParagraph:(id)sender
{
    [self mpx_moveLinePositionIncludingLength:NO modifySelection:NO];
}

- (void)moveToBeginningOfParagraphAndModifySelection:(id)sender
{
    [self mpx_moveLinePositionIncludingLength:NO modifySelection:YES];
}

- (void)moveToEndOfParagraph:(id)sender
{
    [self mpx_moveLinePositionIncludingLength:YES modifySelection:NO];
}

- (void)moveToEndOfParagraphAndModifySelection:(id)sender
{
    [self mpx_moveLinePositionIncludingLength:YES modifySelection:YES];
}

- (void)moveParagraphBackwardAndModifySelection:(id)sender
{
    [self mpx_moveLinePositionIncludingLength:NO modifySelection:YES];
}

- (void)moveParagraphForwardAndModifySelection:(id)sender
{
    [self mpx_moveLinePositionIncludingLength:YES modifySelection:YES];
}

@end
