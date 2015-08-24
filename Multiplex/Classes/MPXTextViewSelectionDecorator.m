//
//  MPXTextViewSelectionDecorator.m
//  Multiplex
//
//  Created by Kolin Krewinkel on 8/23/15.
//  Copyright © 2015 Kolin Krewinkel. All rights reserved.
//

#import <DVTKit/DVTSourceTextView.h>

#import "MPXTextViewSelectionDecorator.h"

@interface MPXTextViewSelectionDecorator ()

@property (nonatomic) DVTSourceTextView *textView;

@end

@implementation MPXTextViewSelectionDecorator

#pragma mark - Initialization

- (instancetype)initWithTextView:(DVTSourceTextView *)textView
{
    if (self = [super init]) {
        self.textView = textView;
    }

    return self;
}

#pragma mark - MPXSelectionManagerVisualizationDelegate

- (void)selectionManager:(MPXSelectionManager *)selectionManager didChangeVisualSelections:(NSArray *)visualSelections
{
    
}

@end
