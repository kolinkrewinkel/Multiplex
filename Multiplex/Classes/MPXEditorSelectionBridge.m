//
//  MPXEditorSelectionBridge.m
//  Multiplex
//
//  Created by Kolin Krewinkel on 8/31/15.
//  Copyright © 2015 Kolin Krewinkel. All rights reserved.
//

@import AppKit;

#import <DVTKit/DVTSourceTextView.h>

#import "MPXEditorSelectionBridge.h"

@interface MPXEditorSelectionBridge ()

@property (nonatomic) DVTSourceTextView *textView;

@end

@implementation MPXEditorSelectionBridge

#pragma mark - Initialization

- (instancetype)initWithTextView:(DVTSourceTextView *)textView
{
    if (self = [super init]) {
    }

    return self;
}

@end
