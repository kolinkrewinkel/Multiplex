//
//  CATNavigatorTarget.h
//  Multiplex
//
//  Created by Kolin Krewinkel on 11/23/14.
//  Copyright (c) 2014 Kolin Krewinkel. All rights reserved.
//

#import "DVTInterfaces.h"

@interface CATNavigatorTarget : NSObject

#pragma mark -
#pragma mark Designated Initializer

- (instancetype)initWithRect:(CGRect)rect
                   modelItem:(DVTSourceModelItem *)modelItem;

#pragma mark -
#pragma mark Attributes

@property (nonatomic) CGRect rect;
@property (nonatomic) DVTSourceModelItem *modelItem;

@end
