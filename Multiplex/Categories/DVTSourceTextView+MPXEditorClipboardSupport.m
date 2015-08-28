//
//  DVTSourceTextView+MPXEditorClipboardSupport.m
//  Multiplex
//
//  Created by Kolin Krewinkel on 8/26/15.
//  Copyright © 2015 Kolin Krewinkel. All rights reserved.
//

#import <MPXSelectionCore/MPXSelectionCore.h>
#import <DVTKit/DVTTextStorage.h>

#import "DVTSourceTextView+MPXEditorExtensions.h"

#import "DVTSourceTextView+MPXEditorClipboardSupport.h"

@implementation DVTSourceTextView (MPXEditorClipboardSupport)

- (void)copy:(id)sender
{
    NSArray *selectedAttributedStrings =
    [[self.mpx_selectionManager.visualSelections rac_sequence] map:^NSAttributedString *(MPXSelection *selection) {
        return [self.textStorage.contents attributedSubstringFromRange:selection.range];
    }].array;

    NSMutableAttributedString *attributedStringToCopy = [[NSMutableAttributedString alloc] init];
    [selectedAttributedStrings enumerateObjectsUsingBlock:^(NSAttributedString *_Nonnull attributedStringSelection,
                                                            NSUInteger idx,
                                                            BOOL * _Nonnull stop) {
        [attributedStringToCopy appendAttributedString:attributedStringSelection];

        if (idx < [selectedAttributedStrings count] - 1 && [selectedAttributedStrings count] > 1) {
            [attributedStringToCopy appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        }
    }];

    [[NSPasteboard generalPasteboard] clearContents];
    [[NSPasteboard generalPasteboard] writeObjects:@[attributedStringToCopy]];
}

- (void)paste:(id)sender
{
    NSString *clipboardContents = [[NSPasteboard generalPasteboard] stringForType:NSPasteboardTypeString];
    if (!clipboardContents) {
        return;
    }

    [self insertText:clipboardContents];
}

@end
