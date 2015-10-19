//
//  IDESourceCodeEditor+CATViewReplacement.m
//  Multiplex
//
//  Created by Kolin Krewinkel on 9/25/14.
//  Copyright (c) 2015 Kolin Krewinkel. All rights reserved.
//

@import MPXFoundation;
@import MPXSelectionCore;
@import ReactiveCocoa;

#import <DVTFoundation/DVTTextPreferences.h>

#import <DVTKit/DVTDefaultSourceLanguageService.h>
#import <DVTKit/DVTLayoutManager.h>
#import <DVTKit/DVTSourceLanguageService.h>
#import <DVTKit/DVTTextCompletionController.h>
#import <DVTKit/DVTTextStorage.h>
#import <DVTKit/DVTTextCompletionSession.h>
#import <DVTKit/DVTTextCompletionInlinePreviewController.h>

#import <libextobjc/EXTSynthesize.h>

#import "DVTSourceTextView+MPXEditorExtensions.h"
#import "DVTSourceTextView+MPXEditorSelectionVisualization.h"

NSString *kMPXQuickAddNextMenuItemTitle = @"Quick Add Next";

static NSString *kMPXNewlineString = @"\n";

@implementation DVTSourceTextView (MPXEditorExtensions)
@synthesizeAssociation(DVTSourceTextView, mpx_selectionManager);
@synthesizeAssociation(DVTSourceTextView, mpx_inUndoGroup);
@synthesizeAssociation(DVTSourceTextView, mpx_shouldCloseGroupOnNextChange);
@synthesizeAssociation(DVTSourceTextView, mpx_trimTrailingWhitespace);

#pragma mark - Initializer

- (void)mpx_commonInitDVTSourceTextView
{
    [self mpx_commonInitDVTSourceTextView];
    
    self.mpx_textViewSelectionDecorator = [[MPXTextViewSelectionDecorator alloc] initWithTextView:self];
    
    self.mpx_selectionManager = [[MPXSelectionManager alloc] initWithTextView:self];
    self.mpx_selectionManager.visualizationDelegate = self.mpx_textViewSelectionDecorator;
    
    self.selectedTextAttributes = @{};
    
    self.mpx_trimTrailingWhitespace = self.shouldTrimTrailingWhitespace;
}

+ (void)mpx_addQuickAddNextMenuItem
{
    NSMenuItem *findMenuItem = [[NSApp mainMenu] itemWithTitle:@"Find"];
    NSMenu *findMenu = findMenuItem.submenu;
    if ([findMenu itemWithTitle:kMPXQuickAddNextMenuItemTitle]) {
        return;
    }    
    
    // Add a divider between the native stuff and Multiplex's.
    [findMenu addItem:[NSMenuItem separatorItem]];
    
    NSMenuItem *quickAddNextItem = [[NSMenuItem alloc] initWithTitle:kMPXQuickAddNextMenuItemTitle
                                                              action:@selector(mpx_quickAddNext:)
                                                       keyEquivalent:@"D"];
    quickAddNextItem.keyEquivalent = @"d";
    quickAddNextItem.keyEquivalentModifierMask = NSCommandKeyMask; 
    quickAddNextItem.target = self;
    [findMenu addItem:quickAddNextItem];
    
    NSMenuItem *editMenuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
    NSMenu *editMenu = editMenuItem.submenu;
    
    NSMenuItem *duplicateItem = [editMenu itemWithTitle:@"Duplicate"];
    duplicateItem.keyEquivalentModifierMask = NSCommandKeyMask | NSAlternateKeyMask;
}

- (void)mpx_quickAddNext:(id)sender
{
    NSArray *visualSelections = self.mpx_selectionManager.visualSelections; 
    MPXSelection *lastSelection = [visualSelections lastObject];
    
    NSUInteger locationToSearchFrom = lastSelection.insertionIndex;
    if (lastSelection.range.length == 0) {
        locationToSearchFrom = [self.textStorage currentWordAtIndex:lastSelection.insertionIndex].location;
    }
    
    NSRange searchWithinRange = NSMakeRange(locationToSearchFrom, self.textStorage.string.length - locationToSearchFrom);
    
    NSString *stringToSearchFor = [self mpx_stringForQuickAddNext];    
    NSRange nextRange = [self.textStorage.string rangeOfString:stringToSearchFor options:0 range:searchWithinRange]; 
    
    if (nextRange.length == 0) {
        return;
    }
    
    MPXSelection *newSelection = [[MPXSelection alloc] initWithSelectionRange:nextRange
                                                        indexWantedWithinLine:MPXNoStoredLineIndex
                                                                       origin:nextRange.location];       
    self.mpx_selectionManager.finalizedSelections = [visualSelections arrayByAddingObject:newSelection];
    [self.mpx_textViewSelectionDecorator startBlinking];
}

