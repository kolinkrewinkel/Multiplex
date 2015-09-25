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

static NSString *kMPXQuickAddNextMenuItemTitle = @"Quick Add Next";
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
    
    [self mpx_addQuickAddNextMenuItem];
}

- (void)mpx_addQuickAddNextMenuItem
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

    NSRange searchWithinRange = NSMakeRange(locationToSearchFrom, self.string.length - locationToSearchFrom);
    
    NSString *stringToSearchFor = [self mpx_stringForQuickAddNext];    
    NSRange nextRange = [self.string rangeOfString:stringToSearchFor options:0 range:searchWithinRange]; 
    
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
        NSString *selectionString = [self.string substringWithRange:selection.range];
        
        // Find the word it's in if the selection is just a caret.
        if (selectionString.length == 0) {
            NSRange wordRange = [self.textStorage currentWordAtIndex:selection.range.location];

            if (wordRange.length == 0) {
                selectionString = nil;
            } else {
                selectionString = [self.string substringWithRange:wordRange];
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

    // Sequential (negative) offset of characters added.
    __block NSUInteger totalDelta = 0;
    [self mpx_mapAndFinalizeSelectedRanges:^MPXSelection *(MPXSelection *selection) {
        NSRange range = selection.range;
        NSString *modifiedInsertString = insertString;
        
        // Gets subtracted from NSMaxRange() of modifiedInsertString.
        NSUInteger offsetForCursor = 0;
        
        BOOL shouldInsertChars = YES;
        BOOL indentNextLine = NO;
        
        DVTSourceLanguageService *maybeLanguageService = self.textStorage.languageService;
        if ([maybeLanguageService isKindOfClass:[DVTDefaultSourceLanguageService class]]) {
            DVTDefaultSourceLanguageService *languageService = (DVTDefaultSourceLanguageService *)maybeLanguageService;
            if (selection.insertionIndex > 0
                && [languageService isIncompletionPlaceholderAtLocation:selection.insertionIndex - 1]) {
                NSRange placeholderRange = [self rangeOfPlaceholderFromCharacterIndex:selection.range.location - 1
                                                                              forward:YES
                                                                                 wrap:NO
                                                                                limit:NSMaxRange(selection.range)];

                // This is an awful hack to make -replaceSelectedTokenWithTokenText expand the right token.
                self.selectedRange = placeholderRange;
                [self replaceSelectedTokenWithTokenText];

                // -replaceSelectedTokenWithTokenText will then assign the result of expanding the token to
                // -selectedRange, so we read from that.
                NSRange newSelectionRange = self.selectedRange;
                
                if ([modifiedInsertString isEqualToString:kMPXNewlineString]) {
                    return [[MPXSelection alloc] initWithSelectionRange:newSelectionRange
                                                  indexWantedWithinLine:MPXNoStoredLineIndex
                                                                 origin:newSelectionRange.location];
                }
                
                range = newSelectionRange;
            }
        }
        
        NSString *nextChar = nil;
        if ([self.textStorage.string length] - 1 > selection.insertionIndex + 1) {
            nextChar = [self.textStorage.string substringWithRange:NSMakeRange(selection.insertionIndex, 1)];
        }

        if (nextChar) {
            for (NSString *typeoverString in @[@"]", @"}", @")", @"\"", @"'", @";"]) {
                if (![insertString isEqualToString:typeoverString]) {
                    continue;
                }

                if ([nextChar isEqualToString:typeoverString]) {
                    shouldInsertChars = NO;
                    break;
                }
            }
            
            if (selection.insertionIndex - 1 > 0) {
                NSString *currChar = [self.textStorage.string substringWithRange:NSMakeRange(selection.insertionIndex - 1, 1)];
                if ([nextChar isEqualToString:@"}"] && [currChar isEqualToString:@"{"] && [insertString isEqualToString:kMPXNewlineString]) {
                    modifiedInsertString = @"\n\n";
                    offsetForCursor = 1;
                    indentNextLine = YES;
                }
            }
        }

        if (!shouldInsertChars) {
            NSUInteger newIndex = selection.insertionIndex + 1;
            return [[MPXSelection alloc] initWithSelectionRange:NSMakeRange(newIndex, 0)
                                          indexWantedWithinLine:MPXNoStoredLineIndex
                                                         origin:newIndex];
        }

        // Offset by the previous mutations made (+/- doesn't matter, as long as the different maths at each point
        // correspond to the relative offset made by inserting a # of chars.)
        NSRange offsetRange = NSMakeRange(range.location + totalDelta, range.length);

        [self.textStorage replaceCharactersInRange:offsetRange withString:modifiedInsertString withUndoManager:self.undoManager];
        
        NSUInteger delta = [modifiedInsertString length] - range.length;

        __block NSRange rangeOfInsertedText = NSMakeRange(offsetRange.location, [modifiedInsertString length]);
        if ([modifiedInsertString rangeOfString:kMPXNewlineString].length > 0) {                        
            __block NSUInteger index = rangeOfInsertedText.location;    
            [modifiedInsertString enumerateLinesUsingBlock:^(NSString * _Nonnull line, BOOL * _Nonnull stop) {
                NSRange lineRange = NSMakeRange(index + [kMPXNewlineString length], [line length] + [kMPXNewlineString length]);
                NSRange indentedRange = [self _indentInsertedTextIfNecessaryAtRange:lineRange];
                                
                if (NSMaxRange(rangeOfInsertedText) >= lineRange.location) {
                    rangeOfInsertedText.location += indentedRange.location - lineRange.location;
                }
                
                index = NSMaxRange(indentedRange);
            }];           
        }

        // Offset the following ones by noting the original length and updating for the replacement's length, moving
        // cursors following forward/backward.
        totalDelta += delta;

        NSString *matchingBrace = [self followupStringToMakePair:modifiedInsertString];       
        if (matchingBrace && [[[NSCharacterSet alphanumericCharacterSet] invertedSet] characterIsMember:[nextChar characterAtIndex:0]]) {
            NSRange matchingBraceRange = NSMakeRange(NSMaxRange(offsetRange) + delta, 0);
            [self.textStorage replaceCharactersInRange:matchingBraceRange
                                            withString:matchingBrace
                                       withUndoManager:self.undoManager];

            totalDelta += [matchingBrace length];
        }

        NSRange lineRange;
        (void)[self.layoutManager lineFragmentRectForGlyphAtIndex:NSMaxRange(offsetRange) effectiveRange:&lineRange];

        NSUInteger relativeLinePosition = selection.indexWantedWithinLine;

        if (relativeLinePosition == NSNotFound) {
            relativeLinePosition = NSMaxRange(offsetRange) - lineRange.location;
        }

        // Move cursor (or range-selection) to the end of what was just added with 0-length.
        NSRange newInsertionPointRange = NSMakeRange(NSMaxRange(rangeOfInsertedText) - offsetForCursor, 0);

        return [[MPXSelection alloc] initWithSelectionRange:newInsertionPointRange
                                      indexWantedWithinLine:relativeLinePosition
                                                     origin:newInsertionPointRange.location];
    } sequentialModification:YES modifyingExistingSelections:NO movementDirection:NSSelectionAffinityDownstream];


    [self.mpx_textViewSelectionDecorator startBlinking];

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

- (BOOL)handleInsertTab
{
    if ([self.mpx_selectionManager.finalizedSelections count] == 1) {
        MPXSelection *selection = [self.mpx_selectionManager.finalizedSelections firstObject];
        
        // Use the actual line to allow skipping to a placeholder that's only soft word-wrapped.
        NSRange lineRange = [self.string lineRangeForRange:selection.range];
    
        // Get the next placeholder within the line.
        NSRange placeholderOnSameLine = [self rangeOfPlaceholderFromCharacterIndex:selection.range.location
                                                                           forward:YES
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
    
    BOOL shouldTrimTrailingWhitespace = [self mpx_shouldTrimTrailingWhitespace];
    self.mpx_trimTrailingWhitespace = NO;

    NSString *tabString = [self mpx_tabString];
    [self insertText:tabString];

    self.mpx_trimTrailingWhitespace = shouldTrimTrailingWhitespace;

    return YES;
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

    [self.mpx_textViewSelectionDecorator startBlinking];
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

@end
