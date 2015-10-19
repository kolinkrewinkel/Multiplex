//
//  DVTSourceTextView+MPXEditorExtensions.h
//  Multiplex
//
//  Created by Kolin Krewinkel on 9/25/14.
//  Copyright (c) 2015 Kolin Krewinkel. All rights reserved.
//

extern NSString *kMPXQuickAddNextMenuItemTitle;

#import <DVTKit/DVTSourceTextView.h>

@class MPXSelection;
@class MPXSelectionManager;

@interface DVTSourceTextView (MPXEditorExtensions)

- (void)mpx_mapAndFinalizeSelectedRanges:(MPXSelection * (^)(MPXSelection *selection))mapBlock;
- (void)mpx_mapAndFinalizeSelectedRanges:(MPXSelection * (^)(MPXSelection *selection))mapBlock
                  sequentialModification:(BOOL)sequentialModification
             modifyingExistingSelections:(BOOL)modifySelection
                       movementDirection:(NSSelectionAffinity)movementDirection;

- (void)mpx_commonInitDVTSourceTextView;
+ (void)mpx_addQuickAddNextMenuItem;

- (void)mpx_indentSelection:(id)sender;

- (BOOL)mpx_validateMenuItem:(NSMenuItem *)menuItem;

- (BOOL)mpx_shouldTrimTrailingWhitespace;
- (void)mpx_trimTrailingWhitespaceOnLine:(NSUInteger)line;

#pragma mark - Selection Management Core

@property (nonatomic) MPXSelectionManager *mpx_selectionManager;

@property (nonatomic) BOOL mpx_shouldCloseGroupOnNextChange;
@property (nonatomic) BOOL mpx_inUndoGroup;

@property (nonatomic) BOOL mpx_trimTrailingWhitespace;


@end
