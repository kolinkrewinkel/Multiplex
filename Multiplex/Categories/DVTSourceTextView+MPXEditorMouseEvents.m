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
#import <DVTKit/DVTSourceTextViewDelegate-Protocol.h>

#import "DVTSourceTextView+MPXEditorExtensions.h"
#import "DVTSourceTextView+MPXEditorSelectionVisualization.h"

#import "DVTSourceTextView+MPXEditorMouseEvents.h"

@implementation DVTSourceTextView (MPXEditorMouseEvents)
@synthesizeAssociation(DVTSourceTextView, mpx_altPopoverTimer);
@synthesizeAssociation(DVTSourceTextView, mpx_rangeInProgressStart);
@synthesizeAssociation(DVTSourceTextView, mpx_rangeInProgress);

#pragma mark - Mouse Events

- (void)mpx_mouseDragged:(NSEvent *)theEvent
{
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

- (void)mpx_showAltPopover:(NSTimer *)sender
{    
    RACTuple *tuple = sender.userInfo;
    RACTupleUnpack(NSNumber *nIndex, NSEvent *event) = tuple;
    
    [((id<DVTSourceTextViewDelegate>)self.delegate) textView:self
                     didClickOnTemporaryLinkAtCharacterIndex:nIndex.unsignedIntegerValue
                                                       event:event
                                                  isAltEvent:YES];
    
    [sender invalidate];
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
    
    BOOL altKeyHeld = (theEvent.modifierFlags & NSAlternateKeyMask) != 0;
    if (altKeyHeld) {      
        
        self.mpx_altPopoverTimer = [NSTimer timerWithTimeInterval:1.0
                                                           target:self
                                                         selector:@selector(mpx_showAltPopover:)
                                                         userInfo:RACTuplePack(@(index), theEvent)
                                                          repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:self.mpx_altPopoverTimer forMode:NSDefaultRunLoopMode];
        
        return;
    }

    NSInteger clickCount = theEvent.clickCount;
    NSRange resultRange = NSMakeRange(NSNotFound, 0);
    
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
            
            resultRange = [self.textStorage doubleClickAtIndex:index];
            break;
        }
        case 3:
            resultRange = [self.textStorage.string lineRangeForRange:NSMakeRange(index, 0)];
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
    BOOL showedAltPopover = !self.mpx_altPopoverTimer.valid;
    [self.mpx_altPopoverTimer invalidate];
    
    NSUInteger index = ({
        CGPoint clickLocation = [self convertPoint:[theEvent locationInWindow]
                                          fromView:nil];
        [self characterIndexForInsertionAtPoint:clickLocation];
    });
    
    BOOL altKeyHeld = (theEvent.modifierFlags & NSAlternateKeyMask) != 0;
    if (altKeyHeld) {        
        
        if (!showedAltPopover) {
            NSEvent *event = [NSEvent mouseEventWithType:theEvent.type
                                                location:theEvent.locationInWindow
                                           modifierFlags:NSCommandKeyMask
                                               timestamp:theEvent.timestamp
                                            windowNumber:theEvent.windowNumber
                                                 context:theEvent.context
                                             eventNumber:theEvent.eventNumber
                                              clickCount:1
                                                pressure:theEvent.pressure];
            
            
            [((id<DVTSourceTextViewDelegate>)self.delegate) textView:self
                             didClickOnTemporaryLinkAtCharacterIndex:index
                                                               event:event
                                                          isAltEvent:NO];
        }
        
        return;
    }
  
    self.mpx_selectionManager.finalizedSelections = self.mpx_selectionManager.visualSelections;
    self.mpx_rangeInProgress = [MPXSelection selectionWithRange:NSMakeRange(NSNotFound, 0)];
    self.mpx_rangeInProgressStart = [MPXSelection selectionWithRange:NSMakeRange(NSNotFound, 0)];
    
    [self.mpx_textViewSelectionDecorator startBlinking];
}

- (void)mpx_updateTemporaryLinkUnderMouseForEvent:(NSEvent *)event
{
    BOOL altKeyHeld = (event.modifierFlags & NSAlternateKeyMask) != 0;
    BOOL commandKeyHeld = (event.modifierFlags & NSCommandKeyMask) != 0;
    if (!commandKeyHeld) {        
        NSEvent *substituteEvent = event;
        
        if (altKeyHeld) {
            if (event.type == NSMouseMoved) {
                substituteEvent = [NSEvent mouseEventWithType:event.type location:event.locationInWindow modifierFlags:NSCommandKeyMask timestamp:event.timestamp windowNumber:event.windowNumber context:event.context eventNumber:event.eventNumber clickCount:event.clickCount pressure:event.pressure];
            } else if (event.type == NSFlagsChanged) {
                substituteEvent = [NSEvent keyEventWithType:event.type location:event.locationInWindow modifierFlags:NSCommandKeyMask timestamp:event.timestamp windowNumber:event.windowNumber context:event.context characters:@"" charactersIgnoringModifiers:@"" isARepeat:NO keyCode:event.keyCode];
            }
        }

        [self mpx_updateTemporaryLinkUnderMouseForEvent:substituteEvent];
    }
}

@end
