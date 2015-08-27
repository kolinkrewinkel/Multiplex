//
//  DVTSourceTextView+MPXEditorClipboardSupport.m
//  Multiplex
//
//  Created by Kolin Krewinkel on 8/26/15.
//  Copyright © 2015 Kolin Krewinkel. All rights reserved.
//

@import JRSwizzle;
@import MPXSelectionCore;

#import <DVTKit/DVTTextStorage.h>

#import "DVTSourceTextView+MPXEditorExtensions.h"

#import "DVTSourceTextView+MPXSwizzling.h"

@implementation DVTSourceTextView (MPXEditorAutocompletion)

- (void)mpx_didInsertCompletionTextAtRange:(NSRange)completedTextRange
{
    __block NSInteger offset = 0;

    // The first range is the one which needs to be outright replaced from the start.
    // What's passed back with `completedTextRange` is the first range's replacement.
    NSArray *selections = ({
        NSMutableArray *selections = [[NSMutableArray alloc] initWithArray:self.mpx_selectionManager.visualSelections];

        MPXSelection *existingSelection = selections[0];

        offset += NSMaxRange(completedTextRange) - NSMaxRange(existingSelection.range);

        selections[0] = [MPXSelection selectionWithRange:completedTextRange];
        selections;
    });

    NSString *completionText = [self.string substringWithRange:completedTextRange];

    // Now, the remaining ranges need to be adjusted to include the text (and adjust the selection.)
    __block NSUInteger idx = 0;
    NSArray *newSelections = [[selections rac_sequence] map:^MPXSelection *(MPXSelection *selection) {
        NSRange selectionRange = selection.range;

        if (idx > 0) {
            selectionRange.location += offset;

            // First, one needs to reverse-enumerate over the completion text. We're looking for the first match of a
            // character, and then traversing back from there. Then we'll know what, if anything, is already available
            // as a base to complete. If nothing is there, the whole string needs to be inserted.
             NSInteger completionStringIndex = [completionText length] - 1;

            // Used as the pointer to walk-back from the selection and see what matches. Essentially, we're wanting to find
            // the first substring to match and go back from there to see if it matches the "full" partial substring to the
            // beginning of it. For instance:
            //
            // (Completing for the word `category`)
            //
            // cate| vs. nate|
            //
            // Only chcking the first char before the selection would not be accurate.
            NSInteger selectionRelativeIndex = 0;

            while (completionStringIndex >= 0) {
                unichar completionChar = [completionText characterAtIndex:completionStringIndex];
                unichar compareStorageChar = [self.string characterAtIndex:(NSMaxRange(selectionRange) - 1) + selectionRelativeIndex];

                if (completionChar == compareStorageChar) {
                    selectionRelativeIndex--;
                }

                // Always decrement, as we're seeking the first match within the completion string that is found in the
                // text. If a match was found, we need to continue walking back.
                completionStringIndex--;
            }

            NSInteger completionStringStartIndex = -selectionRelativeIndex;
            NSInteger insertedStringLength = ([completionText length]) - completionStringStartIndex;

            [self insertText:[completionText substringFromIndex:completionStringStartIndex]
            replacementRange:NSMakeRange(NSMaxRange(selectionRange), 0)];

            offset += insertedStringLength;
        }

        NSRange indentedRange = [self _indentInsertedTextIfNecessaryAtRange:selectionRange];

        NSRange firstPlaceholder = [self rangeOfPlaceholderFromCharacterIndex:indentedRange.location
                                                                      forward:YES
                                                                         wrap:YES
                                                                        limit:indentedRange.length];

        idx++;

        if (firstPlaceholder.location == NSUIntegerMax) {
            NSRange finalEndOfCompletionRange = NSMakeRange(NSMaxRange(indentedRange), 0);
            return [MPXSelection selectionWithRange:finalEndOfCompletionRange];
        }

        return [MPXSelection selectionWithRange:firstPlaceholder];
    }].array;

    self.mpx_selectionManager.finalizedSelections = newSelections;
}

- (BOOL)mpx_shouldAutoCompleteAtLocation:(NSUInteger)location
{
    BOOL internalShouldAutoComplete = [self mpx_shouldAutoCompleteAtLocation:location];
    return (internalShouldAutoComplete && !([self.mpx_selectionManager.visualSelections count] > 1));
}

@end
