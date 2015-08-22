//
//  Multiplex.h
//  Multiplex
//
//  Created by Kolin Krewinkel on 3/9/14.
//  Copyright (c) 2014 Kolin Krewinkel. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface MultiplexPlugin : NSObject

#pragma mark - Singleton

+ (instancetype)sharedPlugin;

@end
