//
//  IDESourceCodeEditor+CMDViewReplacement.m
//  CommandEdit
//
//  Created by Kolin Krewinkel on 9/25/14.
//  Copyright (c) 2014 Kolin Krewinkel. All rights reserved.
//

#import "IDESourceCodeEditor+CMDViewReplacement.h"

#import "PLYSwizzling.h"
#import "CMDEditorController.h"

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
    return CMDIDESourceCodeEditorOriginalInit(self, @selector(initWithNibName:bundle:document:), nibName, bundle, document);
}

- (void)cmd_loadView
{
    CMDIDESourceCodeEditorOriginalLoadView(self, @selector(loadView));

    [self.view.subviews enumerateObjectsUsingBlock:^(NSView *subview, NSUInteger idx, BOOL *stop) {
        [subview removeFromSuperview];
    }];

    [self.view addSubview:[[CMDEditorController alloc] initWithFrame:self.view.bounds document:self.sourceCodeDocument]];
}

@end
