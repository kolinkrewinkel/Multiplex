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

- (void)toggleEnabled:(id)sender
{
    BOOL newValue = ![[NSUserDefaults standardUserDefaults] boolForKey:@"PLYPluginEnabled"];
    [[NSUserDefaults standardUserDefaults] setBool:newValue forKey:@"PLYPluginEnabled"];

    [self.enableItem setState:newValue ? NSOnState : NSOffState];
}

- (void)modifyEditorMenu:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMenuItem *editorMenuItem = [[NSApp mainMenu] itemWithTitle:@"Editor"];

        if ([editorMenuItem.submenu itemWithTitle:@"CommandEdit"])
        {
            return;
        }

        NSMenu *CommandEditMenu = [[NSMenu alloc] initWithTitle:@"CommandEdit"];
        NSMenuItem *menuItem = [[NSMenuItem alloc] init];
        menuItem.title = @"CommandEdit";

        NSMenuItem *installItem = [[NSMenuItem alloc] initWithTitle:@"Install Sample Themes" action:@selector(showInstallWindow:) keyEquivalent:@"I"];
        installItem.target = self;
        [CommandEditMenu addItem:installItem];

        self.enableItem = [[NSMenuItem alloc] initWithTitle:@"Enabled" action:@selector(toggleEnabled:) keyEquivalent:@"E"];

        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"PLYPluginEnabled"])
        {
            [self.enableItem setState:NSOnState];
        }

        self.enableItem.target = self;
        [CommandEditMenu addItem:self.enableItem];


        menuItem.submenu = CommandEditMenu;
        [editorMenuItem.submenu addItem:[NSMenuItem separatorItem]];
        [editorMenuItem.submenu addItem:menuItem];
    });
}

- (BOOL)pluginEnabled
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"PLYPluginEnabled"];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    return YES;
}

@end
