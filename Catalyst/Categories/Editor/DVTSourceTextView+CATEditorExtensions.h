//
//  DVTSourceTextView+CATEditorExtensions.h
//  Catalyst
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

@class CATNextNavigator;
@class CATSelectionRange;

@interface DVTSourceTextView (CATEditorExtensions)

#pragma mark -
#pragma mark Keyboard-based Navigation

@property (nonatomic) CATNextNavigator *cat_nextNavigator;

#pragma mark -
#pragma mark Multiple Selection

@property (nonatomic) NSArray *cat_selectedRanges;

#pragma mark Vertical-bar Drawing

@property (nonatomic) NSTimer *cat_blinkTimer;
@property (nonatomic) BOOL cat_blinkState;
@property (nonatomic) NSDictionary *cat_selectionViews;

#pragma mark Mutation States

@property (nonatomic) NSArray *cat_finalizingRanges;

@property (nonatomic) CATSelectionRange *cat_rangeInProgress;
@property (nonatomic) CATSelectionRange *cat_rangeInProgressStart;

@end