- (NSString *)mpx_stringForQuickAddNext
{
    NSString *stringToMatch = nil;
    for (MPXSelection *selection in self.mpx_selectionManager.visualSelections) {
        NSString *selectionString = [self.textStorage.string substringWithRange:selection.range];
        
        // Find the word it's in if the selection is just a caret.
        if (selectionString.length == 0) {
            NSRange wordRange = [self.textStorage currentWordAtIndex:selection.range.location];
            
            if (wordRange.length == 0) {
                selectionString = nil;
            } else {
                selectionString = [self.textStorage.string substringWithRange:wordRange];
            }
        }
        
        if (!stringToMatch) {
            stringToMatch = selectionString;
            continue;
        }
        
        if (![stringToMatch isEqualToString:selectionString]) {
            stringToMatch = nil;
            break;
        }
    }
    
    return stringToMatch;
}

- (void)undo:(id)sender
{
    if (self.mpx_inUndoGroup) {
        self.mpx_inUndoGroup = NO;
        [self.undoManager endUndoGrouping];
    }
    
    [self.undoManager undoNestedGroup];
}

- (NSRange)mpx_rangeOfCompletionPlaceholderForSelection:(MPXSelection *)selection
{
    DVTDefaultSourceLanguageService *service = (DVTDefaultSourceLanguageService *)self.textStorage.languageService;
    
    if ([service isKindOfClass:[DVTDefaultSourceLanguageService class]]
        && selection.insertionIndex > 0
        && [service isIncompletionPlaceholderAtLocation:selection.insertionIndex - 1]) {                
        
        return [self rangeOfPlaceholderFromCharacterIndex:selection.range.location - 1
                                                  forward:YES
                                                     wrap:NO
                                                    limit:NSMaxRange(selection.range)];
    }
    
    return NSMakeRange(NSUIntegerMax, 0);
}

- (BOOL)mpx_shouldInsertText:(NSString *)insertText withNextCharacter:(NSString *)nextCharacter
{
    for (NSString *typeoverString in @[@"]", @"}", @")", @"\"", @"'", @";"]) {
        if ([nextCharacter isEqualToString:typeoverString] && [insertText isEqualToString:typeoverString]) {
            return NO;
        }
    } 
    
    return YES;
}

#pragma mark - Keyboard Events

