//
//  CMDTextRange.m
//  CommandEdit
//
//  Created by Kolin Krewinkel on 9/25/14.
//  Copyright (c) 2014 Kolin Krewinkel. All rights reserved.
//

#import "CMDTextRange.h"

@interface CMDTextRange ()

@property (nonatomic) NSRange range;

@end

@implementation CMDTextRange

+ (instancetype)textRange:(NSRange)range
{
    CMDTextRange *instance = [[self alloc] init];
    instance.range = range;

    return instance;
}

@end
