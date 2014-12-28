//
//  DVTSourceTextView+CATEditorExtensions.h
//  Catalyst
//
//  Created by Kolin Krewinkel on 9/25/14.
//  Copyright (c) 2014 Kolin Krewinkel. All rights reserved.
//

#import "DVTInterfaces.h"
#import "CATNextNavigator.h"

@interface DVTSourceTextView (CATEditorExtensions)


@property (nonatomic) NSUInteger lineCursorIndexMaximum;

@property (nonatomic) CATNextNavigator *cat_nextNavigator;

@property (nonatomic) NSArray *cat_selectedRanges;

@property (nonatomic) NSTimer *cat_blinkTimer;
@property (nonatomic) BOOL cat_blinkState;
@property (nonatomic) NSDictionary *cat_selectionViews;

@property (nonatomic) NSValue *cat_rangeInProgress;
@property (nonatomic) NSValue *cat_rangeInProgressStart;

@property (nonatomic) NSArray *cat_finalizingRanges;

@end
