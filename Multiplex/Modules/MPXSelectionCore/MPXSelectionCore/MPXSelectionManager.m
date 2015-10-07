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
#import "MPXSelectionMutation.h"

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

- (NSArray *)preprocessedPlaceholderSelectionsForSelections:(NSArray *)selections
                                          movementDirection:(NSSelectionAffinity)movementDirection
                                            modifySelection:(BOOL)modifySelection
{
    // For testing contexts where a textView is not available.
    if (!self.textView) {
        return selections;
    }
    
    return [[[selections rac_sequence] map:^MPXSelection *(MPXSelection *selection) {
        NSRange range1 = [selection range];
        NSRange rangeToAdd = range1;
        NSUInteger selectionOrigin = selection.origin;
        
        switch (movementDirection) {
            case NSSelectionAffinityUpstream: {
                NSRange leadingPlaceholder = [self.textView rangeOfPlaceholderFromCharacterIndex:selection.insertionIndex
                                                                                         forward:NO
                                                                                            wrap:NO
                                                                                           limit:0];

                if (leadingPlaceholder.location != NSNotFound) {
                    NSRange intersection = NSIntersectionRange(rangeToAdd, leadingPlaceholder);
                    if (intersection.length > 0 && modifySelection && selection.insertionIndex < NSMaxRange(leadingPlaceholder)) {
                        rangeToAdd = [selection modifySelectionUpstreamByAmount:leadingPlaceholder.length - 1];
                    } else if (intersection.location != 0 && intersection.length == 0 && NSMaxRange(rangeToAdd) < NSMaxRange(leadingPlaceholder)) {
                        rangeToAdd = NSMakeRange(leadingPlaceholder.location, 0);
                    }
                }
                
                break;
            }
            case NSSelectionAffinityDownstream: {
                NSRange trailingPlaceholder = [self.textView rangeOfPlaceholderFromCharacterIndex:selection.insertionIndex - 1
                                                                                          forward:YES
                                                                                             wrap:NO
                                                                                            limit:0];

                if (trailingPlaceholder.location != NSNotFound) {
                    NSRange intersection = NSIntersectionRange(rangeToAdd, trailingPlaceholder);
                    if (intersection.length > 0 && modifySelection && selection.insertionIndex > trailingPlaceholder.location) {
                        rangeToAdd = [selection modifySelectionDownstreamByAmount:trailingPlaceholder.length - 1];
                    } else if (intersection.location != 0 && intersection.length == 0 && rangeToAdd.location > trailingPlaceholder.location) {
                        rangeToAdd = NSMakeRange(NSMaxRange(trailingPlaceholder), 0);
                    }
                }

                break;
            }
        }
                                     
        return [[MPXSelection alloc] initWithSelectionRange:rangeToAdd
                                      indexWantedWithinLine:selection.indexWantedWithinLine
                                                     origin:selectionOrigin];
    }] array];
}

- (NSArray *)fixedSelections:(NSArray *)ranges
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

- (void)setFinalizedSelections:(NSArray *)finalizedSelections
{
    _finalizedSelections = [self fixedSelections:finalizedSelections];
    self.temporarySelections = nil;

    [self.visualizationDelegate selectionManager:self didChangeVisualSelections:self.visualSelections];
    [self.selectionDelegate selectionManager:self didChangeVisualSelections:self.visualSelections];
}

- (void)setTemporarySelections:(NSArray *)temporarySelections
{
    if (!temporarySelections) {
        _temporarySelections = nil;
        return;
    }
    
    _temporarySelections = [self fixedSelections:temporarySelections];

    [self.visualizationDelegate selectionManager:self didChangeVisualSelections:self.visualSelections];
    [self.selectionDelegate selectionManager:self didChangeVisualSelections:self.visualSelections];
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
            precedingMutationAdjustedSelection = [precedingMutation adjustTrailingSelection:selection];
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
