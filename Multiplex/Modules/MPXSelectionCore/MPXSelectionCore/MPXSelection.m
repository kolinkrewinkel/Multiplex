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
@property (nonatomic) NSUInteger indexWantedWithinLine;
@property (nonatomic) NSUInteger origin;

@end

@implementation MPXSelection

#pragma mark - Designated Initializer

- (instancetype)initWithSelectionRange:(NSRange)range
                 indexWantedWithinLine:(NSUInteger)indexWantedWithinLine
                                origin:(NSUInteger)origin
{
    if (self = [self init]) {
        self.range = range;
        self.indexWantedWithinLine = indexWantedWithinLine;
        self.origin = origin;
    }

    return self;
}

#pragma mark - Convenience Initializers

- (instancetype)initWithSelectionRange:(NSRange)range
{
    return [self initWithSelectionRange:range indexWantedWithinLine:NSNotFound origin:range.location];
}

+ (instancetype)selectionWithRange:(NSRange)range
{
    return [[[self alloc] init] initWithSelectionRange:range];
}

#pragma mark - Getters/Setters

- (NSUInteger)caretIndex
{
    switch (self.selectionAffinity) {
        case NSSelectionAffinityUpstream:
            return self.range.location;
        case NSSelectionAffinityDownstream:
            return NSMaxRange(self.range);
    }
}

- (NSSelectionAffinity)selectionAffinity
{
    if (self.range.location < self.origin) {
        return NSSelectionAffinityUpstream;
    }

    return NSSelectionAffinityDownstream;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }

    MPXSelection *otherSelection = (MPXSelection *)object;

    return (otherSelection.indexWantedWithinLine == self.indexWantedWithinLine
            && NSEqualRanges(otherSelection.range, self.range));
}

- (NSUInteger)hash
{
    return self.range.location;
}

- (NSString *)description
{
    return [self debugDescription];
}

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"<%@: range: %@, interline index: %lu, origin: %lu>",
            NSStringFromClass([self class]),
            NSStringFromRange(self.range),
            (unsigned long)self.indexWantedWithinLine,
            (unsigned long)self.origin];

}

@end
