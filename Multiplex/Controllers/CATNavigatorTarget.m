//
//  CATNavigatorTarget.m
//  Multiplex
//
//  Created by Kolin Krewinkel on 11/23/14.
//  Copyright (c) 2014 Kolin Krewinkel. All rights reserved.
//

#import "CATNavigatorTarget.h"

@implementation CATNavigatorTarget

#pragma mark -
#pragma mark Designated Initializer

- (instancetype)initWithRect:(CGRect)rect
                   modelItem:(DVTSourceModelItem *)modelItem
{
    if ((self = [self init]))
    {
        self.rect = rect;
        self.modelItem = modelItem;
    }

    return self;
}

@end
