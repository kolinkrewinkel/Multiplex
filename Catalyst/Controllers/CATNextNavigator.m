//
//  CATNextNavigator.m
//  Catalyst
//
//  Created by Kolin Krewinkel on 11/21/14.
//  Copyright (c) 2014 Kolin Krewinkel. All rights reserved.
//

@import AppKit;
#import "DVTInterfaces.h"
#import <INPopoverController/INPopoverController.h>
#import <pop/POP.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

#import "CATNavigatorTarget.h"
#import "CATNextNavigator.h"
#import "CATActionViewController.h"

@interface CATNextNavigator () <INPopoverControllerDelegate>

@property (nonatomic) NSView *targetView;
@property (nonatomic) NSArray *targetItems;
@property (nonatomic) NSLayoutManager *layoutManager;

@end

@implementation CATNextNavigator

#pragma mark -
#pragma mark Designated Initializer

- (instancetype)initWithView:(NSView *)view
                 targetItems:(NSArray *)targetItems
               layoutManager:(NSLayoutManager *)layoutManager
{
    if ((self = [super init]))
    {
        self.targetView = view;
        self.targetItems = targetItems;
        self.layoutManager = layoutManager;
    }

    return self;
}

- (void)cycleForward
{

}

- (void)cycleBackwards
{

}

- (void)showItems:(NSArray *)items
{
    if ([items count] == 0)
    {
        return;
    }

    CGFloat width = 320.f;
    CGRect rect = CGRectMake(0.f, 0.f, width, 400.f);

    CATActionViewController *viewController = [[CATActionViewController alloc] init];

    INPopoverController *controller = [[INPopoverController alloc] initWithContentViewController:viewController];
    controller.animates = NO;
    controller.delegate = self;

    [items enumerateObjectsUsingBlock:^(CATNavigatorTarget *target, NSUInteger idx, BOOL *stop)
    {
        [self.layoutManager addTemporaryAttributes:@{NSBackgroundColorAttributeName: [[DVTFontAndColorTheme currentTheme] sourceTextTokenizedBackgroundColor]} forCharacterRange:target.modelItem.range];
    }];

    [[self rac_signalForSelector:@selector(popoverDidClose:)
                    fromProtocol:@protocol(INPopoverControllerDelegate)] subscribeNext:^(id x)
    {
        [items enumerateObjectsUsingBlock:^(CATNavigatorTarget *target, NSUInteger idx, BOOL *stop) {
            [self.layoutManager removeTemporaryAttribute:NSBackgroundColorAttributeName forCharacterRange:target.modelItem.range];
        }];
    }];

    CGRect popoverTargetRect = CGRectZero;
    if ([items count] > 1)
    {
        popoverTargetRect = CGRectMake(CGRectGetWidth(self.targetView.frame),
                                       CGRectGetHeight(self.targetView.frame) * 0.5f,
                                       0.f,
                                       0.f);
    }
    else
    {
        CATNavigatorTarget *target = [items lastObject];
        popoverTargetRect = target.rect;
    }

    [controller presentPopoverFromRect:popoverTargetRect inView:self.targetView preferredArrowDirection:INPopoverArrowDirectionUndefined anchorsToPositionView:YES];
}

@end
