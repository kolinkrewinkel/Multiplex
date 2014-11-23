//
//  Catalyst.m
//  Catalyst
//
//  Created by Kolin Krewinkel on 3/9/14.
//  Copyright (c) 2014 Kolin Krewinkel. All rights reserved.
//

#import "CatalystPlugin.h"

static NSString *kCATApplicationName = @"Xcode";

@interface CatalystPlugin ()

@property (nonatomic) NSBundle *bundle;

@end

@implementation CatalystPlugin

#pragma mark -
#pragma mark Instantiation

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][(NSString *)kCFBundleNameKey];

    if ([currentApplicationName isEqual:kCATApplicationName])
    {
        [self sharedPluginWithBundle:plugin];
    }
}

#pragma mark -
#pragma mark Singleton

+ (instancetype)sharedPluginWithBundle:(NSBundle *)bundle
{
    static id sharedPlugin = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        sharedPlugin = [[self alloc] initWithBundle:bundle];
    });

    return sharedPlugin;
}

+ (instancetype)sharedPlugin
{
    return [self sharedPluginWithBundle:nil];
}

#pragma mark -
#pragma mark Designated Initializer

- (id)initWithBundle:(NSBundle *)bundle
{
    if ((self = [self init]))
    {
        self.bundle = bundle;
    }

    return self;
}

@end
