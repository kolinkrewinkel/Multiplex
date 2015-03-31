//
//  DVTSourceTextView+CATEditorExtensions.h
//  Multiplex
//
//  Created by Kolin Krewinkel on 9/25/14.
//  Copyright (c) 2014 Kolin Krewinkel. All rights reserved.
//

#import "DVTInterfaces.h"

typedef NS_ENUM(NSInteger, CATRelativePosition) {
    CATRelativePositionTop,
    CATRelativePositionLeft,
    CATRelativePositionRight,
    CATRelativePositionBottom
};

@class CATSelectionRange;

@interface DVTSourceTextView (CATEditorExtensions)

#pragma mark -
#pragma mark Multiple Selection

@property (nonatomic, readonly) NSArray *cat_selectedRanges;

#pragma mark -
#pragma mark Vertical-bar Drawing

@property (nonatomic, readonly) NSTimer *cat_blinkTimer;
@property (nonatomic, readonly) BOOL cat_blinkState;
@property (nonatomic, readonly) NSArray *cat_selectionViews;

#pragma mark -
#pragma mark Mutation States

@property (nonatomic, readonly) NSArray *cat_finalizingRanges;

@property (nonatomic, readonly) CATSelectionRange *cat_rangeInProgress;
@property (nonatomic, readonly) CATSelectionRange *cat_rangeInProgressStart;

@end
