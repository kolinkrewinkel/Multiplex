//
//  DVTSourceTextView+MPXEditorDocumentMovement.h"
//  Multiplex
//
//  Created by Kolin Krewinkel on 8/26/15.
//  Copyright © 2015 Kolin Krewinkel. All rights reserved.
//

@import MPXSelectionCore;

#import <DVTKit/DVTTextStorage.h>

#import "DVTSourceTextView+MPXEditorExtensions.h"

#import "DVTSourceTextView+MPXEditorDocumentMovement.h"

@implementation DVTSourceTextView (MPXEditorDocumentMovement)

#pragma mark - Logic

- (void)mpx_moveToRange:(NSRange)newRange modifyingSelection:(BOOL)modifySelection
{
    [self mpx_mapAndFinalizeSelectedRanges:^MPXSelection *(MPXSelection *selection) {
        NSRange previousAbsoluteRange = selection.range;
        NSRange newAbsoluteRange = newRange;

        if (modifySelection) {
            newAbsoluteRange = NSUnionRange(previousAbsoluteRange, newAbsoluteRange);
        }

        return [[MPXSelection alloc] initWithSelectionRange:newAbsoluteRange
                                      indexWantedWithinLine:MPXNoStoredLineIndex
                                                     origin:selection.insertionIndex];
    }];
}

- (void)mpx_moveToBeginningOfDocumentModifyingSelection:(BOOL)modifySelection
{
    [self mpx_moveToRange:NSMakeRange(0, 0) modifyingSelection:modifySelection];
}

- (void)mpx_moveToEndOfDocumentModifyingSelection:(BOOL)modifySelection
{
    [self mpx_moveToRange:NSMakeRange([self.textStorage length] - 1, 0) modifyingSelection:modifySelection];
}

#pragma mark - Forwarding Methods

- (void)moveToBeginningOfDocument:(id)sender
{
    [self mpx_moveToBeginningOfDocumentModifyingSelection:NO];
}

- (void)moveToBeginningOfDocumentAndModifySelection:(id)sender
{
    [self mpx_moveToBeginningOfDocumentModifyingSelection:YES];
}

- (void)moveToEndOfDocument:(id)sender
{
    [self mpx_moveToEndOfDocumentModifyingSelection:NO];
}

- (void)moveToEndOfDocumentAndModifySelection:(id)sender
{
    [self mpx_moveToEndOfDocumentModifyingSelection:YES];
}

@end
