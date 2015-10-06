//
//  MPXSelectionMutation.m
//  MPXSelectionCore
//
//  Created by Kolin Krewinkel on 9/25/15.
//  Copyright © 2015 Kolin Krewinkel. All rights reserved.
//

#import "MPXSelectionMutation.h"
#import "MPXSelection.h"

@interface MPXSelectionMutation ()

@property (nonatomic) MPXSelection *initialSelection;
@property (nonatomic) MPXSelection *finalSelection;

@end

@implementation MPXSelectionMutation

- (instancetype)initWithInitialSelection:(MPXSelection *)initialSelection
                          finalSelection:(MPXSelection *)finalSelection
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
    NSUInteger changeInLength = self.finalSelection.range.length - self.initialSelection.range.length;
    NSUInteger changeInLocation = self.finalSelection.range.location - self.initialSelection.range.location;
    NSUInteger delta = changeInLength + changeInLocation;
    
    NSRange trailingRange = selection.range;
    return [[MPXSelection alloc] initWithSelectionRange:NSMakeRange(trailingRange.location + delta, trailingRange.length)
                                  indexWantedWithinLine:selection.indexWantedWithinLine + delta
                                                 origin:selection.origin + delta];
}

@end
