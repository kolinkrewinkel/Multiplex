//
//  DVTSourceTextView+MPXTokenizedEditing.m
//  Multiplex
//
//  Created by Kolin Krewinkel on 9/19/15.
//  Copyright © 2015 Kolin Krewinkel. All rights reserved.
//

#import <DVTFoundation/DVTRangeArray.h>

@import MPXSelectionCore;

#import "DVTSourceTextView+MPXEditorExtensions.h"
#import "DVTSourceTextView+MPXTokenizedEditing.h"

@implementation DVTSourceTextView (MPXTokenizedEditing)

- (void)willStartTokenizedEditingWithRanges:(DVTRangeArray *)rangesArray
{
    self.mpx_selectionManager.finalizedSelections = [[[rangesArray rac_sequence] map:^MPXSelection *(NSValue *value) {
        NSRange range = [value rangeValue];
        return [[MPXSelection alloc] initWithSelectionRange:range
                                      indexWantedWithinLine:MPXNoStoredLineIndex
                                                     origin:range.location];
    }] array];
}

@end
