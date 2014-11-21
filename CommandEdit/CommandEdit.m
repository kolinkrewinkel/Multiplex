//
//  CommandEdit.m
//  CommandEdit
//
//  Created by Kolin Krewinkel on 3/9/14.
//  Copyright (c) 2014 Kolin Krewinkel. All rights reserved.
//

#import "CommandEdit.h"

@interface CommandEdit()

@property (nonatomic, strong) NSBundle *bundle;

@property (nonatomic, strong) NSMenuItem *enableItem;

@end

@implementation CommandEdit

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];

    if ([currentApplicationName isEqual:@"Xcode"])
    {
        [self sharedPluginWithBundle:plugin];
    }
}

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

- (id)initWithBundle:(NSBundle *)bundle
{
    if ((self = [super init]))
    {
        self.bundle = bundle;
    }

    return self;
}

@end
