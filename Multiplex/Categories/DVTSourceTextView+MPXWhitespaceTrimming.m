//
//  DVTSourceTextView+MPXWhitespaceTrimming.m
//  Multiplex
//
//  Created by Kolin Krewinkel on 10/22/15.
//  Copyright © 2015 Kolin Krewinkel. All rights reserved.
//

@import libextobjc;

#import <DVTKit/DVTTextStorage.h>
#import <DVTFoundation/DVTTextPreferences.h>

#import "DVTSourceTextView+MPXEditorExtensions.h"
#import "MPXSelection.h"
#import "MPXSelectionManager.h"
#import "MPXSelectionMutation.h"

#import "DVTSourceTextView+MPXWhitespaceTrimming.h"

@implementation DVTSourceTextView (MPXWhitespaceTrimming)

- (void)mpx_trimTrailingWhitespaceOnLine:(NSUInteger)line
{
    // `lineRange` is a range of line numbers. Just get the line for the number we're given.
    NSRange characterRange = [self.textStorage characterRangeForLineRange:NSMakeRange(line, 1)];
    NSString *lineToTrim = [self.textStorage.string substringWithRange:characterRange];

    // Attempt to find anything other than the whitespace charset (and newline) to determine if the line is whitespace
    // only, searching from the end so we don't trim leading whitespace.
    NSCharacterSet *whitespaceAndNewlineSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSRange lastNonWhitespaceStringRange = [lineToTrim rangeOfCharacterFromSet:[whitespaceAndNewlineSet invertedSet]
                                                                       options:NSBackwardsSearch];
    
    // Do not trim a line that's only whitespace if the user only wants regular trailing whitespace trimmed.
    BOOL whitespaceOnly = lastNonWhitespaceStringRange.length == 0;
    if (whitespaceOnly && ![[DVTTextPreferences preferences] trimWhitespaceOnlyLines]) {
        return;
    }
    
    // Track the absolute indexes (relative to the whole text view's string) of the whitespace that's removed.
    NSMutableIndexSet *whitespaceRemoved = [[NSMutableIndexSet alloc] init];
    NSCharacterSet *whitespaceSet = [NSCharacterSet whitespaceCharacterSet];

    // If the line is whitespace only, search for whitespace from the beginning. Otherwise, start from the last real
    // character and work towards the end of the line.
    NSUInteger indexToSearchFrom = whitespaceOnly ? 0 : NSMaxRange(lastNonWhitespaceStringRange);
    NSRange rangeRemainingToSearch = NSMakeRange(indexToSearchFrom, lineToTrim.length - indexToSearchFrom);

    NSRange nextWhitespaceRange = [lineToTrim rangeOfCharacterFromSet:whitespaceSet
                                                              options:0
                                                                range:rangeRemainingToSearch];
    while (nextWhitespaceRange.length > 0) {        
        // Normalize the whitespace range so that it's relative to the whole text view string.
        NSRange normalizedWhitespaceRange = NSMakeRange(characterRange.location + nextWhitespaceRange.location,
                                                        nextWhitespaceRange.length);
        [whitespaceRemoved addIndexesInRange:normalizedWhitespaceRange];

        // Advance forward within the line to keep finding new search results, moving from left to right.
        rangeRemainingToSearch = NSMakeRange(NSMaxRange(nextWhitespaceRange),
                                              lineToTrim.length - NSMaxRange(nextWhitespaceRange));
        nextWhitespaceRange = [lineToTrim rangeOfCharacterFromSet:whitespaceSet options:0 range:rangeRemainingToSearch];
    }
    
    __block NSUInteger characterChangeDelta = 0;
    [whitespaceRemoved enumerateRangesUsingBlock:^(NSRange range, BOOL * _Nonnull stop) {        
        NSRange offsetRange = NSMakeRange(range.location - characterChangeDelta, range.length);
        [self.textStorage replaceCharactersInRange:offsetRange withString:@""];
        
        characterChangeDelta += range.length;
    }];
    
    MPXSelectionMutationBlock transformBlock = ^MPXSelectionMutation *(MPXSelection *selectionToModify) {
        NSRange selectionRange = selectionToModify.range;

        NSRange rangeUpToSelection = NSMakeRange(0, selectionRange.location);
        NSUInteger shift = [whitespaceRemoved countOfIndexesInRange:rangeUpToSelection];

        MPXSelection *newSelection = [[MPXSelection alloc] initWithSelectionRange:NSMakeRange(selectionRange.location - shift, selectionRange.length)
                                                            indexWantedWithinLine:selectionToModify.indexWantedWithinLine
                                                                           origin:selectionToModify.origin];
        return [[MPXSelectionMutation alloc] initWithInitialSelection:selectionToModify
                                                       finalSelection:newSelection
                                                          mutatedText:NO];
    };

    [self.mpx_selectionManager mapSelectionsWithMovementDirection:NSSelectionAffinityUpstream
                                              modifyingSelections:NO
                                                       usingBlock:transformBlock];
}

@end
