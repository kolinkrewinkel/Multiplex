//
//  MPXSelection.m
//  Multiplex
//
//  Created by Kolin Krewinkel on 12/27/14.
//  Copyright (c) 2014 Kolin Krewinkel. All rights reserved.
//

#import "MPXSelection.h"

@interface MPXSelection ()

@property (nonatomic) NSRange range;
@property (nonatomic) NSUInteger interLineDesiredIndex;
@property (nonatomic) NSUInteger origin;

@end

@implementation MPXSelection

#pragma mark - Designated Initializer

- (instancetype)initWithSelectionRange:(NSRange)range
                 interLineDesiredIndex:(NSUInteger)interLineDesiredIndex
                                origin:(NSUInteger)origin
{
    if ((self = [self init]))
    {
        self.range = range;
        self.interLineDesiredIndex = interLineDesiredIndex;
        self.origin = origin;
    }

    return self;
}

#pragma mark - New Range-Convenience Initializer

- (instancetype)initWithSelectionRange:(NSRange)range
{
    return [[[self class] alloc] initWithSelectionRange:range
                                  interLineDesiredIndex:NSNotFound
                                                 origin:range.location];
}

+ (instancetype)selectionWithRange:(NSRange)range
{
    return [[[self alloc] init] initWithSelectionRange:range];
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]])
    {
        return NO;
    }

    MPXSelection *otherSelection = (MPXSelection *)object;

    return (otherSelection.interLineDesiredIndex == self.interLineDesiredIndex
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
            (unsigned long)self.interLineDesiredIndex,
            NSStringFromRange(self.range)];
}

@end
