//
//  IDESourceCodeEditor+CMDViewReplacement.m
//  CommandEdit
//
//  Created by Kolin Krewinkel on 9/25/14.
//  Copyright (c) 2014 Kolin Krewinkel. All rights reserved.
//

#import <libextobjc/extobjc.h>
#import <pop/POP.h>

#import "IDESourceCodeEditor+CMDViewReplacement.h"

#import "PLYSwizzling.h" 
#import "CMDEditorController.h"

static  IMP CMDDVTSourceTextViewOriginalSetSelectedRange = nil; 
static IMP CMDDVTSourceTextViewOriginalInit = nil;

@implementation DVTSourceTextView (CMDViewReplacement)

@synthesizeAssociation(DVTSourceTextView, cmd_selectedRanges);
@synthesizeAssociation(DVTSourceTextView, cmd_selectionViews);

#pragma mark -
#pragma mark NSObject

+ (void)load
{
    CMDDVTSourceTextViewOriginalInit = PLYPoseSwizzle(self, @selector(init), self, @selector(init), YES);
//    CMDDVTSourceTextViewOriginalSetSelectedRange = PLYPoseSwizzle(self, @selector(setSelectedRange:), self, @selector(cmd_setSelectedRange:), YES);
}

#pragma mark -
#pragma mark Initializer

- (instancetype)init
{
    id val = CMDDVTSourceTextViewOriginalInit(self, @selector(init));

//    self.selectedRange = NSMakeRange(NSNotFound, 0);
//    self.selectable = NO;
//    self.editable = YES;

    return val;
}

#pragma mark -
#pragma mark Setters

//-(void)cmd_setSelectedRange:(NSRange)range
//{
//    self.selectable = NO;
//    NSLog(@"%@", NSStringFromRange(self.selectedRange));
//}
//
- (BOOL)isSelectable
{
    return NO;
}

#pragma mark -
#pragma mark Events

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

        [view.layer pop_addAnimation:
         ({
            POPSpringAnimation *animation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerOpacity];
            animation.springBounciness = 0.f;
//            animation.velocity = @0.05f;
            animation.springSpeed = 1.f;
            animation.toValue = @0.f;
            animation.repeatForever = YES;
            animation.autoreverses = YES;
            animation;
        }) forKey:nil];
    }];

    self.cmd_selectionViews = selectionViews;
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
