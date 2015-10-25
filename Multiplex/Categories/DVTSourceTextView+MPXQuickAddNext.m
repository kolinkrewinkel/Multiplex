//
//  DVTSourceTextView+MPXQuickAddNext.m
//  Multiplex
//
//  Created by Kolin Krewinkel on 9/19/15.
//  Copyright © 2015 Kolin Krewinkel. All rights reserved.
//

@import MPXSelectionCore;

#import <DVTKit/DVTLayoutManager.h>
#import <DVTKit/DVTTextStorage.h>

#import "DVTSourceTextView+MPXEditorExtensions.h"
#import "DVTSourceTextView+MPXSelectionVisualization.h"

#import "DVTSourceTextView+MPXQuickAddNext.h"

NSString *kMPXQuickAddNextMenuItemTitle = @"Quick Add Next";

@implementation DVTSourceTextView (MPXQuickAddNext)

+ (void)mpx_addQuickAddNextMenuItem
{
    NSMenuItem *findMenuItem = [[NSApp mainMenu] itemWithTitle:@"Find"];
    NSMenu *findMenu = findMenuItem.submenu;
    if ([findMenu itemWithTitle:kMPXQuickAddNextMenuItemTitle]) {
        return;
    }

    // Add a divider between the native stuff and Multiplex's.
    [findMenu addItem:[NSMenuItem separatorItem]];

    NSMenuItem *quickAddNextItem = [[NSMenuItem alloc] initWithTitle:kMPXQuickAddNextMenuItemTitle
                                                              action:@selector(mpx_quickAddNext:)
                                                       keyEquivalent:@"D"];
    quickAddNextItem.keyEquivalent = @"d";
    quickAddNextItem.keyEquivalentModifierMask = NSCommandKeyMask;
    quickAddNextItem.target = self;
    [findMenu addItem:quickAddNextItem];

    NSMenuItem *editMenuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
    NSMenu *editMenu = editMenuItem.submenu;

    NSMenuItem *duplicateItem = [editMenu itemWithTitle:@"Duplicate"];
    duplicateItem.keyEquivalentModifierMask = NSCommandKeyMask | NSAlternateKeyMask;
}

- (void)mpx_quickAddNext:(id)sender
{
    NSArray *visualSelections = self.mpx_selectionManager.visualSelections;
    MPXSelection *lastSelection = [visualSelections lastObject];

    NSUInteger locationToSearchFrom = lastSelection.insertionIndex;
    if (lastSelection.range.length == 0) {
        locationToSearchFrom = [self.textStorage currentWordAtIndex:lastSelection.insertionIndex].location;
    }

    NSRange searchWithinRange = NSMakeRange(locationToSearchFrom, self.textStorage.string.length - locationToSearchFrom);

    NSString *stringToSearchFor = [self mpx_stringForQuickAddNext];
    NSRange nextRange = [self.textStorage.string rangeOfString:stringToSearchFor options:0 range:searchWithinRange];

    if (nextRange.length == 0) {
        return;
    }

    MPXSelection *newSelection = [[MPXSelection alloc] initWithSelectionRange:nextRange
                                                        indexWantedWithinLine:MPXNoStoredLineIndex
                                                                       origin:nextRange.location];
    self.mpx_selectionManager.finalizedSelections = [visualSelections arrayByAddingObject:newSelection];
    [self.mpx_textViewSelectionDecorator startBlinking];
}

- (NSString *)mpx_stringForQuickAddNext
{
    NSString *stringToMatch = nil;
    for (MPXSelection *selection in self.mpx_selectionManager.visualSelections) {
        NSString *selectionString = [self.textStorage.string substringWithRange:selection.range];

        // Find the word it's in if the selection is just a caret.
        if (selectionString.length == 0) {
            NSRange wordRange = [self.textStorage currentWordAtIndex:selection.range.location];

            if (wordRange.length == 0) {
                selectionString = nil;
            } else {
                selectionString = [self.textStorage.string substringWithRange:wordRange];
            }
        }

        if (!stringToMatch) {
            stringToMatch = selectionString;
            continue;
        }

        if (![stringToMatch isEqualToString:selectionString]) {
            stringToMatch = nil;
            break;
        }
    }

    return stringToMatch;
}

@end
