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

@interface DVTSourceTextView (MPXEditorExtensions)

#pragma mark - Vertical-bar Drawing

@property (nonatomic) NSTimer *mpx_blinkTimer;
@property (nonatomic) BOOL mpx_blinkState;
@property (nonatomic) NSArray *mpx_selectionViews;

#pragma mark - Mutation States

@property (nonatomic) MPXSelectionManager *mpx_selectionManager;
@property (nonatomic) MPXSelection *mpx_rangeInProgress;
@property (nonatomic) MPXSelection *mpx_rangeInProgressStart;

@end
