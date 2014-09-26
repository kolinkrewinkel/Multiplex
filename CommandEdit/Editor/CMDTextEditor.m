//
//  CMDTextEditor.m
//  CommandEdit
//
//  Created by Kolin Krewinkel on 9/25/14.
//  Copyright (c) 2014 Kolin Krewinkel. All rights reserved.
//

#import "CMDTextEditor.h"

#import "CMDTextRange.h"

@interface CMDTextEditor ()

@property (nonatomic) NSArray *selectedRanges;
@property (nonatomic) NSArray *selectionViews;

@end

@implementation CMDTextEditor

- (instancetype)initWithTextStorage:(DVTTextStorage *)textStorage
{
    if ((self = [super init]))
    {
        self.textStorage = textStorage;

        NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
        [layoutManager addTextContainer:[[NSTextContainer alloc] init]];
        [self.textStorage addLayoutManager:layoutManager];

        self.wantsLayer = YES;
        self.layer.backgroundColor = [[self.textStorage.fontAndColorTheme sourceTextBackgroundColor] CGColor];
        self.selectedRanges = @[[CMDTextRange textRange:NSMakeRange(0, 0)]];
    }

    return self;
}

- (BOOL)isFlipped
{
    return YES;
}

- (void)drawRect:(NSRect)dirtyRect
{
    self.textStorage.syntaxColoringEnabled = YES;

    NSMutableAttributedString *string = [self.textStorage contents];

    NSRange currentRange = NSMakeRange(0, string.length);
    while (currentRange.location < string.length)
    {
        NSColor *color = [self.textStorage colorAtCharacterIndex:currentRange.location effectiveRange:&currentRange context:0];

        NSUInteger offset = currentRange.location + currentRange.length;
        currentRange = NSMakeRange(offset, string.length - offset);

        [string addAttribute:NSForegroundColorAttributeName value:color range:currentRange];
    }

    [string drawWithRect:NSMakeRect(0.f, 0.f, self.bounds.size.width, self.bounds.size.height) options:NSStringDrawingUsesLineFragmentOrigin];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return [[self.textStorage attributedSubstringFromRange:NSMakeRange(0, self.textStorage.length)] boundingRectWithSize:NSMakeSize(size.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin].size;
}

- (void)setSelectedRanges:(NSArray *)selectedRanges
{
    _selectedRanges = selectedRanges;

    [self.selectionViews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    NSMutableArray *views = [[NSMutableArray alloc] init];
    [selectedRanges enumerateObjectsUsingBlock:^(CMDTextRange *textRange, NSUInteger idx, BOOL *stop) {
        NSView *view = [[NSView alloc] init];
        view.wantsLayer = YES;
        view.layer.backgroundColor = [[[NSColor blueColor] colorWithAlphaComponent:0.5f] CGColor];
        [views addObject:view];
        [self addSubview:view];
    }];

    self.selectionViews = views;
}

- (void)setSelectionViews:(NSArray *)selectionViews
{
    _selectionViews = selectionViews;

    [self setNeedsLayout:YES];
}

- (void)layout
{
    NSLayoutManager *layoutManager = [[self.textStorage layoutManagers] firstObject];
    [[layoutManager.textContainers firstObject] setContainerSize:self.frame.size];

    [self.selectionViews enumerateObjectsUsingBlock:^(NSView *view, NSUInteger idx, BOOL *stop) {
        CMDTextRange *textRange = self.selectedRanges[idx];
        NSRange range = textRange.range;

        if (range.length == 0)
        {
            CGPoint linePoint = [layoutManager lineFragmentRectForGlyphAtIndex:range.location effectiveRange:NULL].origin;
            CGPoint intraLinePoint = [layoutManager locationForGlyphAtIndex:range.location];

            view.frame = CGRectMake(linePoint.x + intraLinePoint.x, linePoint.y, 1.f, intraLinePoint.y);
        }
    }];

    [super layout];
}

- (BOOL)canBecomeKeyView
{
    return YES;
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void)keyDown:(NSEvent *)theEvent
{
    unsigned short keyCode = theEvent.keyCode;

    if (keyCode == NSLeftArrowFunctionKey)
    {

    }
    else if (keyCode == 124)
    {
        NSMutableArray *newRanges = [[NSMutableArray alloc] init];
        [self.selectedRanges enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(CMDTextRange *range, NSUInteger idx, BOOL *stop) {
            [newRanges addObject:[CMDTextRange textRange:NSMakeRange(range.range.location + 1, 0)]];
        }];

        self.selectedRanges = newRanges;
    }
}

@end