- (void)insertText:(id)insertObject
{
    // Prevents random stuff being thrown in.
    if (![insertObject isKindOfClass:[NSString class]]) {
        return;
    }
    
    NSString *insertString = (NSString *)insertObject;
    
    if (self.mpx_shouldCloseGroupOnNextChange && self.mpx_inUndoGroup) {
        self.mpx_inUndoGroup = NO;
        [self.undoManager endUndoGrouping];
        self.mpx_shouldCloseGroupOnNextChange = NO;
    }
    
    if (!self.mpx_inUndoGroup) {
        self.mpx_inUndoGroup = YES;
        self.mpx_shouldCloseGroupOnNextChange = NO;
        
        [self.undoManager beginUndoGrouping];
        
        NSArray *currState = self.mpx_selectionManager.finalizedSelections;
        [self.undoManager registerUndoWithTarget:self handler:^(id  _Nonnull target) {
            self.mpx_selectionManager.finalizedSelections = currState;
            [self.mpx_textViewSelectionDecorator startBlinking];
        }];
    }
    
    [self.completionController textViewShouldInsertText:self];
    
    MPXSelectionMutationBlock transformBlock = ^MPXSelectionMutation *(MPXSelection *selection) {
        NSRange range = selection.range;
        
        NSRange placeholderRange = [self mpx_rangeOfCompletionPlaceholderForSelection:selection];        
        if (placeholderRange.length > 0) {
            // This is an awful hack to make -replaceSelectedTokenWithTokenText expand the right token.
            self.selectedRange = placeholderRange;
            [self replaceSelectedTokenWithTokenText];
            
            // -replaceSelectedTokenWithTokenText will then assign the result of expanding the token to
            // -selectedRange, so we read from that.
            NSRange newSelectionRange = self.selectedRange;
            
            if ([insertString isEqualToString:kMPXNewlineString]) {
                MPXSelection *newSelection = [[MPXSelection alloc] initWithSelectionRange:newSelectionRange
                                                                    indexWantedWithinLine:MPXNoStoredLineIndex
                                                                                   origin:newSelectionRange.location];
                return [[MPXSelectionMutation alloc] initWithInitialSelection:selection
                                                               finalSelection:newSelection
                                                                  mutatedText:YES];
            }
            
            range = newSelectionRange;            
        }
                
        // Gets subtracted from NSMaxRange() of modifiedInsertString.
        NSString *modifiedInsertString = insertString;        
        NSUInteger offsetForCursor = 0;
                
        NSString *nextChar = nil;
        if ([self.textStorage.string length] - 1 > selection.insertionIndex + 1) {
            nextChar = [self.textStorage.string substringWithRange:NSMakeRange(selection.insertionIndex, 1)];
        }
        
        if ([nextChar isEqualToString:@"}"]) {
            if (selection.insertionIndex - 1 > 0) {
                NSString *currChar = [self.textStorage.string substringWithRange:NSMakeRange(selection.insertionIndex - 1, 1)];
                if ([currChar isEqualToString:@"{"] && [insertString isEqualToString:kMPXNewlineString]) {
                    modifiedInsertString = @"\n\n";
                    offsetForCursor = 1;
                }
            }
        }
        
        if (![self mpx_shouldInsertText:modifiedInsertString withNextCharacter:nextChar]) {
            NSUInteger newIndex = selection.insertionIndex + 1;
            MPXSelection *newSelection = [[MPXSelection alloc] initWithSelectionRange:NSMakeRange(newIndex, 0)
                                                                indexWantedWithinLine:MPXNoStoredLineIndex
                                                                               origin:newIndex];
            return [[MPXSelectionMutation alloc] initWithInitialSelection:selection
                                                           finalSelection:newSelection
                                                              mutatedText:NO];
        }
        
        [self.textStorage replaceCharactersInRange:range withString:modifiedInsertString withUndoManager:self.undoManager];
        
        NSUInteger delta = [modifiedInsertString length] - range.length;
        
        __block NSRange rangeOfInsertedText = NSMakeRange(range.location, [modifiedInsertString length]);
        if ([modifiedInsertString rangeOfString:kMPXNewlineString].length > 0) {                        
            __block NSUInteger index = rangeOfInsertedText.location;    
            [modifiedInsertString enumerateLinesUsingBlock:^(NSString * _Nonnull line, BOOL * _Nonnull stop) {
                NSString *lineToIndent = line;
                if (line.length == 0) {
                    NSUInteger locationToSearchForwardFrom = index + [kMPXNewlineString length];
                    NSRange rangeToSearchThrough = NSMakeRange(locationToSearchForwardFrom, self.string.length - locationToSearchForwardFrom);
                    NSRange nextNewline = [self.string rangeOfString:kMPXNewlineString options:0 range:rangeToSearchThrough];
                    if (nextNewline.length > 0) {
                        NSRange lineComponentRange = NSMakeRange(locationToSearchForwardFrom, NSMaxRange(nextNewline) - locationToSearchForwardFrom);
                        NSString *lineComponentToAppend = [self.string substringWithRange:lineComponentRange];
                        lineToIndent = [line stringByAppendingString:lineComponentToAppend];                        
                    }
                }
                
                NSRange lineRange = NSMakeRange(index + [kMPXNewlineString length], [lineToIndent length] + [kMPXNewlineString length]);                                
                NSRange indentedRange = [self mpx_indentRange:lineRange];
                
                if (NSMaxRange(rangeOfInsertedText) >= lineRange.location) {
                    rangeOfInsertedText.location += indentedRange.location - lineRange.location;
                }

                index = NSMaxRange(indentedRange);
            }];        
        }
        
        NSString *matchingBrace = [self followupStringToMakePair:modifiedInsertString];       
        if (matchingBrace && [[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:[nextChar characterAtIndex:0]]) {
            NSRange matchingBraceRange = NSMakeRange(NSMaxRange(range) + delta, 0);
            [self.textStorage replaceCharactersInRange:matchingBraceRange
                                            withString:matchingBrace
                                       withUndoManager:self.undoManager];
        }
                
        NSUInteger relativeLinePosition = selection.indexWantedWithinLine;
        
        if (relativeLinePosition == NSNotFound) {
            NSRange lineRange;
            (void)[self.layoutManager lineFragmentRectForGlyphAtIndex:NSMaxRange(range) effectiveRange:&lineRange];

            relativeLinePosition = NSMaxRange(range) - lineRange.location;
        }
        
        // Move cursor (or range-selection) to the end of what was just added with 0-length.
        NSRange newInsertionPointRange = NSMakeRange(NSMaxRange(rangeOfInsertedText) - offsetForCursor, 0);
        MPXSelection *newSelection = [[MPXSelection alloc] initWithSelectionRange:newInsertionPointRange
                                                            indexWantedWithinLine:relativeLinePosition
                                                                           origin:newInsertionPointRange.location];
        
        return [[MPXSelectionMutation alloc] initWithInitialSelection:selection
                                                       finalSelection:newSelection
                                                          mutatedText:YES];
    };
    
    [self.mpx_selectionManager mapSelectionsWithMovementDirection:NSSelectionAffinityDownstream
                                              modifyingSelections:NO
                                                       usingBlock:transformBlock];
    
    [self centerSelectionInVisibleArea:self];
    
    [self.completionController textViewDidInsertText];
    [self.completionController _textViewTextDidChange:self];
}

- (void)deleteBackward:(id)sender
{
    // Sequential (negative) offset of characters added.
    __block NSUInteger totalDelta = 0;
    
    [self mpx_mapAndFinalizeSelectedRanges:^MPXSelection *(MPXSelection *selection) {
        // Update the base range with the delta'd amount of change from previous mutations.
        NSRange range = [selection range];
        NSRange offsetRange = NSMakeRange(range.location - totalDelta, range.length);
        
        NSRange deletingRange = NSMakeRange(0, 0);
        if (offsetRange.location > 0 && offsetRange.length == 0) {
            deletingRange = NSMakeRange(offsetRange.location - 1, 1);
        } else {
            deletingRange = NSMakeRange(offsetRange.location, offsetRange.length);
        }
        
        // Delete the characters
        [self insertText:@"" replacementRange:deletingRange];
        
        // New range for the beam (to the beginning of the range we replaced)
        NSRange newInsertionPointRange = NSMakeRange(deletingRange.location, 0);
        MPXSelection *newSelection = [MPXSelection selectionWithRange:newInsertionPointRange];
        
        // Increment/decrement the delta by how much we trimmed.
        totalDelta += deletingRange.length;
        
        return newSelection;
    }];
}

#pragma mark - Indentations/Other insertions

- (void)insertNewline:(id)sender
{
    BOOL shouldTrimTrailingWhitespace = [self mpx_shouldTrimTrailingWhitespace];
    
    self.mpx_trimTrailingWhitespace = NO;
    [self insertText:kMPXNewlineString];
    self.mpx_trimTrailingWhitespace = shouldTrimTrailingWhitespace;
}

- (BOOL)handleInsertBackTab
{
    return [self mpx_handleTabInDirection:NSSelectionAffinityUpstream];
}

- (BOOL)handleInsertTab
{
    if ([self mpx_handleTabInDirection:NSSelectionAffinityDownstream]) {
        return YES;
    }
    
    BOOL shouldTrimTrailingWhitespace = [self mpx_shouldTrimTrailingWhitespace];
    self.mpx_trimTrailingWhitespace = NO;
    
    NSString *tabString = [self mpx_tabString];
    [self insertText:tabString];
    
    self.mpx_trimTrailingWhitespace = shouldTrimTrailingWhitespace;
    
    return YES;
}

- (BOOL)mpx_handleTabInDirection:(NSSelectionAffinity)direction
{
    if ([self.mpx_selectionManager.finalizedSelections count] == 1) {
        MPXSelection *selection = [self.mpx_selectionManager.finalizedSelections firstObject];
        
        // Use the actual line to allow skipping to a placeholder that's only soft word-wrapped.
        NSRange lineRange = [self.string lineRangeForRange:selection.range];
        
        BOOL forward = direction == NSSelectionAffinityDownstream; 
        
        // Get the next placeholder within the line.
        NSRange placeholderOnSameLine = [self rangeOfPlaceholderFromCharacterIndex:selection.range.location
                                                                           forward:forward
                                                                              wrap:NO
                                                                             limit:NSMaxRange(lineRange)];
        
        if (placeholderOnSameLine.length > 0) {
            [self mpx_mapAndFinalizeSelectedRanges:^MPXSelection *(MPXSelection *selection) {               
                // Select the entirety of the next placeholder for quick typing-over/deletion.
                return [[MPXSelection alloc] initWithSelectionRange:placeholderOnSameLine
                                              indexWantedWithinLine:MPXNoStoredLineIndex
                                                             origin:placeholderOnSameLine.location];
            } sequentialModification:NO modifyingExistingSelections:NO movementDirection:NSSelectionAffinityDownstream];
            
            return YES;
        }
    }
    
    return NO;
}

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

- (BOOL)mpx_shouldTrimTrailingWhitespace
{
    return self.mpx_trimTrailingWhitespace;
}

#pragma mark - Range Manipulation

- (BOOL)mpx_validateMenuItem:(NSMenuItem *)item
{
    SEL theAction = item.action;
    if (theAction == @selector(copy:) || theAction == @selector(cut:)) {
        return [self.mpx_selectionManager.visualSelections count] > 0;
    } else if (theAction == @selector(mpx_quickAddNext:)) {
        return [self mpx_stringForQuickAddNext] != nil;
    }
    
    return [self mpx_validateMenuItem:item];
}

- (void)selectAll:(id)sender
{
    self.mpx_selectionManager.finalizedSelections = @[[MPXSelection selectionWithRange:NSMakeRange(0, [self.textStorage.string length])]];
}

- (void)mpx_mapAndFinalizeSelectedRanges:(MPXSelection * (^)(MPXSelection *selection))mapBlock
{
    [self mpx_mapAndFinalizeSelectedRanges:mapBlock
                    sequentialModification:NO
               modifyingExistingSelections:NO
                         movementDirection:NSSelectionAffinityDownstream];
}

- (void)mpx_mapAndFinalizeSelectedRanges:(MPXSelection * (^)(MPXSelection *selection))mapBlock
                  sequentialModification:(BOOL)sequentialModification
             modifyingExistingSelections:(BOOL)modifySelection
                       movementDirection:(NSSelectionAffinity)movementDirection;
{
    NSArray *mappedValues = [[[self.mpx_selectionManager.visualSelections rac_sequence] map:mapBlock] array];
    NSArray *placeholderFixedValues =
    [self.mpx_selectionManager preprocessedPlaceholderSelectionsForSelections:mappedValues
                                                            movementDirection:movementDirection
                                                              modifySelection:modifySelection];
    
    self.mpx_selectionManager.finalizedSelections = placeholderFixedValues;
}

- (NSString *)followupStringToMakePair:(NSString *)originalInsertString
{
    if ([originalInsertString length] != 1) {
        return nil;
    }
    
    if ([originalInsertString isEqualToString:@"["]) {
        return @"]";
    } else if ([originalInsertString isEqualToString:@"{"]) {
        return @"}";
    } else if ([originalInsertString isEqualToString:@"("]) {
        return @")";
    } else if ([originalInsertString isEqualToString:@"\""]) {
        return @"\"";
    } else if ([originalInsertString isEqualToString:@"'"]) {
        return @"'";
    } else if ([originalInsertString isEqualToString:@"<"]) {
        return @">";
    }
    
    return nil;
}

- (void)centerSelectionInVisibleArea:(id)sender
{
    NSUInteger rectCount = 0;
    NSRectArray rectsToCenter = [self.layoutManager rectArrayForCharacterRange:self.selectedRange
                                                  withinSelectedCharacterRange:self.selectedRange
                                                               inTextContainer:(NSTextContainer *)self.textContainer
                                                                     rectCount:&rectCount];
    
    if (rectCount == 0) {
        return;
    }
    
    CGRect firstRect = rectsToCenter[0];
    [self.enclosingScrollView scrollRectToVisible:firstRect];
}

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
