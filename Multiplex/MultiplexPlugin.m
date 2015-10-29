//
//  Multiplex.m
//  Multiplex
//
//  Created by Kolin Krewinkel on 3/9/14.
//  Copyright (c) 2015 Kolin Krewinkel. All rights reserved.
//

#import "DVTSourceTextView+MPXQuickAddNext.h"

#import "MultiplexPlugin.h"

static NSString *kMPXApplicationName = @"Xcode";

@interface MultiplexPlugin ()

@property (nonatomic) NSBundle *bundle;

@end

@implementation MultiplexPlugin

#pragma mark - Instantiation

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    if ([[[NSBundle mainBundle] infoDictionary][(NSString *)kCFBundleNameKey] isEqual:kMPXApplicationName]) {
        [self sharedPluginWithBundle:plugin];
    }
}

#pragma mark - Singleton

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

#pragma mark - Designated Initializer

- (id)initWithBundle:(NSBundle *)bundle
{
    if (self = [self init]) {
        self.bundle = bundle;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(mpx_addQuickAddNextMenuItem:)
                                                     name:NSMenuDidAddItemNotification
                                                   object:nil];
        
    }

    return self;
}

- (void)mpx_addQuickAddNextMenuItem:(NSNotification *)notification
{
    // Make sure there's a menu item to add it to in the first place.
    NSMenu *menu = notification.object;
    NSMenu *findSubmenu = [[menu itemWithTitle:@"Find"] submenu];
    if (!findSubmenu) {
        return;
    }
    
    // Prevent an infinite loop because we'll be adding an item to a menu, setting off another notification.
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSMenuDidAddItemNotification object:nil];
    [DVTSourceTextView mpx_addQuickAddNextMenuItemToSubmenu:findSubmenu];
}

@end
