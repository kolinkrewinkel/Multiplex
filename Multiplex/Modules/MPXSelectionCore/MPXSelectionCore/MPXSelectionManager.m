//
//  MPXSelectionManager.m
//  Multiplex
//
//  Created by Kolin Krewinkel on 8/23/15.
//  Copyright © 2015 Kolin Krewinkel. All rights reserved.
//

@import ReactiveCocoa;

#import <DVTFoundation/DVTMutableRangeArray.h>

#import <DVTKit/DVTFoldingManager.h>
#import <DVTKit/DVTTextFold.h>
#import <DVTKit/DVTLayoutManager.h>
#import <DVTKit/DVTSourceTextView.h>

#import "MPXSelection.h"
#import "MPXSelectionManager.h"
#import "MPXSelectionMutation.h"

@interface MPXSelectionManager ()

@property (nonatomic) DVTSourceTextView *textView;

@property (nonatomic) NSArray<MPXSelection *> *temporarySelections;

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

static NSArray *MPXSortedSelections(NSArray<MPXSelection *> *selections)
{
    return [selections sortedArrayUsingComparator:^NSComparisonResult(MPXSelection *selection,
                                                                      MPXSelection *otherSelection) {
        NSUInteger rangeLocation = selection.range.location;
        NSUInteger otherRangeLocation = otherSelection.range.location;
        
        if (otherRangeLocation > rangeLocation) {
            return NSOrderedAscending;
        } else if (otherRangeLocation < rangeLocation) {
            return NSOrderedDescending;
        }
        
        return NSOrderedSame;
    }];
}

static NSRange MPXSelectionAdjustedAboutToken(MPXSelection *selection,
                                              NSRange tokenRange,
                                              NSSelectionAffinity movementDirection,
                                              BOOL modifySelection)
{
    NSRange originalRange = selection.range;

    if (tokenRange.location == NSNotFound) {
        return originalRange;
    }
    
    NSRange intersection = NSIntersectionRange(originalRange, tokenRange);

    switch (movementDirection) {
        case NSSelectionAffinityUpstream: {
            if (intersection.length > 0 && modifySelection && selection.insertionIndex < NSMaxRange(tokenRange)) {
                return [selection modifySelectionUpstreamByAmount:tokenRange.length - 1];
            } else if (intersection.location != 0 && intersection.length == 0 && NSMaxRange(originalRange) < NSMaxRange(tokenRange)) {
                return NSMakeRange(tokenRange.location, 0);
            }
            
            break;
        }
        case NSSelectionAffinityDownstream: {
            if (intersection.length > 0 && modifySelection && selection.insertionIndex > tokenRange.location) {
                return [selection modifySelectionDownstreamByAmount:tokenRange.length - 1];
            } else if (intersection.location != 0 && intersection.length == 0 && originalRange.location > tokenRange.location) {
                return NSMakeRange(NSMaxRange(tokenRange), 0);
            }

            break;
        }            
    }
    
    return originalRange;
}

- (NSArray *)preprocessedPlaceholderSelectionsForSelections:(NSArray<MPXSelection *> *)selections
                                          movementDirection:(NSSelectionAffinity)movementDirection
                                            modifySelection:(BOOL)modifySelection
{
    // For testing contexts where a textView is not available.
    if (!self.textView) {
        return selections;
    }
    
    return [[[selections rac_sequence] map:^MPXSelection *(MPXSelection *selection) {
        NSRange rangeToAdd = selection.range;
        NSUInteger selectionOrigin = selection.origin;
        
        switch (movementDirection) {
            case NSSelectionAffinityUpstream: {                                
                NSRange leadingPlaceholder = [self.textView rangeOfPlaceholderFromCharacterIndex:selection.insertionIndex
                                                                                         forward:NO
                                                                                            wrap:NO
                                                                                           limit:0];
                                
                rangeToAdd = MPXSelectionAdjustedAboutToken(selection, leadingPlaceholder, movementDirection, modifySelection);
                
                DVTTextFold *fold = [self.textView.layoutManager.foldingManager lastFoldTouchingCharacterIndex:selection.insertionIndex];
                rangeToAdd = MPXSelectionAdjustedAboutToken(selection, fold.range, movementDirection, modifySelection);
                    
                break;
            }
            case NSSelectionAffinityDownstream: {
                NSRange trailingPlaceholder = [self.textView rangeOfPlaceholderFromCharacterIndex:selection.insertionIndex - 1
                                                                                          forward:YES
                                                                                             wrap:NO
                                                                                            limit:0];

                rangeToAdd = MPXSelectionAdjustedAboutToken(selection, trailingPlaceholder, movementDirection, modifySelection);
                
                DVTTextFold *fold = [self.textView.layoutManager.foldingManager firstFoldTouchingCharacterIndex:selection.insertionIndex - 1];
                rangeToAdd = MPXSelectionAdjustedAboutToken(selection, fold.range, movementDirection, modifySelection);

                break;
            }
        }
                
        return [[MPXSelection alloc] initWithSelectionRange:rangeToAdd
                                      indexWantedWithinLine:selection.indexWantedWithinLine
                                                     origin:selectionOrigin];
    }] array];
}

