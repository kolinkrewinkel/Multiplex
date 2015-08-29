//
//  DVTSourceTextView+MPXEditorClipboardSupport.m
//  Multiplex
//
//  Created by Kolin Krewinkel on 8/26/15.
//  Copyright © 2015 Kolin Krewinkel. All rights reserved.
//

#import <MPXSelectionCore/MPXSelectionCore.h>
#import <DVTKit/DVTTextStorage.h>
#import <DVTKit/DVTLayoutManager.h>

#import "DVTSourceTextView+MPXEditorExtensions.h"

#import "DVTSourceTextView+MPXEditorClipboardSupport.h"

@implementation DVTSourceTextView (MPXEditorClipboardSupport)

#pragma mark - NSResponder

- (void)copy:(id)sender
{
    RACSequence *allSelectedAttributedStrings =
    [[self.mpx_selectionManager.visualSelections rac_sequence] map:^NSAttributedString *(MPXSelection *selection) {
        NSRange range = selection.range;
        if (range.length == 0) {
            NSRange lineRange;
            [self.layoutManager lineFragmentUsedRectForGlyphAtIndex:range.location effectiveRange:&lineRange];
            return [self.textStorage.contents attributedSubstringFromRange:lineRange];
        }

        return [self.textStorage.contents attributedSubstringFromRange:range];
    }];

    NSSet *uniqueSelectedStrings = [NSSet setWithArray:[allSelectedAttributedStrings array]];

    NSMutableAttributedString *attributedStringToCopy = [[NSMutableAttributedString alloc] init];
    [uniqueSelectedStrings.allObjects enumerateObjectsUsingBlock:^(NSAttributedString *_Nonnull attributedStringSelection,
                                                                   NSUInteger idx,
                                                                   BOOL * _Nonnull stop) {
        [attributedStringToCopy appendAttributedString:attributedStringSelection];

        if (idx < [uniqueSelectedStrings count] - 1 && [uniqueSelectedStrings count] > 1) {
            [attributedStringToCopy appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        }
    }];

    [[NSPasteboard generalPasteboard] clearContents];
    [[NSPasteboard generalPasteboard] writeObjects:@[attributedStringToCopy]];
}

- (void)cut:(id)sender
{
    [self copy:sender];

//    [self.mpx_selectionManager.visualSelections]
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
