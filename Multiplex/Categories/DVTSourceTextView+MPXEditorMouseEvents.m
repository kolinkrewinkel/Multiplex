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
#import <DVTKit/DVTSourceTextViewDelegate-Protocol.h>
#import <DVTKit/DVTTextStorage.h>

#import "DVTSourceTextView+MPXEditorExtensions.h"
#import "DVTSourceTextView+MPXEditorSelectionVisualization.h"

#import "DVTSourceTextView+MPXEditorMouseEvents.h"

@implementation DVTSourceTextView (MPXEditorMouseEvents)
@synthesizeAssociation(DVTSourceTextView, mpx_altPopoverTimer);
@synthesizeAssociation(DVTSourceTextView, mpx_rangeInProgress);

- (void)mpx_mouseDown:(NSEvent *)theEvent
{
    CGPoint clickLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];    
    NSUInteger index = [self characterIndexForInsertionAtPoint:clickLocation];
    
    if (index == NSNotFound) {
        return;
    }
    
    // If Alt is held, don't add a new cursor and just start the timer for showing the alt-info menu after a delay.
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
    
    NSRange resultRange;    
    switch (theEvent.clickCount) {
        case 1:
            // Selects only the single point at the approximate location of the cursor.
            resultRange = NSMakeRange(index, 0);
            break;
        case 2: {
            // Pass double-clicks through that are on a fold to expand them.
            if ([self.layoutManager.foldingManager firstFoldTouchingCharacterIndex:index]) {
                [self mpx_mouseDown:theEvent];
                return;
            }
            
            resultRange = [self.textStorage doubleClickAtIndex:index];
            break;
        }
        case 3: {
            // Triple-clicks select the whole line.
            resultRange = [self.textStorage.string lineRangeForRange:NSMakeRange(index, 0)];
            break;
        }
        default:
            return;
    }
            
    MPXSelection *newSelection = [[MPXSelection alloc] initWithSelectionRange:resultRange
                                                     indexWantedWithinLine:MPXNoStoredLineIndex
                                                                    origin:resultRange.location];
    self.mpx_rangeInProgress = newSelection;
    
    // Add the new selection to the existing visual selections if command is held.
    BOOL commandKeyHeld = (theEvent.modifierFlags & NSCommandKeyMask) != 0;
    if (commandKeyHeld) {
        NSArray *selections = self.mpx_selectionManager.visualSelections;
        [self.mpx_selectionManager setTemporarySelections:[selections arrayByAddingObject:newSelection]];
    } else {        
        self.mpx_shouldCloseGroupOnNextChange = [self.mpx_selectionManager.finalizedSelections count] > 0;
        
        // Because the click was singular, the other selections will *not* come back under any circumstances.
        // Thus, it must be finalized at the point where it's at is if it's a zero-length selection.
        // Otherwise, they'll be re-added during dragging.
        self.mpx_selectionManager.finalizedSelections = @[newSelection];
        
        // In the event the user drags, however, it needs to unfinalized so that it can be extended again.
        [self.mpx_selectionManager setTemporarySelections:@[newSelection]];
    }
    
    [self.mpx_textViewSelectionDecorator setCursorsVisible:YES];    
}

- (void)mpx_mouseDragged:(NSEvent *)theEvent
{
    if (!self.mpx_rangeInProgress) {
        return;
    }
    
    [self.mpx_textViewSelectionDecorator stopBlinking];
    
    CGPoint clickLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSUInteger index = [self characterIndexForInsertionAtPoint:clickLocation];
    NSRange newRange;

    NSUInteger origin = self.mpx_rangeInProgress.origin;
    if (index > origin) {
        newRange = NSMakeRange(origin, index - origin);
    } else {
        newRange = NSMakeRange(index, origin - index);
    }

    // Update the model value for when it is used combinatorily.
    self.mpx_rangeInProgress = [[MPXSelection alloc] initWithSelectionRange:newRange
                                                      indexWantedWithinLine:MPXNoStoredLineIndex
                                                                     origin:origin];
                                
    NSArray *finalizedSelections = self.mpx_selectionManager.finalizedSelections;
    MPXSelection *draggingSelection = [[MPXSelection alloc] initWithSelectionRange:newRange
                                                             indexWantedWithinLine:MPXNoStoredLineIndex
                                                                            origin:origin];

    [self.mpx_selectionManager setTemporarySelections:[finalizedSelections arrayByAddingObject:draggingSelection]];
    
    // Make sure the selection being dragged stays visible
    [self autoscroll:theEvent];
}

- (void)mpx_mouseUp:(NSEvent *)theEvent
{
    BOOL showedAltPopover = !self.mpx_altPopoverTimer.valid;
    [self.mpx_altPopoverTimer invalidate];
    
    NSUInteger index = ({
        CGPoint clickLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];
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
    self.mpx_rangeInProgress = nil;
    
    [self.mpx_textViewSelectionDecorator startBlinking];
}

#pragma mark - Long-press definition handler

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

/**
 * Flips the modifier flags so that Alt shows as Command, and command isn't sent altogether so no solid underline is
 * shown.
 */
 - (void)mpx_updateTemporaryLinkUnderMouseForEvent:(NSEvent *)event
{
    // If the command key is held, do not show any form of temporary link. The I-beam should be shown instead so users
    // know 
    BOOL commandKeyHeld = (event.modifierFlags & NSCommandKeyMask) != 0;    
    if (commandKeyHeld) {
        return;
    }
    
    // Swap the event if the alt-key is held so it looks like the command key is being held.
    // Not exactly an elegant fix, but it requires the least-specific knowledge (and messing with) the internals of
    // the text view.
    NSEvent *substituteEvent = event;
    
    BOOL altKeyHeld = (event.modifierFlags & NSAlternateKeyMask) != 0;     
    if (altKeyHeld) {
        if (event.type == NSMouseMoved) {
            substituteEvent = [NSEvent mouseEventWithType:event.type
                                                 location:event.locationInWindow
                                            modifierFlags:NSCommandKeyMask
                                                timestamp:event.timestamp
                                             windowNumber:event.windowNumber
                                                  context:event.context
                                              eventNumber:event.eventNumber
                                               clickCount:event.clickCount
                                                 pressure:event.pressure];
        } else if (event.type == NSFlagsChanged) {
            substituteEvent = [NSEvent keyEventWithType:event.type
                                               location:event.locationInWindow
                                          modifierFlags:NSCommandKeyMask
                                              timestamp:event.timestamp
                                           windowNumber:event.windowNumber
                                                context:event.context
                                             characters:@""
                            charactersIgnoringModifiers:@""
                                              isARepeat:NO
                                                keyCode:event.keyCode];
        }
    }

    [self mpx_updateTemporaryLinkUnderMouseForEvent:substituteEvent];
}

@end
