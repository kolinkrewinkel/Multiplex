//
//  IDESourceCodeEditor+CMDViewReplacement.m
//  CommandEdit
//
//  Created by Kolin Krewinkel on 9/25/14.
//  Copyright (c) 2014 Kolin Krewinkel. All rights reserved.
//

@import QuartzCore;

#import <libextobjc/extobjc.h>
#import <pop/POP.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

#import "IDESourceCodeEditor+CMDViewReplacement.h"

#import "PLYSwizzling.h" 
#import "CMDEditorController.h"

static IMP CMDDVTSourceTextViewOriginalInit = nil;
static IMP CMDDVTSourceTextViewOriginalMouseDragged = nil;

@implementation DVTSourceTextView (CMDViewReplacement)

@synthesizeAssociation(DVTSourceTextView, cmd_rangeInProgress);
@synthesizeAssociation(DVTSourceTextView, cmd_finalizingRanges);
@synthesizeAssociation(DVTSourceTextView, cmd_selectedRanges);
@synthesizeAssociation(DVTSourceTextView, cmd_selectionViews);

#pragma mark -
#pragma mark NSObject

+ (void)load
{
    CMDDVTSourceTextViewOriginalInit = PLYPoseSwizzle(self, @selector(init), self, @selector(init), YES);
    CMDDVTSourceTextViewOriginalMouseDragged = PLYPoseSwizzle(self, @selector(mouseDragged:), self, @selector(cmd_mouseDragged:), YES);
}

#pragma mark -
#pragma mark Initializer

- (instancetype)init
{
    id val = CMDDVTSourceTextViewOriginalInit(self, @selector(init));

    self.cmd_rangeInProgress = [NSValue valueWithRange:NSMakeRange(NSNotFound, 0)];

    return val;
}

#pragma mark -
#pragma mark Setters

- (BOOL)isSelectable
{
    return NO;
}

#pragma mark -
#pragma mark Events

- (void)insertText:(id)insertString
{
    if (![insertString isKindOfClass:[NSString class]])
    {
        return;
    }

    NSString *string = (NSString *)insertString;
    NSInteger delta = [string length];
    __block NSInteger totalDelta = 0;

    NSMutableArray *ranges = [[NSMutableArray alloc] init];

    [self.cmd_selectedRanges enumerateObjectsUsingBlock:^(NSValue *vRange, NSUInteger idx, BOOL *stop)
    {
        NSRange range;
        [vRange getValue:&range];

        NSRange rangeToReplace = NSMakeRange(range.location + totalDelta, range.length);
        [self insertText:string replacementRange:rangeToReplace];

        NSRange deltaRange = NSMakeRange(rangeToReplace.location + delta, rangeToReplace.length);
        [ranges addObject:[NSValue valueWithRange:deltaRange]];

//        NSLog(@"\n-----------\nInserting text: %@\n@ range: %@\nNew cursor range: %@\nDelta used: %li\nTotal delta: %li", string, NSStringFromRange(rangeToReplace), NSStringFromRange(deltaRange), (long)delta, (long)totalDelta);

        totalDelta += delta;
    }];

    [self cmd_setSelectedRanges:ranges finalized:YES];
}

- (void)deleteBackward:(id)sender
{
    __block NSInteger totalDelta = 0;

    NSMutableArray *ranges = [[NSMutableArray alloc] init];

    [self.cmd_selectedRanges enumerateObjectsUsingBlock:^(NSValue *vRange, NSUInteger idx, BOOL *stop)
    {
        NSRange range;
        [vRange getValue:&range];

        NSInteger lengthDeleted = -(range.length + 1);
        NSRange rangeToReplace = NSMakeRange(range.location + totalDelta + lengthDeleted, -lengthDeleted);

        [self insertText:@"" replacementRange:rangeToReplace];

        NSRange deltaRange = NSMakeRange(rangeToReplace.location, 0);
        [ranges addObject:[NSValue valueWithRange:deltaRange]];

        NSLog(@"\n-----------\nDeleting text @ range: %@\nNew cursor range: %@\nDelta used: %li\nTotal delta: %li", NSStringFromRange(rangeToReplace), NSStringFromRange(deltaRange), (long)lengthDeleted, (long)totalDelta);

        totalDelta += lengthDeleted;
    }];

    [self cmd_setSelectedRanges:ranges finalized:YES];
}

