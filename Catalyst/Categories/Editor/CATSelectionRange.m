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
@property (nonatomic) NSUInteger intralineDesiredIndex;

@end

@implementation CATSelectionRange

#pragma mark -
#pragma mark Designated Initializer

- (instancetype)initWithSelectionRange:(NSRange)range intralineDesiredIndex:(NSUInteger)intralineDesiredIndex
{
    if ((self = [self init]))
    {
        self.range = range;
        self.intralineDesiredIndex = intralineDesiredIndex;
    }

    return self;
}

#pragma mark -
#pragma mark New Range-Convenience Initializer

- (instancetype)initWithSelectionRange:(NSRange)range
{
    return [[[self class] alloc] initWithSelectionRange:range intralineDesiredIndex:NSNotFound];
}

+ (instancetype)selectionWithRange:(NSRange)range
{
    return [[[self alloc] init] initWithSelectionRange:range];
}

@end
