//
//  CMDEditorController.m
//  CommandEdit
//
//  Created by Kolin Krewinkel on 9/25/14.
//  Copyright (c) 2014 Kolin Krewinkel. All rights reserved.
//

#import "CMDEditorController.h"

#import "DVTInterfaces.h"
#import "CMDTextEditor.h"

@interface CMDEditorController ()

@property (nonatomic) CMDTextEditor *editor;
@property (nonatomic) NSScrollView *scrollView;

@end

@implementation CMDEditorController

- (instancetype)initWithFrame:(NSRect)frameRect document:(IDESourceCodeDocument *)document
{
    if ((self = [super initWithFrame:frameRect]))
    {
        self.wantsLayer = YES;

        self.editor = [[CMDTextEditor alloc] initWithTextStorage:document.textStorage];

        self.scrollView = [[NSScrollView alloc] init];
        self.scrollView.hasVerticalScroller = YES;
        self.scrollView.documentView = self.editor;
        [self addSubview:self.scrollView];
    }

    return self;
}

- (void)layout
{
    self.scrollView.frame = self.bounds;

    self.editor.frame = (CGRect){.size = [self.editor sizeThatFits:self.frame.size]};

    [super layout];
}

@end
