//
//  CATNextNavigator.m
//  Catalyst
//
//  Created by Kolin Krewinkel on 11/21/14.
//  Copyright (c) 2014 Kolin Krewinkel. All rights reserved.
//

#import <INPopoverController/INPopoverController.h>

@import AppKit;

#import "CATNextNavigator.h"

@interface CATNextNavigator ()

@property (nonatomic) NSView *targetView;
@property (nonatomic) CGRect targetRect;

@end

@implementation CATNextNavigator

#pragma mark -
#pragma mark Designated Initializer

- (instancetype)initWithView:(NSView *)view targetRect:(CGRect)targetRect
{
    if ((self = [super init]))
    {
        self.targetView = view;
        self.targetRect = targetRect;
    }

    return self;
}

- (void)show:(BOOL)animated
{
    self.targetView.wantsLayer = YES;

    CGFloat width = 320.f;
    CGRect rect = CGRectMake(0.f, 0.f, width, 400.f);

    NSViewController *viewController = [[NSViewController alloc] init];
    viewController.view = ({
        NSView *view = [[NSView alloc] initWithFrame:rect];
        view.wantsLayer = YES;
        view.layer.backgroundColor = [[NSColor clearColor] CGColor];
        view;
    });

    CGRect targetRect = self.targetRect;

    INPopoverController *controller = [[INPopoverController alloc] initWithContentViewController:viewController];
    [controller presentPopoverFromRect:self.targetRect inView:self.targetView preferredArrowDirection:INPopoverArrowDirectionUp anchorsToPositionView:YES];

    NSView *view = [[NSView alloc] initWithFrame:targetRect];
    view.wantsLayer = YES;
    view.layer.backgroundColor = [[NSColor redColor] CGColor];
    [self.targetView addSubview:view];

    NSLog(@"%@", NSStringFromRect(targetRect));
}

@end
