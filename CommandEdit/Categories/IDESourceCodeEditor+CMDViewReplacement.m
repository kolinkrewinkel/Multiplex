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

static IMP CMDDVTSourceTextViewOriginalDrawInsertion = nil;

@implementation DVTSourceTextView (CMDViewReplacement)

+ (void)load
{
//    CMDDVTSourceTextViewOriginalDrawInsertion = PLYPoseSwizzle(self, @selector(drawInsertionPointInRect:color:turnedOn:), self, @selector(cmd_drawInsertionPointInRect:color:turnedOn:), YES);
}


-(void)_drawInsertionPointInRect:(NSRect)rect color:(NSColor*)color{
    NSRange charRange = NSMakeRange(self.selectedRange.location, 1);
    NSRect glyphRect = [[self layoutManager] boundingRectForGlyphRange:charRange inTextContainer:[self textContainer]];
    if( glyphRect.size.width == 0 ||
       [[NSCharacterSet newlineCharacterSet] characterIsMember:[[self string] characterAtIndex:self.selectedRange.location]] ){
        glyphRect = rect;
    }
    color = [color colorWithAlphaComponent:0.5];
    [color set];
    NSRectFillUsingOperation(glyphRect, NSCompositeSourceOver);
    // We do not call super calls since the method in the super class uses NSRectFill and calling it results in filling the rect with the color without transparency.
}

- (void)drawInsertionPointInRect:(NSRect)rect color:(NSColor *)color turnedOn:(BOOL)flag{
    // Call super class first.
    [super drawInsertionPointInRect:rect color:color turnedOn:flag];
    // Then tell the view to redraw to clear a caret.
    if( !flag ){
        [self setNeedsDisplay:YES];
    }
}

@end
