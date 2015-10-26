//
//  DVTSourceTextView+MPXIndentation.h
//  Multiplex
//
//  Created by Kolin Krewinkel on 10/25/15.
//  Copyright © 2015 Kolin Krewinkel. All rights reserved.
//

#import <DVTKit/DVTSourceTextView.h>

@interface DVTSourceTextView (MPXIndentation)

- (NSRange)mpx_indentRange:(NSRange)range;
- (void)mpx_indentSelection:(id)sender;
- (NSString *)mpx_tabString;

@end
