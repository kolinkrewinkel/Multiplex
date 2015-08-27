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
}

@end