- (void)cmd_mouseDragged:(NSEvent *)theEvent
{
//    CMDDVTSourceTextViewOriginalMouseDragged(self, @selector(mouseDragged:), theEvent);

    NSRange rangeInProgress;
    [self.cmd_rangeInProgress getValue:&rangeInProgress];

    if (rangeInProgress.location == NSNotFound)
    {
        return;
    }

    CGPoint clickLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSUInteger index = [self characterIndexForInsertionAtPoint:clickLocation];

    if (index > rangeInProgress.location)
    {
        NSArray *ranges = self.cmd_selectedRanges;
        [self cmd_setSelectedRanges:[ranges arrayByAddingObject:[NSValue valueWithRange:NSMakeRange(rangeInProgress.location, index - rangeInProgress.location)]] finalized:NO];
    }
}

- (void)mouseDown:(NSEvent *)theEvent
{
    BOOL commandKeyHeld = (theEvent.modifierFlags & NSCommandKeyMask) != 0;

    NSArray *existingSelections = [self cmd_effectiveSelectedRanges];
    if (!existingSelections)
    {
        existingSelections = @[];
    }

    CGPoint clickLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSUInteger index = [self characterIndexForInsertionAtPoint:clickLocation];

    NSRange rangeOfSelection = NSMakeRange(index, 0);
    self.cmd_rangeInProgress = [NSValue valueWithRange:rangeOfSelection];

    if (commandKeyHeld)
    {
        NSLog(@"adding range");
        [self cmd_setSelectedRanges:[existingSelections arrayByAddingObject:[NSValue valueWithRange:rangeOfSelection]] finalized:NO];
    }
    else
    {
        [self cmd_setSelectedRanges:@[[NSValue valueWithRange:rangeOfSelection]] finalized:YES];
        [self cmd_setSelectedRanges:@[[NSValue valueWithRange:rangeOfSelection]] finalized:NO];
    }
}

- (void)mouseUp:(NSEvent *)theEvent
{
    [self cmd_setSelectedRanges:[self cmd_effectiveSelectedRanges] finalized:YES];
    self.cmd_rangeInProgress = [NSValue valueWithRange:NSMakeRange(NSNotFound, 0)];
}

#pragma mark -
#pragma mark Setters

- (NSArray *)derivedRanges:(NSArray *)ranges
{
    NSArray *sortedRanges = [self sortedRanges:ranges];
    NSArray *reducedRanges = [self reducedRanges:sortedRanges];

    return reducedRanges;
}

- (NSArray *)sortedRanges:(NSArray *)ranges
{
    return [ranges sortedArrayUsingComparator:^NSComparisonResult(NSValue *vRange1, NSValue *vRange2) {
        NSRange range1;
        [vRange1 getValue:&range1];
        NSInteger range1End = (range1.location + range1.length);

        NSRange range2;
        [vRange2 getValue:&range2];
        NSInteger range2End = (range2.location + range2.length);

        if (range2End > range1End)
        {
            return NSOrderedAscending;
        }
        else if (range2End < range1End)
        {
            return NSOrderedDescending;
        }

        return NSOrderedSame;
    }];
}

- (NSArray *)reducedRanges:(NSArray *)sortedRanges
{
    NSMutableArray *reducedRanges = [[NSMutableArray alloc] init];
    [sortedRanges enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSValue *vRange, NSUInteger idx, BOOL *stop) {
        NSRange range;
        [vRange getValue:&range];

        if (idx > 0 && [reducedRanges count] > 0)
        {
            [sortedRanges enumerateObjectsWithOptions:0 usingBlock:^(NSValue *vRange2, NSUInteger idx, BOOL *stop)
             {
                 NSRange range2;
                 [vRange2 getValue:&range2];

                 NSLog(@"\nCompare: %@\n   Against: %@\n", NSStringFromRange(range), NSStringFromRange(range2));
             }];
        }

        [reducedRanges addObject:vRange];
    }];

    return [[NSArray alloc] initWithArray:reducedRanges];
}

