//
//  DVTSourceTextView+MPXTokenizedEditing.m
//  Multiplex
//
//  Created by Kolin Krewinkel on 9/19/15.
//  Copyright © 2015 Kolin Krewinkel. All rights reserved.
//

#import <DVTFoundation/DVTRangeArray.h>

#import <DVTKit/DVTLayoutManager.h>

#import "DVTSourceTextView+MPXEditorExtensions.h"
#import "MPXSelection.h"
#import "MPXSelectionManager.h"

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
    
    // When called, `isTokenizedEditingEnabled` is still NO, and there's no `didStartTokenizedEditingWithRanges:` method
    // to immediately disable it. Thus, we do a yucky dispatch_async() because immediately after it gets set to YES.
    // Without this, the editor class will try to intercede when changing the selection in certain ways and snap it back
    // to the original values (issue #17).
    dispatch_async(dispatch_get_main_queue(), ^{
        self.layoutManager.tokenizedEditingEnabled = NO;
    });
}

@end
