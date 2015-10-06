//
//  MPXSelectionMutation.m
//  MPXSelectionCore
//
//  Created by Kolin Krewinkel on 9/25/15.
//  Copyright © 2015 Kolin Krewinkel. All rights reserved.
//

#import "MPXSelectionMutation.h"
#import "MPXSelection.h"

@implementation MPXSelectionMutation

- (instancetype)initWithInitialSelection:(MPXSelection *)initialSelection finalSelection:(MPXSelection *)finalSelection
{
    if (self = [super init]) {
        self.initialSelection = initialSelection;
        self.finalSelection = finalSelection;
    }
    
    return self;
}

- (MPXSelection *)adjustTrailingSelection:(MPXSelection *)selection
{
    // The change in length for this mutation.
    NSUInteger delta = self.finalSelection.range.length - self.initialSelection.range.length;
    
    NSRange trailingRange = selection.range;
    return [[MPXSelection alloc] initWithSelectionRange:NSMakeRange(trailingRange.location + delta, trailingRange.length)
                                  indexWantedWithinLine:selection.indexWantedWithinLine + delta
                                                 origin:selection.origin + delta];
}

@end
