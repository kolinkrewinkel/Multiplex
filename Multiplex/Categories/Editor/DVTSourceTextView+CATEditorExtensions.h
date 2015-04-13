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

@class MPXSelection;

@interface DVTSourceTextView (CATEditorExtensions)

#pragma mark -
#pragma mark Multiple Selection

@property (nonatomic) NSArray *cat_selectedRanges;

#pragma mark -
#pragma mark Vertical-bar Drawing

@property (nonatomic) NSTimer *cat_blinkTimer;
@property (nonatomic) BOOL cat_blinkState;
@property (nonatomic) NSArray *cat_selectionViews;

#pragma mark -
#pragma mark Mutation States

@property (nonatomic) NSArray *cat_finalizingRanges;

@property (nonatomic) MPXSelection *cat_rangeInProgress;
@property (nonatomic) MPXSelection *cat_rangeInProgressStart;

@end
