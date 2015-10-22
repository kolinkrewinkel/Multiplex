//
//  DVTSourceTextView+MPXWhitespaceTrimming.h
//  Multiplex
//
//  Created by Kolin Krewinkel on 10/22/15.
//  Copyright © 2015 Kolin Krewinkel. All rights reserved.
//

#import <DVTKit/DVTSourceTextView.h>

/**
 * Automatic trimming of whitespace, and moving the cursors accordingly.
 */
@interface DVTSourceTextView (MPXWhitespaceTrimming)

/**
 * @param line The line number of the characters to trim
 */
- (void)mpx_trimTrailingWhitespaceOnLine:(NSUInteger)line;

@end
