//
//  MPXSelectionManager.m
//  Multiplex
//
//  Created by Kolin Krewinkel on 8/23/15.
//  Copyright © 2015 Kolin Krewinkel. All rights reserved.
//

#import <DVTKit/DVTTextStorage.h>

#import "MPXSelection.h"

#import "MPXSelectionManager.h"

@interface MPXSelectionManager ()

@property (nonatomic) DVTTextStorage *textStorage;

@end

@implementation MPXSelectionManager

#pragma mark - Initialization

- (instancetype)initWithTextStorage:(DVTTextStorage *)textStorage
{
    if (self = [super init]) {
        self.textStorage = textStorage;
    }

    return self;
}

- (NSArray *)mpx_sortRanges:(NSArray *)ranges
{
    // Standard sorting logic.
    // Do not include the length so that iteration can do sequential iteration thereafter and do reducing.
    return [ranges sortedArrayUsingComparator:^NSComparisonResult(MPXSelection *selectionRange1,
                                                                  MPXSelection *selectionRange2) {
        NSRange range1 = [selectionRange1 range];
        NSInteger range1Loc = range1.location;

        NSRange range2 = [selectionRange2 range];
        NSInteger range2Loc = range2.location;

        if (range2Loc > range1Loc) {
            return NSOrderedAscending;
        } else if (range2Loc < range1Loc) {
            return NSOrderedDescending;
        }

        return NSOrderedSame;
    }];
}

- (NSArray *)mpx_reduceSortedRanges:(NSArray *)sortedRanges
{
    RACSequence *sortedSequence = [sortedRanges rac_sequence];
    RACSequence *placeholderExpandedSequence = [sortedSequence map:^MPXSelection *(MPXSelection *selection) {
        NSRange range1 = [selection range];
        __block NSRange rangeToAdd = range1;

        // Preprocess the range to adjust for placeholders.
        NSRange trailingPlaceholder = [self rangeOfPlaceholderFromCharacterIndex:NSMaxRange(rangeToAdd)
                                                                         forward:NO
                                                                            wrap:NO
                                                                           limit:0];

        NSRange leadingPlaceholder = [self rangeOfPlaceholderFromCharacterIndex:rangeToAdd.location
                                                                        forward:YES
                                                                           wrap:NO
                                                                          limit:0];

        if (trailingPlaceholder.location != NSNotFound) {
            NSRange intersection = NSIntersectionRange(rangeToAdd, trailingPlaceholder);
            if (intersection.location != NSNotFound && !(intersection.location == 0 && intersection.length == 0)) {
                rangeToAdd = NSUnionRange(rangeToAdd, trailingPlaceholder);
            }
        }

        if (leadingPlaceholder.location != NSNotFound && !NSEqualRanges(leadingPlaceholder, trailingPlaceholder)) {
            NSRange intersection = NSIntersectionRange(rangeToAdd, leadingPlaceholder);
            if (intersection.location != NSNotFound && !(intersection.location == 0 && intersection.length == 0)) {
                rangeToAdd = NSUnionRange(rangeToAdd, leadingPlaceholder);
            }
        }

        return [MPXSelection selectionWithRange:rangeToAdd];
    }];

    NSArray *placeholderExpandedSequenceArray = [placeholderExpandedSequence array];
    RACSequence *mergedRanges = [placeholderExpandedSequence map:^MPXSelection *(MPXSelection *selection) {
        NSRange originalRange = selection.range;
        NSRange currentRange = selection.range;

        NSUInteger currentIndex = [placeholderExpandedSequenceArray indexOfObject:selection];

        NSUInteger compareIndex = 0;
        for (MPXSelection *compareSelection in placeholderExpandedSequenceArray) {
            if (compareIndex > currentIndex) {
                NSRange compareRange = compareSelection.range;

                NSRange joinedRange = NSUnionRange(currentRange, compareRange);
                if (!NSEqualRanges(joinedRange, currentRange) && !NSEqualRanges(joinedRange, compareRange)) {
                    currentRange = joinedRange;
                }
            }

            compareIndex++;
        }

        if (NSEqualRanges(originalRange, currentRange)) {
            return selection;
        }

        return [MPXSelection selectionWithRange:currentRange];
    }];

    NSArray *mergedRangesArray = [mergedRanges array];
    RACSequence *filteredRanges = [mergedRanges filter:^BOOL(MPXSelection *selection) {
        NSUInteger currentIndex = [mergedRangesArray indexOfObject:selection];
        NSRange currentRange = selection.range;

        NSUInteger compareIndex = 0;
        for (MPXSelection *compareSelection in mergedRangesArray) {
            if (compareIndex > currentIndex) {
                NSRange compareRange = compareSelection.range;
                if (NSIntersectionRange(compareRange, currentRange).length > 0) {
                    return NO;
                }
            }

            compareIndex++;
        }

        return YES;
    }];

    return [[NSArray alloc] initWithArray:filteredRanges.array];
}

- (NSArray *)prepareRanges:(NSArray *)ranges
{
    NSArray *sortedRanges = [self mpx_sortRanges:ranges];
    NSArray *reducedRanges = [self mpx_reduceSortedRanges:sortedRanges];
    
    return reducedRanges;
}

@end
