//
//  CATNextNavigator.h
//  Catalyst
//
//  Created by Kolin Krewinkel on 11/21/14.
//  Copyright (c) 2014 Kolin Krewinkel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CATNextNavigator : NSObject

@property (nonatomic, readonly) NSView *targetView;

#pragma mark - Designated Initializer

- (instancetype)initWithView:(NSView *)view symbol:(id)symbol;

#pragma mark -

- (void)show:(BOOL)animated;

@end
