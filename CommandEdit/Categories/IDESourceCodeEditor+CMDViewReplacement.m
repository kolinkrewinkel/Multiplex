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
        NSRange newRange = NSMakeRange(rangeInProgress.location, index - rangeInProgress.location);

        // Update the model value for when it is used combinatorily.
        self.cmd_rangeInProgress = [NSValue valueWithRange:newRange];

        [self cmd_setSelectedRanges:[self.cmd_selectedRanges arrayByAddingObject:[NSValue valueWithRange:newRange]] finalized:NO];
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
    NSMutableArray *shouldCompare = [[NSMutableArray alloc] init];

    [sortedRanges enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [shouldCompare addObject:@YES];
    }];

    [sortedRanges enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSValue *vRange1, NSUInteger idx, BOOL *stop)
    {
        if (![shouldCompare[idx] boolValue])
        {
            return;
        }

        NSRange range1;
        [vRange1 getValue:&range1];

        __block NSRange rangeToAdd = range1;
        __block BOOL shouldAdd = YES;

        [sortedRanges enumerateObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, idx)] options:NSEnumerationReverse usingBlock:^(NSValue *vRange2, NSUInteger idx2, BOOL *stop2)
         {
             NSRange range2;
             [vRange2 getValue:&range2];

             if (NSEqualRanges(rangeToAdd, range2))
             {
                 NSLog(@"Equal ranges (range1 not being added.): %@", NSStringFromRange(rangeToAdd));

                 shouldAdd = NO;
                 *stop2 = YES;
                 return;
             }

             BOOL endsBeyondStartOfRange = range2.location + range2.length >= rangeToAdd.location;
             BOOL startsBeforeOrWithinRange = range2.location <= rangeToAdd.location + rangeToAdd.length;

             if (endsBeyondStartOfRange && startsBeforeOrWithinRange)
             {
                 NSRange originalRangeToAdd = rangeToAdd;
                 shouldCompare[idx2] = @NO;

                 rangeToAdd.location = range2.location;
                 rangeToAdd.length += range2.length;

                  NSLog(@"UPDATED RANGE IN PROGRESS: %@", NSStringFromRange([self.cmd_rangeInProgress rangeValue]));
                 if (NSEqualRanges(originalRangeToAdd, [self.cmd_rangeInProgress rangeValue]))
                 {
                     self.cmd_rangeInProgress = [NSValue valueWithRange:rangeToAdd];
                     NSLog(@"UPDATED RANGE IN PROGRESS: %@", NSStringFromRange([self.cmd_rangeInProgress rangeValue]));
                 }
             }
         }];

        if (shouldAdd)
        {
            [reducedRanges addObject:[NSValue valueWithRange:rangeToAdd]];
        }
    }];

    return [[NSArray alloc] initWithArray:reducedRanges];
}

- (void)cmd_setSelectedRanges:(NSArray *)ranges finalized:(BOOL)finalized
{
    ranges = [self derivedRanges:ranges];

    if (finalized)
    {
        if ([self.cmd_selectedRanges isEqual:ranges] && self.cmd_finalizingRanges == nil)
        {
            return;
        }

        self.cmd_selectedRanges = ranges;
        self.cmd_finalizingRanges = nil;

        NSLog(@"finalized ranges to %@", self.cmd_selectedRanges);
    }
    else
    {
        if ([ranges isEqualToArray:self.cmd_finalizingRanges])
        {
            return;
        }

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

             NSRange rangeToDraw = range;

             if (range.length > 0)
             {
                 selectionViews[[NSValue valueWithRange:range]] = self;
                 rangeToDraw = NSMakeRange(range.location + range.length, 0);
             }

             CGRect lineLocation = [self.layoutManager lineFragmentRectForGlyphAtIndex:rangeToDraw.location effectiveRange:NULL];
             CGPoint location = [self.layoutManager locationForGlyphAtIndex:rangeToDraw.location];

             NSView *view = [[NSView alloc] init];
             view.wantsLayer = YES;
             view.layer.backgroundColor = [textStorage.fontAndColorTheme.sourceTextSelectionColor CGColor];
             CGRect rect = CGRectMake(CGRectGetMinX(lineLocation) + location.x, CGRectGetMaxY(lineLocation) - location.y, 2.f, 18.f);

//             NSLog(@"%f %f", CGRectGetMaxY(lineLocation), location.y);
             [self addSubview:view];
             [view.layer pop_addAnimation:[self basicAnimationWithView:view] forKey:kPOPLayerOpacity];

             selectionViews[[NSValue valueWithRect:rect]] = view;
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
