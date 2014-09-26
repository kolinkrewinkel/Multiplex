//
//  IDESourceCodeEditor+CMDViewReplacement.m
//  CommandEdit
//
//  Created by Kolin Krewinkel on 9/25/14.
//  Copyright (c) 2014 Kolin Krewinkel. All rights reserved.
//

#import "IDESourceCodeEditor+CMDViewReplacement.h"

#import "PLYSwizzling.h"

static IMP CMDIDESourceCodeEditorOriginalInit = nil;
static IMP CMDIDESourceCodeEditorOriginalLoadView = nil;

@implementation IDESourceCodeEditor (CMDViewReplacement)

+ (void)load
{
    CMDIDESourceCodeEditorOriginalInit = PLYPoseSwizzle(self, @selector(initWithNibName:bundle:document:), self, @selector(cmd_initWithNibName:bundle:document:), YES);
    CMDIDESourceCodeEditorOriginalLoadView = PLYPoseSwizzle(self, @selector(loadView), self, @selector(cmd_loadView), YES);
}

- (instancetype)cmd_initWithNibName:(id)nibName bundle:(id)bundle document:(id)document
{
    NSAlert *alert = [NSAlert alertWithMessageText:@"test" defaultButton:@"dismiss" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Nib name: %@\nBundle: %@\nDocument: %@\n", nibName, bundle, document];
    [alert runModal];

    return CMDIDESourceCodeEditorOriginalInit(self, @selector(initWithNibName:bundle:document:), nibName, bundle, document);
}

- (void)cmd_loadView
{
    CMDIDESourceCodeEditorOriginalLoadView(self, @selector(loadView));

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view.subviews enumerateObjectsUsingBlock:^(NSView *subview, NSUInteger idx, BOOL *stop) {
            [subview removeFromSuperview];
        }];

        [self.view addSubview:({
            NSView *view = [[NSView alloc] initWithFrame:self.view.bounds];
            view.wantsLayer = YES;
            view.layer.backgroundColor = [[NSColor purpleColor] CGColor];
            view;
        })];
    });
}

@end
