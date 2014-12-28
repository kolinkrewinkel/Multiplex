//
//  CATSelectionRange.m
//  Catalyst
//
//  Created by Kolin Krewinkel on 12/27/14.
//  Copyright (c) 2014 Kolin Krewinkel. All rights reserved.
//

#import "CATSelectionRange.h"

@interface CATSelectionRange ()

@property (nonatomic) NSRange range;

@end

@implementation CATSelectionRange

#pragma mark -
#pragma mark Initialization

- (instancetype)initWithSelectionRange:(NSRange)range
{
    if ((self = [self init]))
    {
        self.range = range;
    }

    return self;
}

+ (instancetype)selectionWithRange:(NSRange)range
{
    return [[[self alloc] init] initWithSelectionRange:range];
}


@end
