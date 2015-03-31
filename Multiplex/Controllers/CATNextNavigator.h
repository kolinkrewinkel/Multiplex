//
//  CATNextNavigator.h
//  Multiplex
//
//  Created by Kolin Krewinkel on 11/21/14.
//  Copyright (c) 2014 Kolin Krewinkel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CATNextNavigator : NSObject

@property (nonatomic, readonly) NSView *targetView;

#pragma mark - Designated Initializer

- (instancetype)initWithView:(NSView *)view targetItems:(NSArray *)targetItems layoutManager:(NSLayoutManager *)layoutManager;

#pragma mark -

- (void)showItems:(NSArray *)items;

@end
