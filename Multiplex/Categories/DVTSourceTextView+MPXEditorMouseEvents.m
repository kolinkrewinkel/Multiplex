//
//  DVTSourceTextView+MPXEditorClipboardSupport.m
//  Multiplex
//
//  Created by Kolin Krewinkel on 8/26/15.
//  Copyright © 2015 Kolin Krewinkel. All rights reserved.
//

@import JRSwizzle;
@import libextobjc;
@import MPXSelectionCore;

#import <DVTKit/DVTFoldingManager.h>
#import <DVTKit/DVTLayoutManager.h>
#import <DVTKit/DVTTextStorage.h>

#import "DVTSourceTextView+MPXEditorExtensions.h"
#import "DVTSourceTextView+MPXEditorSelectionVisualization.h"

#import "DVTSourceTextView+MPXEditorMouseEvents.h"

@implementation DVTSourceTextView (MPXEditorMouseEvents)
@synthesizeAssociation(DVTSourceTextView, mpx_definitionLongPressTimer);
@synthesizeAssociation(DVTSourceTextView, mpx_rangeInProgressStart);
@synthesizeAssociation(DVTSourceTextView, mpx_rangeInProgress);

#pragma mark - Mouse Events

- (void)mpx_mouseDragged:(NSEvent *)theEvent
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(mpx_performOriginalJump:) object:nil];

    [self.mpx_textViewSelectionDecorator stopBlinking];

    NSRange rangeInProgress = self.mpx_rangeInProgress.range;
    NSRange rangeInProgressOrigin = self.mpx_rangeInProgressStart.range;

    if (rangeInProgress.location == NSNotFound || rangeInProgressOrigin.location == NSNotFound) {
        return;
    }

    CGPoint clickLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSUInteger index = [self characterIndexForInsertionAtPoint:clickLocation];
    NSRange newRange;

    if (index > rangeInProgressOrigin.location) {
        newRange = NSMakeRange(rangeInProgressOrigin.location, index - rangeInProgressOrigin.location);
    } else {
        newRange = NSMakeRange(index, (rangeInProgressOrigin.location + rangeInProgressOrigin.length) - index);
    }

    // Update the model value for when it is used combinatorily.
    self.mpx_rangeInProgress = [MPXSelection selectionWithRange:newRange];

    NSArray *finalizedSelections = self.mpx_selectionManager.finalizedSelections;
    MPXSelection *draggingSelection = [[MPXSelection alloc] initWithSelectionRange:newRange
                                                             indexWantedWithinLine:MPXNoStoredLineIndex
                                                                            origin:self.mpx_rangeInProgressStart.range.location];

    [self.mpx_selectionManager setTemporarySelections:[finalizedSelections arrayByAddingObject:draggingSelection]];
}

- (void)mpx_performOriginalJump:(NSTimer *)sender
{
    NSEvent *mouseDownEvent = sender.userInfo;
    if (!CGPointEqualToPoint(self.window.mouseLocationOutsideOfEventStream, [mouseDownEvent locationInWindow])) {
        return;
    }

    [self.mpx_selectionManager setTemporarySelections:nil];
    self.mpx_rangeInProgress = [MPXSelection selectionWithRange:NSMakeRange(NSNotFound, 0)];
    self.mpx_rangeInProgressStart = [MPXSelection selectionWithRange:NSMakeRange(NSNotFound, 0)];

    [self _didClickOnTemporaryLinkWithEvent:mouseDownEvent];
}

- (void)mpx_mouseDown:(NSEvent *)theEvent
{
    NSUInteger index = ({
        CGPoint clickLocation = [self convertPoint:[theEvent locationInWindow]
                                          fromView:nil];
        [self characterIndexForInsertionAtPoint:clickLocation];
    });

    if (index == NSNotFound) {
        return;
    }

    NSInteger clickCount = theEvent.clickCount;
    NSRange resultRange = NSMakeRange(NSNotFound, 0);
    DVTTextStorage *textStorage = (DVTTextStorage *)self.textStorage;
    
    switch (clickCount) {
        case 1:
            // Selects only the single point at the approximate location of the cursor           
            resultRange = NSMakeRange(index, 0);
            break;
        case 2: {
            if ([self.layoutManager.foldingManager firstFoldTouchingCharacterIndex:index]) {
                [self mpx_mouseDown:theEvent];
                return;
            }
            
            resultRange = [textStorage doubleClickAtIndex:index];
            break;
        }
        case 3:
            resultRange = [textStorage.string lineRangeForRange:NSMakeRange(index, 0)];
            break;
        default:
            return;
    }

    if (resultRange.location == NSNotFound) {
        return;
    }

    [self.mpx_textViewSelectionDecorator stopBlinking];
    [self.mpx_textViewSelectionDecorator setCursorsVisible:YES];

    MPXSelection *selection = [MPXSelection selectionWithRange:resultRange];
    self.mpx_rangeInProgress = selection;
    self.mpx_rangeInProgressStart = selection;

    BOOL commandKeyHeld = (theEvent.modifierFlags & NSCommandKeyMask) != 0;
    if (commandKeyHeld) {
        NSArray *selections = self.mpx_selectionManager.visualSelections;
        [self.mpx_selectionManager setTemporarySelections:[selections arrayByAddingObject:selection]];

        self.mpx_definitionLongPressTimer = [NSTimer timerWithTimeInterval:0.333
                                                                    target:self
                                                                  selector:@selector(mpx_performOriginalJump:)
                                                                  userInfo:theEvent
                                                                   repeats:NO];

        [[NSRunLoop mainRunLoop] addTimer:self.mpx_definitionLongPressTimer forMode:NSDefaultRunLoopMode];
    } else {
        self.mpx_shouldCloseGroupOnNextChange = [self.mpx_selectionManager.finalizedSelections count] > 0;

        // Because the click was singular, the other selections will *not* come back under any circumstances.
        // Thus, it must be finalized at the point where it's at is if it's a zero-length selection.
        // Otherwise, they'll be re-added during dragging.
        self.mpx_selectionManager.finalizedSelections = @[selection];

        // In the event the user drags, however, it needs to unfinalized so that it can be extended again.
        [self.mpx_selectionManager setTemporarySelections:@[selection]];
    }
}

- (void)mpx_mouseUp:(NSEvent *)theEvent
{
    [self.mpx_definitionLongPressTimer invalidate];

    self.mpx_selectionManager.finalizedSelections = self.mpx_selectionManager.visualSelections;
    self.mpx_rangeInProgress = [MPXSelection selectionWithRange:NSMakeRange(NSNotFound, 0)];
    self.mpx_rangeInProgressStart = [MPXSelection selectionWithRange:NSMakeRange(NSNotFound, 0)];
    
    [self.mpx_textViewSelectionDecorator startBlinking];
}

@end
