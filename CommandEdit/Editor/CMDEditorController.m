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

@interface CMDEditorController () <NSTextViewDelegate>

@property (nonatomic) CMDTextEditor *editor;
@property (nonatomic) NSScrollView *scrollView;

@end

@implementation CMDEditorController

- (instancetype)initWithFrame:(NSRect)frameRect document:(IDESourceCodeDocument *)document
{
    if ((self = [super initWithFrame:frameRect]))
    {
        self.wantsLayer = YES;

        self.scrollView = [[NSScrollView alloc] init];
        self.scrollView.hasVerticalScroller = YES;
        [self addSubview:self.scrollView];

        self.editor = [[CMDTextEditor alloc] initWithTextStorage:document.textStorage];
        self.editor.delegate = self;
        [self.editor setMinSize:NSMakeSize(0.0, 0.f)];
        [self.editor setMaxSize:NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX)];
        [self.editor setVerticallyResizable:YES];
        [self.editor setHorizontallyResizable:NO];
        [self.editor setAutoresizingMask:NSViewWidthSizable];

        self.scrollView.documentView = self.editor;

        [self.editor setSelectedRanges:@[[NSValue valueWithRange:NSMakeRange(3, 0)]] affinity:NSSelectionAffinityDownstream stillSelecting:YES];

        [self.editor becomeFirstResponder];
    }

    return self;
}

- (void)layout
{
    [[self.editor textContainer] setContainerSize:NSMakeSize(self.scrollView.frame.size.width, CGFLOAT_MAX)];
    self.scrollView.frame = self.bounds;

    [super layout];
}

- (void)textViewDidChangeSelection:(NSNotification *)notification
{
    NSLog(@"%@", self.editor.selectedRanges);
}

@end
