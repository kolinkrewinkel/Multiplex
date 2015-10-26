//
//  DVTSourceTextView+MPXIndentation.m
//  Multiplex
//
//  Created by Kolin Krewinkel on 10/25/15.
//  Copyright © 2015 Kolin Krewinkel. All rights reserved.
//

#import <DVTFoundation/DVTTextPreferences.h>

#import <DVTKit/DVTTextStorage.h>

#import "DVTSourceTextView+MPXEditorExtensions.h"
#import "MPXSelection.h"
#import "MPXSelectionManager.h"
#import "MPXSelectionMutation.h"

#import "DVTSourceTextView+MPXIndentation.h"

@implementation DVTSourceTextView (MPXIndentation)

- (NSString *)mpx_tabString
{
    DVTTextPreferences *preferences = [DVTTextPreferences preferences];
    if (preferences.useTabsToIndent) {
        return @"\t";
    }

    NSMutableString *spaceTabString = [NSMutableString string];

    NSUInteger spaceCount = preferences.tabWidth;
    for (NSUInteger spacesAdded = 0; spacesAdded < spaceCount; spacesAdded++) {
        [spaceTabString appendString:@" "];
    }

    return spaceTabString;
}

- (void)mpx_indentSelection:(id)arg1
{
    MPXSelectionMutationBlock transformBlock = ^MPXSelectionMutation *(MPXSelection *selectionToModify) {
        NSRange lineRange = selectionToModify.range;
        NSRange newRange = [self mpx_indentRange:lineRange];

        MPXSelection *newSelection = selectionToModify;
        BOOL mutatedText = !NSEqualRanges(lineRange, newRange);
        if (mutatedText) {
            newSelection = [[MPXSelection alloc] initWithSelectionRange:newRange
                                                  indexWantedWithinLine:selectionToModify.indexWantedWithinLine
                                                                 origin:selectionToModify.origin];
        }

        return [[MPXSelectionMutation alloc] initWithInitialSelection:selectionToModify
                                                       finalSelection:newSelection
                                                          mutatedText:mutatedText];
    };

    [self.mpx_selectionManager mapSelectionsWithMovementDirection:NSSelectionAffinityDownstream
                                              modifyingSelections:NO
                                                       usingBlock:transformBlock];
}

- (NSRange)mpx_indentRange:(NSRange)range
{
    [self.textStorage beginEditing];

    NSUInteger changeIndex = [self.textStorage currentChangeIndex];
    [self.textStorage indentCharacterRange:range undoManager:self.undoManager];

    // Adjusting ranges that are > 0 chars doesn't work, so we feed it a 0-length version and calculate the delta.
    NSRange zeroLengthRange = NSMakeRange(range.location, 0);
    NSRange adjustedRange = [self _adjustedSelectedRange:zeroLengthRange fromChangeIndex:changeIndex];

    NSInteger shift = 0;
    if (adjustedRange.location >= range.location) {
        shift = adjustedRange.location - range.location;
    } else {
        shift = range.location - adjustedRange.location;
        shift *= -1;
    }

    [self.textStorage endEditing];

    return NSMakeRange(range.location + shift, range.length);
}

@end
