//
//  DVTSourceTextView+MPXEditorExtensions.h
//  Multiplex
//
//  Created by Kolin Krewinkel on 9/25/14.
//  Copyright (c) 2014 Kolin Krewinkel. All rights reserved.
//

#import <DVTKit/DVTSourceTextView.h>

typedef NS_ENUM(NSInteger, CATRelativePosition) {
    CATRelativePositionTop,
    CATRelativePositionLeft,
    CATRelativePositionRight,
    CATRelativePositionBottom
};

@class MPXEditorSelectionBridge;
@class MPXSelection;
@class MPXSelectionManager;

@interface DVTSourceTextView (MPXEditorExtensions)

- (void)mpx_mapAndFinalizeSelectedRanges:(MPXSelection * (^)(MPXSelection *selection))mapBlock;
- (void)mpx_mapAndFinalizeSelectedRanges:(MPXSelection * (^)(MPXSelection *selection))mapBlock
                  sequentialModification:(BOOL)sequentialModification;

- (void)mpx_commonInitDVTSourceTextView;

- (BOOL)mpx_validateMenuItem:(NSMenuItem *)menuItem;

- (BOOL)mpx_shouldTrimTrailingWhitespace;

#pragma mark - Selection Management Core

@property (nonatomic) MPXSelectionManager *mpx_selectionManager;
@property (nonatomic) MPXEditorSelectionBridge *mpx_textViewSelectionBridge;

@property (nonatomic) BOOL mpx_shouldCloseGroupOnNextChange;
@property (nonatomic) BOOL mpx_inUndoGroup;

@property (nonatomic) BOOL mpx_trimTrailingWhitespace;


@end
