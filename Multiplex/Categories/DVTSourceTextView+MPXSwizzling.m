//
//  DVTSourceTextView+MPXEditorClipboardSupport.m
//  Multiplex
//
//  Created by Kolin Krewinkel on 8/26/15.
//  Copyright © 2015 Kolin Krewinkel. All rights reserved.
//

@import JRSwizzle;

#import "DVTSourceTextView+MPXEditorAutocompletion.h"
#import "DVTSourceTextView+MPXEditorExtensions.h"
#import "DVTSourceTextView+MPXEditorMouseEvents.h"
#import "DVTSourceTextView+MPXEditorSelectionVisualization.h"
#import "DVTSourceTextView+MPXEditorClipboardSupport.h"
#import "DVTSourceTextView+MPXWhitespaceTrimming.h"

#import "DVTSourceTextView+MPXSwizzling.h"

@implementation DVTSourceTextView (MPXSwizzling)

+ (void)load
{
    [self jr_swizzleMethod:@selector(mouseUp:) withMethod:@selector(mpx_mouseUp:) error:nil];
    [self jr_swizzleMethod:@selector(mouseDown:) withMethod:@selector(mpx_mouseDown:) error:nil];
    [self jr_swizzleMethod:@selector(mouseDragged:) withMethod:@selector(mpx_mouseDragged:) error:nil];
    [self jr_swizzleMethod:@selector(viewWillMoveToWindow:) withMethod:@selector(mpx_viewWillMoveToWindow:) error:nil];

    [self jr_swizzleMethod:@selector(_commonInitDVTSourceTextView)
                withMethod:@selector(mpx_commonInitDVTSourceTextView)
                     error:nil];

    [self jr_swizzleMethod:@selector(shouldAutoCompleteAtLocation:)
                withMethod:@selector(mpx_shouldAutoCompleteAtLocation:)
                     error:nil];

    [self jr_swizzleMethod:@selector(didInsertCompletionTextAtRange:)
                withMethod:@selector(mpx_didInsertCompletionTextAtRange:)
                     error:nil];

    [self jr_swizzleMethod:@selector(validateMenuItem:)
                withMethod:@selector(mpx_validateMenuItem:)
                     error:nil];
    
    [self jr_swizzleMethod:@selector(_updateTemporaryLinkUnderMouseForEvent:)
                withMethod:@selector(mpx_updateTemporaryLinkUnderMouseForEvent:)
                     error:nil];
    
    [self jr_swizzleMethod:@selector(trimTrailingWhitespaceOnLine:)
                withMethod:@selector(mpx_trimTrailingWhitespaceOnLine:)
                     error:nil];
    
    [self jr_swizzleMethod:@selector(indentSelection:)
                withMethod:@selector(mpx_indentSelection:)
                     error:nil];
}

@end
