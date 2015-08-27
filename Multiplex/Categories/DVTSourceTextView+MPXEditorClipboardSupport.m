//
//  DVTSourceTextView+MPXEditorClipboardSupport.m
//  Multiplex
//
//  Created by Kolin Krewinkel on 8/26/15.
//  Copyright © 2015 Kolin Krewinkel. All rights reserved.
//

#import "DVTSourceTextView+MPXEditorClipboardSupport.h"

@implementation DVTSourceTextView (MPXEditorClipboardSupport)

- (void)paste:(id)sender
{
    NSString *clipboardContents = [[NSPasteboard generalPasteboard] stringForType:NSPasteboardTypeString];
    if (!clipboardContents) {
        return;
    }

    [self insertText:clipboardContents];
}

@end
