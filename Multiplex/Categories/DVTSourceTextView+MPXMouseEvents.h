//
//  DVTSourceTextView+MPXMouseEvents.h
//  Multiplex
//
//  Created by Kolin Krewinkel on 8/26/15.
//  Copyright © 2015 Kolin Krewinkel. All rights reserved.
//

#import <DVTKit/DVTSourceTextView.h>

@interface DVTSourceTextView (MPXMouseEvents)

- (void)mpx_mouseDown:(NSEvent *)event;
- (void)mpx_mouseDragged:(NSEvent *)event;
- (void)mpx_mouseUp:(NSEvent *)event;

- (void)mpx_updateTemporaryLinkUnderMouseForEvent:(NSEvent *)event;

/**
 * Handles long-press while holding alt to show the info menu for an expression. (Normally shows with an Alt-click.)
 */
@property (nonatomic) NSTimer *mpx_altPopoverTimer;

/**
 * Handles the new selection being staged as the user holds their mouse down (and optionally drags). Gets cleared on
 * -mouseUp:.
 */
@property (nonatomic) MPXSelection *mpx_rangeInProgress;

@end
