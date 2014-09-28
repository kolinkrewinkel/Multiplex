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

@implementation DVTSourceTextView (CMDViewReplacement)

@synthesizeAssociation(DVTSourceTextView, cmd_selectedRanges);
@synthesizeAssociation(DVTSourceTextView, cmd_selectionViews);

#pragma mark -
#pragma mark NSObject

+ (void)load
{
    CMDDVTSourceTextViewOriginalInit = PLYPoseSwizzle(self, @selector(init), self, @selector(init), YES);
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

- (void)deleteBackward:(id)sender
{
//    NSLog(@"%@", theEvent);
//    NSLog(@"%lu", theEvent.modifierFlags);
//
//    if ((theEvent.modifierFlags & NSDeviceIndependentModifierFlagsMask) == 0)
//    {
//        NSLog(@"no modifier held. inserting text");
//
//        NSString *string = theEvent.charactersIgnoringModifiers;
//        NSInteger delta = [string length];
//
//        [self.cmd_selectedRanges enumerateObjectsUsingBlock:^(NSValue *vRange, NSUInteger idx, BOOL *stop) {
//            NSRange range;
//            [vRange getValue:&range];
//
//            NSRange rangeToReplace = range;
//            if (delta < 0)
//            {
//                rangeToReplace.location += delta;
//            }
//
//            [self insertText:string replacementRange:rangeToReplace];
//        }];
//
//        [self cmd_setSelectedRanges:[[self.cmd_selectedRanges.rac_sequence map:^id(NSValue *vRange) {
//            NSRange range;
//            [vRange getValue:&range];
//
//            return [NSValue valueWithRange:NSMakeRange(range.location + delta, 0)];
//        }] array]];
//    }
//    else
//    {
//        [super keyDown:theEvent];
//    }
    NSLog(@"DELETE BACKWARD");
}

- (void)mouseDown:(NSEvent *)theEvent
{
    BOOL commandKeyHeld = (theEvent.modifierFlags & NSCommandKeyMask) != 0;

    NSArray *existingSelections = self.cmd_selectedRanges;
    if (!existingSelections)
    {
        existingSelections = @[];
    }

    CGPoint clickLocation =
    ({
        CGPoint location = [self convertPoint:[theEvent locationInWindow] toView:nil];

        CGFloat sidebarWidth = [[[[self enclosingScrollView] verticalRulerView] valueForKey:@"sidebarWidth"] floatValue];
        CGFloat foldbarWidth = [[[[self enclosingScrollView] verticalRulerView] valueForKey:@"foldbarWidth"] floatValue];

        location.x -= (sidebarWidth + foldbarWidth) * 2.f;
        location;
    });
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

- (void)cmd_setSelectedRanges:(NSArray *)ranges
{
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
    animation.beginTime = CACurrentMediaTime() + 0.275;
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
