//
//  CMDTextEditor.m
//  CommandEdit
//
//  Created by Kolin Krewinkel on 9/25/14.
//  Copyright (c) 2014 Kolin Krewinkel. All rights reserved.
//

#import "CMDTextEditor.h"

#import "CMDTextRange.h"

@interface CMDTextEditor ()


@end

@implementation CMDTextEditor

- (instancetype)initWithTextStorage:(DVTTextStorage *)textStorage
{
    if ((self = [super initWithFrame:CGRectZero]))
    {
//        self.layout
        [self.layoutManager replaceTextStorage:textStorage];
    }

    return self;
}

@end
