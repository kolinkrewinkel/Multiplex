//
//  DVTSourceTextView+MPXQuickAddNext.h
//  Multiplex
//
//  Created by Kolin Krewinkel on 9/19/15.
//  Copyright © 2015 Kolin Krewinkel. All rights reserved.
//

#import <DVTKit/DVTSourceTextView.h>

extern NSString *kMPXQuickAddNextMenuItemTitle;

/**
 * Handles the "Quick Add Next" menu item, and the logic to handle selecting the current word and the next instance of
 * it.
 */
@interface DVTSourceTextView (MPXQuickAddNext)

/**
 * Injects the "Quick Add Next" menu item into the "Find" menu.
 */
+ (void)mpx_addQuickAddNextMenuItem;

/**
 * Used as the string to search for (grabs the current word enclosing the cursor, or the homogenous word(s) currently
 * selected. Also used for validating the menu item (-validateMenuItem:).
 */
- (NSString *)mpx_stringForQuickAddNext;

/**
 * Finds and adds the next instance of the current word (-mpx_stringForQuickAddNext).
 */
- (void)mpx_quickAddNext:(id)sender;

@end
