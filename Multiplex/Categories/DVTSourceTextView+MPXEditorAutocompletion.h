//
//  DVTSourceTextView+MPXEditorClipboardSupport.h
//  Multiplex
//
//  Created by Kolin Krewinkel on 8/26/15.
//  Copyright © 2015 Kolin Krewinkel. All rights reserved.
//

#import <DVTKit/DVTSourceTextView.h>

@interface DVTSourceTextView (MPXEditorAutocompletion)

- (BOOL)mpx_shouldAutoCompleteAtLocation:(NSUInteger)location;
- (void)mpx_didInsertCompletionTextAtRange:(NSRange)range;

@end
