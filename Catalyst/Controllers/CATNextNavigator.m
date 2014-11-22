//
//  CATNextNavigator.m
//  Catalyst
//
//  Created by Kolin Krewinkel on 11/21/14.
//  Copyright (c) 2014 Kolin Krewinkel. All rights reserved.
//

@import AppKit;

#import "CATNextNavigator.h"

@interface CATNextNavigator ()

@property (nonatomic) NSView *targetView;

@end

@implementation CATNextNavigator

#pragma mark - Designated Initializer

- (instancetype)initWithView:(NSView *)view symbol:(id)symbol
{
    if ((self = [super init]))
    {
        self.targetView = view;
    }

    return self;
}

- (void)show:(BOOL)animated
{
    self.targetView.wantsLayer = YES;

    CGFloat width = 320.f;
    CGRect rect = CGRectMake(self.targetView.frame.size.width - width, 0.f, width, CGRectGetHeight(self.targetView.frame));
    NSLog(@"%@", NSStringFromRect(rect));

    NSView *navigatorView = [[NSView alloc] initWithFrame:rect];
    navigatorView.wantsLayer = YES;
    navigatorView.layer.backgroundColor = [[NSColor colorWithCalibratedWhite:0.1f alpha:1.f] CGColor];

    [self.targetView addSubview:navigatorView];
}

@end
