//
//  MPXTextViewSelectionDecorator.m
//  Multiplex
//
//  Created by Kolin Krewinkel on 8/23/15.
//  Copyright © 2015 Kolin Krewinkel. All rights reserved.
//

#import <DVTKit/DVTLayoutManager.h>
#import <DVTKit/DVTSourceTextView.h>
#import <DVTKit/DVTTextStorage.h>
#import <DVTKit/DVTFontAndColorTheme.h>

@import MPXFoundation;
@import ReactiveCocoa;

#import "MPXSelection.h"

#import "MPXTextViewSelectionDecorator.h"

@interface MPXTextViewSelectionDecorator ()

@property (nonatomic) DVTSourceTextView *textView;

@property (nonatomic) NSTimer *blinkTimer;
@property (nonatomic) BOOL blinkState;
@property (nonatomic) NSArray *caretViews;

@end

@implementation MPXTextViewSelectionDecorator

#pragma mark - Initialization

- (instancetype)initWithTextView:(DVTSourceTextView *)textView
{
    if (self = [super init]) {
        self.textView = textView;
    }

    return self;
}

#pragma mark - MPXSelectionManagerVisualizationDelegate

- (void)selectionManager:(MPXSelectionManager *)selectionManager didChangeVisualSelections:(NSArray *)visualSelections
{
    [self stopBlinking];

    DVTTextStorage *textStorage = self.textView.textStorage;

    // Reset the background color of all the source text.
    NSColor *defaultBackgroundColor = textStorage.fontAndColorTheme.sourceTextBackgroundColor;
    [self.textView.layoutManager setTemporaryAttributes:@{NSBackgroundColorAttributeName: defaultBackgroundColor}
                                      forCharacterRange:NSMakeRange(0, textStorage.length)];

    // Remove any onscreen cursors
    [self.caretViews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    RACSequence *selectionSequence = [visualSelections rac_sequence];
    self.caretViews = [[selectionSequence map:^NSView *(MPXSelection *selection) {
        NSRange range = [selection range];
        if ([selection selectionAffinity] == NSSelectionAffinityDownstream) {
            range = NSMakeRange(NSMaxRange(range), 0);
        } else {
            range = NSMakeRange(range.location, 0);
        }

        NSRange glyphRange = [self.textView.layoutManager glyphRangeForCharacterRange:range
                                                                 actualCharacterRange:nil];

        NSRect glyphRect = [self.textView.layoutManager boundingRectForGlyphRange:NSMakeRange(glyphRange.location, 0)
                                                                  inTextContainer:self.textView.textContainer];

        CGRect unroundedCaretRect = CGRectOffset(CGRectMake(glyphRect.origin.x, glyphRect.origin.y, 1.f/self.textView.window.screen.backingScaleFactor, CGRectGetHeight(glyphRect)),
                                                 self.textView.textContainerOrigin.x,
                                                 self.textView.textContainerOrigin.y);

        CGRect caretRect = MPXRoundedValueRectForView(unroundedCaretRect, self.textView);

        NSView *caretView = [[NSView alloc] initWithFrame:caretRect];
        caretView.wantsLayer = YES;
        caretView.layer.backgroundColor = [textStorage.fontAndColorTheme.sourceTextInsertionPointColor CGColor];

        return caretView;
    }] array];
    [self.caretViews enumerateObjectsUsingBlock:^(NSView *caret, NSUInteger idx, BOOL *stop) {
        [self.textView addSubview:caret];
    }];

    // Paint the background of the selection range for selections taht are not just insertion points.
    NSArray *rangedSelections = [[selectionSequence filter:^BOOL(MPXSelection *selection) {
        return selection.range.length > 0;
    }] array];

    NSColor *selectedBackgroundColor = textStorage.fontAndColorTheme.sourceTextSelectionColor;
    for (MPXSelection *selection in rangedSelections) {
        [self.textView.layoutManager setTemporaryAttributes:@{NSBackgroundColorAttributeName: selectedBackgroundColor}
                                          forCharacterRange:selection.range];
    }
}

- (void)setCursorsVisible:(BOOL)visible
{
    [self.caretViews enumerateObjectsUsingBlock:^(NSView *view, NSUInteger idx, BOOL *stop) {
        view.hidden = !visible;
    }];

    self.blinkState = visible;
}

- (void)blinkCursors:(NSTimer *)sender
{
    if ([self.caretViews count] == 0) {
        return;
    }

    [self setCursorsVisible:!self.blinkState];
}

- (void)startBlinking
{
    [self.blinkTimer invalidate];
    self.blinkTimer = nil;

    // This used to check if the blink timer was already there, however:
    // we should restart it because the old one will mess up a new cursor's showing
    // for too short a time if the timer was already in motion.
    self.blinkTimer = [NSTimer timerWithTimeInterval:0.5
                                              target:self
                                            selector:@selector(blinkCursors:)
                                            userInfo:nil
                                             repeats:YES];

    [[NSRunLoop mainRunLoop] addTimer:self.blinkTimer forMode:NSRunLoopCommonModes];
}

- (void)stopBlinking
{
    [self.blinkTimer invalidate];
    self.blinkTimer = nil;

    [self setCursorsVisible:NO];
}

@end