- (void)cmd_setSelectedRanges:(NSArray *)ranges finalized:(BOOL)finalized
{
    ranges = [self derivedRanges:ranges];

    if (finalized)
    {
        self.cmd_selectedRanges = ranges;
        self.cmd_finalizingRanges = nil;

        NSLog(@"finalized ranges to %@", self.cmd_selectedRanges);
    }
    else
    {
        self.cmd_finalizingRanges = ranges;

        NSLog(@"temp'd ranges to %@", self.cmd_finalizingRanges);
    }

    [self.cmd_selectionViews enumerateKeysAndObjectsUsingBlock:^(NSValue *value, NSView *view, BOOL *stop) {
        if (view == self)
        {
            NSRange range;
            [value getValue:&range];

            DVTTextStorage *textStorage = (DVTTextStorage *)self.textStorage;
            NSColor *backgroundColor = textStorage.fontAndColorTheme.sourceTextBackgroundColor;

            [self.layoutManager addTemporaryAttribute:NSBackgroundColorAttributeName value:backgroundColor forCharacterRange:range];

            return;
        }

        [view removeFromSuperview];
    }];

    self.cmd_selectionViews =
    ({
        DVTTextStorage *textStorage = (DVTTextStorage *)self.textStorage;
        NSMutableDictionary *selectionViews = [[NSMutableDictionary alloc] init];

        [[self cmd_effectiveSelectedRanges] enumerateObjectsUsingBlock:^(NSValue *vRange, NSUInteger idx, BOOL *stop)
         {
             NSRange range;
             [vRange getValue:&range];

             if (range.length == 0)
             {
                 CGRect lineLocation = [self.layoutManager lineFragmentRectForGlyphAtIndex:range.location effectiveRange:NULL];
                 CGPoint location = [self.layoutManager locationForGlyphAtIndex:range.location];

                 NSView *view = [[NSView alloc] init];
                 view.wantsLayer = YES;
                 view.layer.backgroundColor = [textStorage.fontAndColorTheme.sourceTextSelectionColor CGColor];
                 CGRect rect = CGRectMake(CGRectGetMinX(lineLocation) + location.x, CGRectGetMaxY(lineLocation) - location.y, 2.f, 18.f);
                 [self addSubview:view];
                 [view.layer pop_addAnimation:[self basicAnimationWithView:view] forKey:kPOPLayerOpacity];

                 selectionViews[[NSValue valueWithRect:rect]] = view;
             }
             else
             {
                selectionViews[[NSValue valueWithRange:range]] = self;
             }
         }];
        
        selectionViews;
    });

    [self setNeedsLayout:YES];
}

- (POPBasicAnimation *)basicAnimationWithView:(NSView *)view
{
    POPBasicAnimation *animation = [POPBasicAnimation easeInEaseOutAnimation];
    animation.property = [POPAnimatableProperty propertyWithName:kPOPLayerOpacity];
    animation.toValue = @(view.layer.opacity == 1.f ? 0.f : 1.f);
    animation.duration = view.layer.opacity == 1.f ? 0.10 : 0.15;
    animation.beginTime = CACurrentMediaTime() + 0.3;
    animation.removedOnCompletion = YES;
    [animation setCompletionBlock:^(POPAnimation *animation, BOOL complete)
     {
         if (view && view.superview)
         {
             [view.layer pop_addAnimation:[self basicAnimationWithView:view] forKey:kPOPLayerOpacity];
         }
     }];

    return animation;
}

- (void)layout
{
    [self.cmd_selectionViews enumerateKeysAndObjectsUsingBlock:^(NSValue *vRect, NSView *view, BOOL *stop) {
        CGRect rect = CGRectZero;
        [vRect getValue:&rect];

        if (view == self)
        {
            NSRange range;
            [vRect getValue:&range];

            DVTTextStorage *textStorage = (DVTTextStorage *)self.textStorage;
            NSColor *backgroundColor = textStorage.fontAndColorTheme.sourceTextSelectionColor;

            [self.layoutManager addTemporaryAttribute:NSBackgroundColorAttributeName value:backgroundColor forCharacterRange:range];

            return;
        }

        view.frame = rect;
    }];

    [super layout];
}

- (NSArray *)cmd_effectiveSelectedRanges
{
    return self.cmd_finalizingRanges ? self.cmd_finalizingRanges : self.cmd_selectedRanges;
}

@end
