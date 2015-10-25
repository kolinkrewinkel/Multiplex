//
//  DVTSourceTextView+MPXEditorExtensions.m
//  Multiplex
//
//  Created by Kolin Krewinkel on 9/25/14.
//  Copyright (c) 2015 Kolin Krewinkel. All rights reserved.
//

@import ReactiveCocoa;

#import <DVTFoundation/DVTTextPreferences.h>

#import <DVTKit/DVTDefaultSourceLanguageService.h>
#import <DVTKit/DVTLayoutManager.h>
#import <DVTKit/DVTSourceLanguageService.h>
#import <DVTKit/DVTTextCompletionController.h>
#import <DVTKit/DVTTextFold.h>
#import <DVTKit/DVTTextStorage.h>
#import <DVTKit/DVTTextCompletionSession.h>
#import <DVTKit/DVTFoldingManager.h>
#import <DVTKit/DVTTextCompletionInlinePreviewController.h>

#import <libextobjc/EXTSynthesize.h>

#import "MPXSelection.h"
#import "MPXSelectionManager.h"
#import "MPXSelectionMutation.h"
#import "MPXTextViewSelectionDecorator.h"
#import "DVTSourceTextView+MPXEditorExtensions.h"
#import "DVTSourceTextView+MPXSelectionVisualization.h"
#import "DVTSourceTextView+MPXQuickAddNext.h"

static NSString *kMPXNewlineString = @"\n";

@implementation DVTSourceTextView (MPXEditorExtensions)
@synthesizeAssociation(DVTSourceTextView, mpx_selectionManager);
@synthesizeAssociation(DVTSourceTextView, mpx_inUndoGroup);
@synthesizeAssociation(DVTSourceTextView, mpx_shouldCloseGroupOnNextChange);

#pragma mark - Initializer

- (void)mpx_commonInitDVTSourceTextView
{
    [self mpx_commonInitDVTSourceTextView];
    
    self.mpx_textViewSelectionDecorator = [[MPXTextViewSelectionDecorator alloc] initWithTextView:self];
    
    self.mpx_selectionManager = [[MPXSelectionManager alloc] initWithTextView:self];
    self.mpx_selectionManager.visualizationDelegate = self.mpx_textViewSelectionDecorator;
    
    self.selectedTextAttributes = @{};
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
    MPXSelectionMutationBlock transformBlock = ^MPXSelectionMutation *(MPXSelection *selectionToModify) {
        // Update the base range with the delta'd amount of change from previous mutations.
        NSRange range = selectionToModify.range;

        NSRange deletingRange = NSMakeRange(0, 0);
        if (range.location > 0 && range.length == 0) {
            deletingRange = NSMakeRange(range.location - 1, 1);

            NSRange rangeOfLine = [self.textStorage.string lineRangeForRange:range];
            NSRange lineSubrangePendingDeletion = NSMakeRange(rangeOfLine.location, range.location - rangeOfLine.location);

            if (lineSubrangePendingDeletion.length > 0) {
                NSString *remainderOfLine = [self.textStorage.string substringWithRange:lineSubrangePendingDeletion];

                if (![[DVTTextPreferences preferences] useTabsToIndent]) {
                    BOOL shouldDeleteAsTab = YES;
                    NSUInteger charIndex = 0;
                    while (charIndex < [remainderOfLine length] - 1) {
                        unichar character = [remainderOfLine characterAtIndex:charIndex];

                        if ([[[NSCharacterSet whitespaceCharacterSet] invertedSet] characterIsMember:character]) {
                            shouldDeleteAsTab = NO;
                            break;
                        }

                        charIndex++;
                    }

                    if (shouldDeleteAsTab) {
                        NSRange tabStringToDelete = [self.textStorage.string rangeOfString:[self mpx_tabString]
                                                                                   options:NSBackwardsSearch
                                                                                     range:lineSubrangePendingDeletion];

                        if (tabStringToDelete.length > 0) {
                            deletingRange = tabStringToDelete;
                        }
                    }
                }
            }
        } else {
            deletingRange = NSMakeRange(range.location, range.length);
        }

        MPXSelection *newSelection = [[MPXSelection alloc] initWithSelectionRange:deletingRange
                                                            indexWantedWithinLine:MPXNoStoredLineIndex
                                                                           origin:NSMaxRange(deletingRange)];

        NSRange leadingPlaceholder = [self rangeOfPlaceholderFromCharacterIndex:newSelection.insertionIndex
                                                                        forward:NO
                                                                           wrap:NO
                                                                          limit:0];

        deletingRange = MPXSelectionAdjustedAboutToken(newSelection, leadingPlaceholder, NSSelectionAffinityUpstream, YES);

        newSelection = [[MPXSelection alloc] initWithSelectionRange:deletingRange
                                              indexWantedWithinLine:MPXNoStoredLineIndex
                                                             origin:NSMaxRange(deletingRange)];

        DVTTextFold *fold = [self.layoutManager.foldingManager lastFoldTouchingCharacterIndex:newSelection.insertionIndex];
        deletingRange = MPXSelectionAdjustedAboutToken(newSelection, fold.range, NSSelectionAffinityUpstream, YES);

        // Delete the characters
        [self insertText:@"" replacementRange:deletingRange];

        // New range for the beam (to the beginning of the range we replaced)
        NSRange newInsertionPointRange = NSMakeRange(deletingRange.location, 0);
        newSelection = [[MPXSelection alloc] initWithSelectionRange:newInsertionPointRange
                                              indexWantedWithinLine:MPXNoStoredLineIndex
                                                             origin:newInsertionPointRange.location];

        return [[MPXSelectionMutation alloc] initWithInitialSelection:selectionToModify
                                                       finalSelection:newSelection
                                                          mutatedText:YES];
    };

    [self.mpx_selectionManager mapSelectionsWithMovementDirection:NSSelectionAffinityUpstream
                                              modifyingSelections:NO
                                                       usingBlock:transformBlock];
}

#pragma mark - Indentations/Other insertions

- (void)insertNewline:(id)sender
{
    [self insertText:kMPXNewlineString];
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
    MPXSelectionMutationBlock transformBlock = ^MPXSelectionMutation *(MPXSelection *selectionToModify) {
        return [[MPXSelectionMutation alloc] initWithInitialSelection:selectionToModify
                                                       finalSelection:mapBlock(selectionToModify)
                                                          mutatedText:NO];
    };

    [self.mpx_selectionManager mapSelectionsWithMovementDirection:movementDirection
                                              modifyingSelections:modifySelection
                                                       usingBlock:transformBlock];
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
