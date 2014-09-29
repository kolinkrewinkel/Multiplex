//
//  IDESourceCodeEditor+CMDViewReplacement.m
//  CommandEdit
//
//  Created by Kolin Krewinkel on 9/25/14.
//  Copyright (c) 2014 Kolin Krewinkel. All rights reserved.
//

#import <libextobjc/extobjc.h>
#import <pop/POP.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

#import "IDESourceCodeEditor+CMDViewReplacement.h"

#import "PLYSwizzling.h" 
#import "CMDEditorController.h"

static IMP CMDDVTSourceTextViewOriginalInit = nil;
static IMP CMDDVTSourceTextViewOriginalMouseDragged = nil;

@implementation DVTSourceTextView (CMDViewReplacement)

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

    [self cmd_setSelectedRanges:ranges];
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

    [self cmd_setSelectedRanges:ranges];
}

- (void)cmd_mouseDragged:(NSEvent *)theEvent
{
    CMDDVTSourceTextViewOriginalMouseDragged(self, @selector(mouseDragged:), theEvent);
    NSLog(@"mouse dragged %@", theEvent);
}

- (void)mouseDown:(NSEvent *)theEvent
{
    BOOL commandKeyHeld = (theEvent.modifierFlags & NSCommandKeyMask) != 0;

    NSArray *existingSelections = self.cmd_selectedRanges;
    if (!existingSelections)
    {
        existingSelections = @[];
    }

    CGPoint clickLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSUInteger index = [self characterIndexForInsertionAtPoint:clickLocation];

    if (commandKeyHeld)
    {
        [self cmd_setSelectedRanges:[existingSelections arrayByAddingObject:[NSValue valueWithRange:NSMakeRange(index, 0)]]];
    }
    else
    {
        [self cmd_setSelectedRanges:@[[NSValue valueWithRange:NSMakeRange(index, 0)]]];
    }
}

#pragma mark -
#pragma mark Setters

- (NSArray *)derivedRanges:(NSArray *)ranges
{
    NSArray *sortedRanges = [ranges sortedArrayUsingComparator:^NSComparisonResult(NSValue *vRange1, NSValue *vRange2) {
        NSRange range1;
        NSRange range2;

        [vRange1 getValue:&range1];
        [vRange2 getValue:&range2];

        NSInteger range1End = (range1.location + range1.length);
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

    NSMutableArray *coallescedRanges = [[NSMutableArray alloc] init];
    [sortedRanges enumerateObjectsUsingBlock:^(NSValue *vRange, NSUInteger idx, BOOL *stop) {
        NSRange range;
        [vRange getValue:&range];

        __block BOOL contained = NO;
        [coallescedRanges enumerateObjectsUsingBlock:^(NSValue *vRange2, NSUInteger idx, BOOL *stop) {
            NSRange range2;
            [vRange2 getValue:&range2];

            NSRange intersectionRange = NSIntersectionRange(range, range2);
            BOOL overlap = intersectionRange.length != 0;
            BOOL sameIndex = intersectionRange.length == 0 && (range2.location == range.location);
            if (overlap || sameIndex)
            {
                *stop = YES;
                contained = YES;
            }
        }];

        if (!contained)
        {
            [coallescedRanges addObject:vRange];
        }
    }];

    return [[NSArray alloc] initWithArray:coallescedRanges];
}

- (void)cmd_setSelectedRanges:(NSArray *)ranges
{
    ranges = [self derivedRanges:ranges];

    self.cmd_selectedRanges = ranges;

    [self.cmd_selectionViews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    NSMutableArray *selectionViews = [[NSMutableArray alloc] init];

    [ranges enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSView *view = [[NSView alloc] init];
        view.wantsLayer = YES;
        view.layer.backgroundColor = [[NSColor redColor] CGColor];

        [selectionViews addObject:view];
        [self addSubview:view];

        [view.layer pop_addAnimation:[self basicAnimationWithView:view] forKey:kPOPLayerOpacity];
    }];

    self.cmd_selectionViews = selectionViews;
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
    [self.cmd_selectionViews enumerateObjectsUsingBlock:^(NSView *view, NSUInteger idx, BOOL *stop) {
        NSValue *vRange = self.cmd_selectedRanges[idx];
        NSRange range;
        [vRange getValue:&range];

        CGRect lineLocation = [self.layoutManager lineFragmentRectForGlyphAtIndex:range.location effectiveRange:NULL];
        CGPoint location = [self.layoutManager locationForGlyphAtIndex:range.location];

        DVTTextStorage *textStorage = (DVTTextStorage *)self.textStorage;
        view.layer.backgroundColor = [textStorage.fontAndColorTheme.sourceTextSelectionColor CGColor];
        view.frame = CGRectMake(CGRectGetMinX(lineLocation) + location.x, CGRectGetMaxY(lineLocation) - location.y, 2.f, 18.f);
    }];

    [super layout];
}

@end
