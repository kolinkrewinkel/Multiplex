//
//  DVTSourceTextView+MPXSelectionVisualization.m
//  Multiplex
//
//  Created by Kolin Krewinkel on 8/26/15.
//  Copyright © 2015 Kolin Krewinkel. All rights reserved.
//

#import <DVTKit/DVTLayoutManager.h>
#import <DVTKit/DVTTextStorage.h>

#import "DVTSourceTextView+MPXEditorExtensions.h"
#import "DVTSourceTextView+MPXQuickAddNext.h"

#import "DVTSourceTextView+MPXSelectionVisualization.h"

@import libextobjc;
@import MPXSelectionCore;

@implementation DVTSourceTextView (MPXSelectionVisualization)
@synthesizeAssociation(DVTSourceTextView, mpx_textViewSelectionDecorator);

- (void)mpx_viewWillMoveToWindow:(NSWindow *)window
{
    [self mpx_viewWillMoveToWindow:window];

    // Observe the window's state while the view resides in it
    if (window) {
        [[NSNotificationCenter defaultCenter] addObserver:self.mpx_textViewSelectionDecorator
                                                 selector:@selector(startBlinking)
                                                     name:NSWindowDidBecomeKeyNotification
                                                   object:window];

        [[NSNotificationCenter defaultCenter] addObserver:self.mpx_textViewSelectionDecorator
                                                 selector:@selector(stopBlinking)
                                                     name:NSWindowDidResignKeyNotification
                                                   object:window];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidBecomeKeyNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResignKeyNotification object:nil];
    }
    
    NSMenuItem *findMenuItem = [[NSApp mainMenu] itemWithTitle:@"Find"];
    NSMenu *findMenu = findMenuItem.submenu;
    NSMenuItem *quickAddNextItem = [findMenu itemWithTitle:kMPXQuickAddNextMenuItemTitle];
    quickAddNextItem.target = self;
}

- (void)_drawInsertionPointInRect:(CGRect)rect color:(NSColor *)color
{
    // Intentionally no-op to prevent display of the original insertion point.
}

- (void)centerSelectionInVisibleArea:(id)sender
{
    NSUInteger rectCount = 0;
    NSRectArray rectsToCenter = [self.layoutManager rectArrayForCharacterRange:self.selectedRange
                                                  withinSelectedCharacterRange:self.selectedRange
                                                               inTextContainer:(NSTextContainer *)self.textContainer
                                                                     rectCount:&rectCount];

    if (rectCount == 0) {
        return;
    }

    CGRect firstRect = rectsToCenter[0];
    [self.enclosingScrollView scrollRectToVisible:firstRect];
}

- (void)selectAll:(id)sender
{
    NSRange entireDocument = NSMakeRange(0, [self.textStorage.string length]);
    MPXSelection *newSelection = [[MPXSelection alloc] initWithSelectionRange:entireDocument
                                                        indexWantedWithinLine:MPXNoStoredLineIndex
                                                                       origin:0];

    self.mpx_selectionManager.finalizedSelections = @[newSelection];
}

@end
