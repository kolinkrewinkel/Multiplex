//
//  DVTSourceTextView+MPXEditorClipboardSupport.m
//  Multiplex
//
//  Created by Kolin Krewinkel on 8/26/15.
//  Copyright © 2015 Kolin Krewinkel. All rights reserved.
//

#import <DVTKit/DVTTextStorage.h>
#import <DVTKit/DVTLayoutManager.h>

#import <MPXFoundation/MPXFoundation.h>

#import <MPXSelectionCore/MPXSelectionCore.h>

#import "DVTSourceTextView+MPXEditorExtensions.h"

#import "DVTSourceTextView+MPXEditorLineMovement.h"

@implementation DVTSourceTextView (MPXEditorLineMovement)

- (void)mpx_moveSelectionsToLineExtremity:(NSSelectionAffinity)affinity modifyingSelection:(BOOL)modifySelection
{
    [self mpx_mapAndFinalizeSelectedRanges:^MPXSelection *(MPXSelection *selection) {
        NSRange previousAbsoluteRange = selection.range;

        // The cursors are being pushed to the line's relative location of 0 or .length.
        NSRange rangeOfContainingLine = ({
            NSRange range;
            NSUInteger locationToBaseFrom = previousAbsoluteRange.location;

            if (affinity == NSSelectionAffinityDownstream) {
                locationToBaseFrom = NSMaxRange(previousAbsoluteRange);
            }

            [self.layoutManager lineFragmentRectForGlyphAtIndex:locationToBaseFrom
                                                 effectiveRange:&range];
            range;
        });

        NSRange cursorRange = NSMakeRange(rangeOfContainingLine.location, 0);

        if (affinity == NSSelectionAffinityDownstream) {
            cursorRange.location += rangeOfContainingLine.length - 1;
        }

        if (modifySelection) {
            cursorRange = NSUnionRange(previousAbsoluteRange, cursorRange);
        }

        return [MPXSelection selectionWithRange:cursorRange];
    }];
}

- (void)mpx_moveToLeftEndOfLineModifyingSelection:(BOOL)modifySelection
{
    [self mpx_moveSelectionsToLineExtremity:NSSelectionAffinityUpstream modifyingSelection:modifySelection];
}

- (void)mpx_moveToRightEndOfLineModifyingSelection:(BOOL)modifySelection
{
    [self mpx_moveSelectionsToLineExtremity:NSSelectionAffinityDownstream modifyingSelection:modifySelection];
}

#pragma mark - Directional Movements

- (void)moveToLeftEndOfLine:(id)sender
{
    [self mpx_moveToLeftEndOfLineModifyingSelection:NO];
}

- (void)moveToLeftEndOfLineAndModifySelection:(id)sender
{
    [self mpx_moveToLeftEndOfLineModifyingSelection:YES];
}

- (void)moveToRightEndOfLine:(id)sender
{
    [self mpx_moveToRightEndOfLineModifyingSelection:NO];
}

- (void)moveToRightEndOfLineAndModifySelection:(id)sender
{
    [self mpx_moveToRightEndOfLineModifyingSelection:YES];
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
