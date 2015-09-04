//
//  DVTTextCompletionListWindowController+MPXAutocompleteAnimation.m
//  Multiplex
//
//  Created by Kolin Krewinkel on 9/4/15.
//  Copyright © 2015 Kolin Krewinkel. All rights reserved.
//

@import JRSwizzle;
@import QuartzCore;

#import "DVTTextCompletionListWindowController+MPXAutocompleteAnimation.h"

@implementation DVTTextCompletionListWindowController (MPXAutocompleteAnimation)

+ (void)load
{
    [self jr_swizzleMethod:@selector(showWindowForTextFrame:explicitAnimation:)
                withMethod:@selector(mpx_showWindowForTextFrame:explicitAnimation:)
                     error:nil];
}

- (void)mpx_showWindowForTextFrame:(CGRect)textFrame explicitAnimation:(BOOL)explicitAnimation
{
    // Disable the AppKit window animation as well as the explicit animation created by Xcode.
    self.window.animationBehavior = NSWindowAnimationBehaviorNone;
    [self mpx_showWindowForTextFrame:textFrame explicitAnimation:NO];
}

@end
