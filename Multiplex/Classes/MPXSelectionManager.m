//
//  MPXSelectionManager.m
//  Multiplex
//
//  Created by Kolin Krewinkel on 8/23/15.
//  Copyright © 2015 Kolin Krewinkel. All rights reserved.
//

#import <DVTKit/DVTSourceTextView.h>

#import "MPXSelection.h"

#import "MPXSelectionManager.h"

@interface MPXSelectionManager ()

@property (nonatomic) DVTSourceTextView *textView;

@property (nonatomic) NSArray *temporarySelections;

@end

@implementation MPXSelectionManager

#pragma mark - Initialization

- (instancetype)initWithTextView:(DVTSourceTextView *)textView
{
    if (self = [super init]) {
        self.textView = textView;
    }

    return self;
}

#pragma mark - Range Logic

static RACSequence *MPXSortedSelections(NSArray *selections)
{
    return [[selections sortedArrayUsingComparator:^NSComparisonResult(MPXSelection *selection1,
                                                                      MPXSelection *selection2) {
        NSRange range1 = selection1.range;
        NSInteger range1Loc = range1.location;

        NSRange range2 = selection2.range;
        NSInteger range2Loc = range2.location;

        if (range2Loc > range1Loc) {
            return NSOrderedAscending;
        } else if (range2Loc < range1Loc) {
            return NSOrderedDescending;
        }

        return NSOrderedSame;
    }] rac_sequence];
}

- (RACSequence *)selectionsWithFixedPlaceholdersForSortedSelections:(RACSequence *)sortedSelections
{
    // For testing contexts where a textView is not available.
    if (!self.textView) {
        return sortedSelections;
    }

    return [sortedSelections map:^MPXSelection *(MPXSelection *selection) {
        NSRange range1 = [selection range];
        __block NSRange rangeToAdd = range1;

        // Preprocess the range to adjust for placeholders.
        NSRange trailingPlaceholder = [self.textView rangeOfPlaceholderFromCharacterIndex:NSMaxRange(rangeToAdd)
                                                                                  forward:NO
                                                                                     wrap:NO
                                                                                    limit:0];

        NSRange leadingPlaceholder = [self.textView rangeOfPlaceholderFromCharacterIndex:rangeToAdd.location
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
}

static RACSequence *MPXMergedSortedSelections(RACSequence *sortedSelections)
{
    NSArray *sortedSelectionsArray = [sortedSelections array];
    return [sortedSelections map:^MPXSelection *(MPXSelection *selection) {
        NSRange originalRange = selection.range;
        NSRange currentRange = selection.range;

        NSUInteger currentIndex = [sortedSelectionsArray indexOfObject:selection];

        NSUInteger compareIndex = 0;
        for (MPXSelection *compareSelection in sortedSelectionsArray) {
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
}

static RACSequence *MPXCoallescedSelections(RACSequence *mergedSelections)
{
    NSArray *mergedSelectionsArray = [mergedSelections array];
    return [mergedSelections filter:^BOOL(MPXSelection *selection) {
        NSUInteger currentIndex = [mergedSelectionsArray indexOfObject:selection];
        NSRange currentRange = selection.range;

        NSUInteger compareIndex = 0;
        for (MPXSelection *compareSelection in mergedSelectionsArray) {
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
}

- (NSArray *)fixedSelections:(NSArray *)ranges
{
    RACSequence *sortedSelections = MPXSortedSelections(ranges);
    RACSequence *placeholderFixedSelections = [self selectionsWithFixedPlaceholdersForSortedSelections:sortedSelections];
    RACSequence *mergedSelections = MPXMergedSortedSelections(placeholderFixedSelections);
    return [MPXCoallescedSelections(mergedSelections) array];
}

#pragma mark - Display

- (NSArray *)visualSelections
{
    return self.temporarySelections ?: self.finalizedSelections;
}

- (void)setFinalizedSelections:(NSArray *)finalizedSelections
{
    _finalizedSelections = [self fixedSelections:finalizedSelections];
    self.temporarySelections = nil;

    [self.visualizationDelegate selectionManager:self didChangeVisualSelections:self.visualSelections];
}

- (void)setTemporarySelections:(NSArray *)temporarySelections
{
    _temporarySelections = [self fixedSelections:temporarySelections];

    [self.visualizationDelegate selectionManager:self didChangeVisualSelections:self.visualSelections];
}

@end
