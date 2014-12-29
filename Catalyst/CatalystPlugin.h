//
//  Catalyst.h
//  Catalyst
//
//  Created by Kolin Krewinkel on 3/9/14.
//  Copyright (c) 2014 Kolin Krewinkel. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface CatalystPlugin : NSObject

#pragma mark -
#pragma mark Singleton

+ (instancetype)sharedPlugin;

@end