- (NSArray *)fixedSelections:(NSArray<MPXSelection *> *)ranges
{
    NSArray *sortedSelections = MPXSortedSelections(ranges);

    NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
    for (MPXSelection *selection in sortedSelections) {
        if (selection.range.length == 0) {
            continue;
        }

        [indexSet addIndexesInRange:selection.range];
    }


    NSMutableSet *selections = [[NSMutableSet alloc] init];
    [indexSet enumerateRangesUsingBlock:^(NSRange range, BOOL * _Nonnull stop) {

        NSPredicate *sameSelectionPredicate =
        [NSPredicate predicateWithBlock:^BOOL(MPXSelection *_Nonnull potentialMatch,
                                              NSDictionary<NSString *,id> * _Nullable bindings) {
            return NSEqualRanges(potentialMatch.range, range);
        }];

        MPXSelection *existingProvidedSelection = [[ranges filteredArrayUsingPredicate:sameSelectionPredicate] firstObject];
        if (existingProvidedSelection) {
            [selections addObject:existingProvidedSelection];
        } else {
            [selections addObject:[MPXSelection selectionWithRange:range]];
        }
    }];

    for (MPXSelection *selection in sortedSelections) {
        if (selection.range.length == 0
            && ![indexSet containsIndexesInRange:NSMakeRange(selection.range.location, 1)]
            && ![indexSet containsIndexesInRange:NSMakeRange(selection.range.location - 1, 1)]) {

            NSPredicate *sameSelectionPredicate =
            [NSPredicate predicateWithBlock:^BOOL(MPXSelection *_Nonnull potentialMatch,
                                                  NSDictionary<NSString *,id> * _Nullable bindings) {
                return NSEqualRanges(potentialMatch.range, selection.range);
            }];

            MPXSelection *existingProvidedSelection = [[ranges filteredArrayUsingPredicate:sameSelectionPredicate] firstObject];
            if (existingProvidedSelection) {
                [selections addObject:existingProvidedSelection];
            } else {
                [selections addObject:selection];
            }
        }
    }

    return MPXSortedSelections(selections.allObjects);
}

#pragma mark - Display

- (NSArray *)visualSelections
{
    return self.temporarySelections ?: self.finalizedSelections;
}

- (void)setFinalizedSelections:(NSArray<MPXSelection *> *)finalizedSelections
{
    _finalizedSelections = [self fixedSelections:finalizedSelections];
    self.temporarySelections = nil;

    [self.visualizationDelegate selectionManager:self didChangeVisualSelections:self.visualSelections];
}

- (void)setTemporarySelections:(NSArray<MPXSelection *> *)temporarySelections
{
    if (!temporarySelections) {
        _temporarySelections = nil;
        return;
    }
    
    _temporarySelections = [self fixedSelections:temporarySelections];

    [self.visualizationDelegate selectionManager:self didChangeVisualSelections:self.visualSelections];
}

- (void)mapSelectionsWithMovementDirection:(NSSelectionAffinity)movementDirection
                       modifyingSelections:(BOOL)modifySelections
                                usingBlock:(MPXSelectionMutationBlock)mutationBlock;
{
    NSMutableArray<MPXSelection *> *selections = [[NSMutableArray alloc] init];
    NSMutableArray<MPXSelectionMutation *> *processedMutations = [[NSMutableArray alloc] init]; 

    for (MPXSelection *selection in self.finalizedSelections) {
        // Adjust the selection for the mutations that have occurred previously.
        MPXSelection *precedingMutationAdjustedSelection = selection;
        
        for (MPXSelectionMutation *precedingMutation in processedMutations) {
            precedingMutationAdjustedSelection = [precedingMutation adjustTrailingSelection:precedingMutationAdjustedSelection];
        }
        
        MPXSelectionMutation *mutation = mutationBlock(precedingMutationAdjustedSelection);
        [processedMutations addObject:mutation];
        
        [selections addObject:mutation.finalSelection];
    }
    
    // Adjust the selections for placeholders that they may need to include or move around.   
    self.finalizedSelections = [self preprocessedPlaceholderSelectionsForSelections:selections
                                                                  movementDirection:movementDirection
                                                                    modifySelection:modifySelections];
}

@end
