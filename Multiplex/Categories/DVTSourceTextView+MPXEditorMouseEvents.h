//
//  DVTSourceTextView+MPXEditorClipboardSupport.h
//  Multiplex
//
//  Created by Kolin Krewinkel on 8/26/15.
//  Copyright © 2015 Kolin Krewinkel. All rights reserved.
//

#import <DVTKit/DVTSourceTextView.h>

@interface DVTSourceTextView (MPXEditorMouseEvents)

- (void)mpx_mouseDown:(id)sender;
- (void)mpx_mouseUp:(id)sender;
//- (void)mpx_mouseMoved:(NSEvent *)event;
- (void)mpx_mouseDragged:(id)sender;
- (void)mpx_updateTemporaryLinkUnderMouseForEvent:(NSEvent *)event;

@property (nonatomic) MPXSelection *mpx_rangeInProgress;
@property (nonatomic) MPXSelection *mpx_rangeInProgressStart;

@end
