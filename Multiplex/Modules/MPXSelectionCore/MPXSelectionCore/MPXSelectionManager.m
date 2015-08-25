//
//  MPXSelectionManager.m
//  Multiplex
//
//  Created by Kolin Krewinkel on 8/23/15.
//  Copyright © 2015 Kolin Krewinkel. All rights reserved.
//

@import ReactiveCocoa;
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

static NSArray *MPXSortedSelections(NSArray *selections)
{
    return [selections sortedArrayUsingComparator:^NSComparisonResult(MPXSelection *selection1,
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
    }];
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

- (NSArray *)fixedSelections:(NSArray *)ranges
{
    NSArray *sortedSelections = MPXSortedSelections(ranges);
    RACSequence *placeholderFixedSelections = [self selectionsWithFixedPlaceholdersForSortedSelections:sortedSelections.rac_sequence];

    NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
    for (MPXSelection *selection in placeholderFixedSelections) {
        if (selection.range.length == 0) {
            continue;
        }

        [indexSet addIndexesInRange:selection.range];
    }

    NSMutableSet *selections = [[NSMutableSet alloc] init];
    [indexSet enumerateRangesUsingBlock:^(NSRange range, BOOL * _Nonnull stop) {
        [selections addObject:[MPXSelection selectionWithRange:range]];
    }];

    for (MPXSelection *selection in placeholderFixedSelections) {
        if (selection.range.length == 0 && ![indexSet containsIndexesInRange:NSMakeRange(selection.range.location, 1)]) {
            [selections addObject:selection];
        }
    }

    return MPXSortedSelections(selections.allObjects);
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
    if (!temporarySelections) {
        _temporarySelections = nil;
        return;
    }
    
    _temporarySelections = [self fixedSelections:temporarySelections];

    [self.visualizationDelegate selectionManager:self didChangeVisualSelections:self.visualSelections];
}

@end
