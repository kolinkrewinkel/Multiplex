//
//  CATSelectionRange.m
//  Multiplex
//
//  Created by Kolin Krewinkel on 12/27/14.
//  Copyright (c) 2014 Kolin Krewinkel. All rights reserved.
//

#import "MPXSelectionRange.h"

@interface MPXSelectionRange ()

@property (nonatomic) NSRange range;
@property (nonatomic) NSUInteger intralineDesiredIndex;

@end

@implementation MPXSelectionRange

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

#pragma mark -
#pragma mark NSObject

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]])
    {
        return NO;
    }

    MPXSelectionRange *otherSelection = (MPXSelectionRange *)object;

    return (otherSelection.intralineDesiredIndex == self.intralineDesiredIndex
            && NSEqualRanges(otherSelection.range, self.range));
}

- (NSString *)description
{
    return [self debugDescription];
}

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"<%@: intraline index: %lu, range: %@>",
            NSStringFromClass([self class]),
            (unsigned long)self.intralineDesiredIndex,
            NSStringFromRange(self.range)];
}

@end
