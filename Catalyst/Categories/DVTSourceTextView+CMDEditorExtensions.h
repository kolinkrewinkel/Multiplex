//
//  DVTSourceTextView+CMDEditorExtensions.h
//  Catalyst
//
//  Created by Kolin Krewinkel on 9/25/14.
//  Copyright (c) 2014 Kolin Krewinkel. All rights reserved.
//

#import "DVTInterfaces.h"
#import "CATNextNavigator.h"

@interface DVTSourceTextView (CMDEditorExtensions)

@property (nonatomic) CATNextNavigator *cmd_nextNavigator;

@property (nonatomic) NSArray *cmd_selectedRanges;

@property (nonatomic) NSTimer *cmd_blinkTimer;
@property (nonatomic) BOOL cmd_blinkState;
@property (nonatomic) NSDictionary *cmd_selectionViews;

@property (nonatomic) NSValue *cmd_rangeInProgress;
@property (nonatomic) NSValue *cmd_rangeInProgressStart;

@property (nonatomic) NSArray *cmd_finalizingRanges;

@end
