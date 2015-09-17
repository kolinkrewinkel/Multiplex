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
#import "DVTSourceTextView+MPXEditorSelectionVisualization.h"
#import "DVTSourceTextView+MPXEditorClipboardSupport.h"

@implementation DVTSourceTextView (MPXEditorClipboardSupport)

#pragma mark - Convenience

- (NSArray *)mpx_clipboardSelectionsWithCaretsOverridingWholeLine:(BOOL)caretsOverrideWholeLine
{
    RACSequence *selectionSequence = [self.mpx_selectionManager.visualSelections rac_sequence];
    RACSequence *allSelectedAttributedStrings = [selectionSequence map:^NSAttributedString *(MPXSelection *selection) {
        NSRange range = selection.range;
        if (caretsOverrideWholeLine && range.length == 0) {
            NSRange lineRange;
            [self.layoutManager lineFragmentUsedRectForGlyphAtIndex:range.location effectiveRange:&lineRange];

            for (MPXSelection *otherSelection in selectionSequence) {
                NSRange otherRange = otherSelection.range;
                if (NSIntersectionRange(otherRange, lineRange).length > 0) {
                    return nil;
                }
            }

            return [self.textStorage.contents attributedSubstringFromRange:lineRange];
        }

        return [self.textStorage.contents attributedSubstringFromRange:range];
    }];

    return [allSelectedAttributedStrings array];
}

#pragma mark - NSResponder

- (void)copy:(id)sender
{
    NSArray *uniqueSelectedStrings = [self mpx_clipboardSelectionsWithCaretsOverridingWholeLine:YES];

    NSMutableAttributedString *attributedStringToCopy = [[NSMutableAttributedString alloc] init];
    [uniqueSelectedStrings enumerateObjectsUsingBlock:^(NSAttributedString *_Nonnull attributedStringSelection,
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
    if (self.mpx_inUndoGroup) {
        self.mpx_inUndoGroup = NO;
        [self.undoManager endUndoGrouping];
        self.mpx_shouldCloseGroupOnNextChange = NO;
    }

    [self.undoManager beginUndoGrouping];
    NSArray *currentSelections = self.mpx_selectionManager.visualSelections;
    [self.undoManager registerUndoWithTarget:self handler:^(id  _Nonnull target) {
        self.mpx_selectionManager.finalizedSelections = currentSelections;
        [self.mpx_textViewSelectionDecorator startBlinking];
    }];

    NSArray *uniqueSelectedStrings = [self mpx_clipboardSelectionsWithCaretsOverridingWholeLine:YES];

    NSMutableAttributedString *attributedStringToCopy = [[NSMutableAttributedString alloc] init];
    [uniqueSelectedStrings enumerateObjectsUsingBlock:^(NSAttributedString *_Nonnull attributedStringSelection,
                                                        NSUInteger idx,
                                                        BOOL * _Nonnull stop) {
        [attributedStringToCopy appendAttributedString:attributedStringSelection];

        if (idx < [uniqueSelectedStrings count] - 1 && [uniqueSelectedStrings count] > 1) {
            [attributedStringToCopy appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        }
    }];

    [[NSPasteboard generalPasteboard] clearContents];
    [[NSPasteboard generalPasteboard] writeObjects:@[attributedStringToCopy]];

    __block NSInteger offset = 0;
    NSMutableArray *newSelections = [NSMutableArray array];
    [self.mpx_selectionManager.visualSelections enumerateObjectsUsingBlock:^(MPXSelection *selection,
                                                                             NSUInteger idx,
                                                                             BOOL * _Nonnull stop) {
        NSRange range = selection.range;
        range.location += offset;

        if (range.length == 0) {
            NSRange lineRange;
            [self.layoutManager lineFragmentUsedRectForGlyphAtIndex:range.location effectiveRange:&lineRange];
            [self.textStorage replaceCharactersInRange:lineRange withString:@"" withUndoManager:self.undoManager];

            [newSelections addObject:[MPXSelection selectionWithRange:NSMakeRange(range.location, 0)]];

            offset -= lineRange.length;
        } else {
            [self.textStorage replaceCharactersInRange:range withString:@"" withUndoManager:self.undoManager];

            [newSelections addObject:[MPXSelection selectionWithRange:NSMakeRange(range.location, 0)]];

            offset -= range.length;
        }
    }];

    [self.undoManager endUndoGrouping];

    self.mpx_selectionManager.finalizedSelections = newSelections;
}

- (void)paste:(id)sender
{
    NSString *clipboardContents = [[NSPasteboard generalPasteboard] stringForType:NSPasteboardTypeString];
    if (!clipboardContents) {
        return;
    }
    
    NSArray *clipboardLines = [clipboardContents componentsSeparatedByString:@"\n"];
    if ([clipboardLines count] == 1 || [clipboardLines count] != [self.mpx_selectionManager.finalizedSelections count]) {
        [self insertText:clipboardContents];
        return;
    }
    
    NSEnumerator *clipboardEnumerator = [clipboardLines objectEnumerator];

    __block NSInteger offset = 0;
    [self mpx_mapAndFinalizeSelectedRanges:^MPXSelection *(MPXSelection *selection) {
        NSRange range = selection.range;
        NSRange offsetRange = NSMakeRange(range.location + offset, range.length);
        NSString *clipboardItemToBeInserted = [clipboardEnumerator nextObject];

        [self.textStorage replaceCharactersInRange:offsetRange
                                        withString:clipboardItemToBeInserted
                                   withUndoManager:self.undoManager];
        
        NSRange newRange = NSMakeRange(offsetRange.location + [clipboardItemToBeInserted length], 0);
        offset -= range.length - [clipboardItemToBeInserted length];

        return [[MPXSelection alloc] initWithSelectionRange:newRange
                                      indexWantedWithinLine:MPXNoStoredLineIndex
                                                     origin:newRange.location];
    } sequentialModification:YES];
}

@end
