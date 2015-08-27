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

@class MPXSelection;
@class MPXSelectionManager;
@class MPXTextViewSelectionDecorator;

@interface DVTSourceTextView (MPXEditorExtensions)

#pragma mark - Selection Management Core

@property (nonatomic) MPXSelectionManager *mpx_selectionManager;
@property (nonatomic) MPXTextViewSelectionDecorator *mpx_textViewSelectionDecorator;

@property (nonatomic) NSTimer *mpx_definitionLongPressTimer;

@property (nonatomic) BOOL mpx_shouldCloseGroupOnNextChange;
@property (nonatomic) BOOL mpx_inUndoGroup;

#pragma mark - Mutation States

@property (nonatomic) MPXSelection *mpx_rangeInProgress;
@property (nonatomic) MPXSelection *mpx_rangeInProgressStart;

@end
