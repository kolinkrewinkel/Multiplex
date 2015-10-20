//
//  MPXSelectionManager.h
//  Multiplex
//
//  Created by Kolin Krewinkel on 8/23/15.
//  Copyright © 2015 Kolin Krewinkel. All rights reserved.
//

@class MPXSelectionMutation;
typedef MPXSelectionMutation *(^MPXSelectionMutationBlock)(MPXSelection *selectionToModify);

@import Foundation;

@class MPXSelectionManager;
@protocol MPXSelectionManagerVisualizationDelegate <NSObject>

/**
 * Called when the visual selections that are to be used are changed.
 */
- (void)selectionManager:(MPXSelectionManager *)selectionManager didChangeVisualSelections:(NSArray<MPXSelection *> *)visualSelections;

@end

@class DVTSourceTextView;

/**
 * Handles deduplication and temporary modifications of selections along with the nuances of making sure selection-range
 * doesn't fall within the bounds of a token, etc.
 */
@interface MPXSelectionManager : NSObject

#pragma mark - Initialization

- (instancetype)initWithTextView:(DVTSourceTextView *)textView;

#pragma mark - Visualization

/**
 * @return Selections which should be rendered onscreen.
 */
@property (nonatomic, readonly) NSArray<MPXSelection *> *visualSelections;

/**
 * Essentially a listener for changes to `visualSelections`.
 */
@property (nonatomic, weak) id<MPXSelectionManagerVisualizationDelegate> visualizationDelegate;

#pragma mark - State

/**
 * @return Selections which are finalized and not subject to mutation.
 */
@property (nonatomic) NSArray<MPXSelection *> *finalizedSelections;

/**
 * Allows clients to temporarily alter the display attributes before a change to the selections is finalized.
 */
- (void)setTemporarySelections:(NSArray<MPXSelection *> *)temporarySelections;

/**
 * Should be called before setting/applying a selection to make sure that placeholders are properly moved around or 
 * included.
 */
- (NSArray *)preprocessedPlaceholderSelectionsForSelections:(NSArray<MPXSelection *> *)selections
                                          movementDirection:(NSSelectionAffinity)movementDirection
                                            modifySelection:(BOOL)modifySelection;

/**
 * Preferred method of remapping selections to automatically handle offsetting.
 */
- (void)mapSelectionsWithMovementDirection:(NSSelectionAffinity)movementDirection
                       modifyingSelections:(BOOL)modifySelections
                                usingBlock:(MPXSelectionMutationBlock)mutationBlock;

NSRange MPXSelectionAdjustedAboutToken(MPXSelection *selection,
                                       NSRange tokenRange,
                                       NSSelectionAffinity movementDirection,
                                       BOOL modifySelection);

@end
