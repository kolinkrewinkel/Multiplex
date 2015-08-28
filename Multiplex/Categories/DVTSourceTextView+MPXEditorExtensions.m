//
//  IDESourceCodeEditor+CATViewReplacement.m
//  Multiplex
//
//  Created by Kolin Krewinkel on 9/25/14.
//  Copyright (c) 2014 Kolin Krewinkel. All rights reserved.
//

@import MPXFoundation;
@import MPXSelectionCore;

#import <DVTKit/DVTTextStorage.h>
#import <DVTKit/DVTLayoutManager.h>

#import "DVTSourceTextView+MPXEditorExtensions.h"
#import "DVTSourceTextView+MPXEditorSelectionVisualization.h"

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

        [self.undoManager beginUndoGrouping];

        NSArray *currState = self.mpx_selectionManager.finalizedSelections;
        [self.undoManager registerUndoWithTarget:self handler:^(id  _Nonnull target) {
            self.mpx_selectionManager.finalizedSelections = currState;
            [self.mpx_textViewSelectionDecorator startBlinking];
        }];
    }

    // Sequential (negative) offset of characters added.
    __block NSInteger totalDelta = 0;
    [self mpx_mapAndFinalizeSelectedRanges:^MPXSelection *(MPXSelection *selection) {
        NSRange range = selection.range;
        NSUInteger insertStringLength = [insertString length];

        // Offset by the previous mutations made (+/- doesn't matter, as long as the different maths at each point
        // correspond to the relative offset made by inserting a # of chars.)
        NSRange offsetRange = NSMakeRange(range.location + totalDelta, range.length);

        [self.textStorage replaceCharactersInRange:offsetRange withString:insertString withUndoManager:self.undoManager];

        // Offset the following ones by noting the original length and updating for the replacement's length, moving
        // cursors following forward/backward.
        NSInteger delta = range.length - insertStringLength;
        totalDelta -= delta;

        NSRange lineRange;
        (void)[self.layoutManager lineFragmentRectForGlyphAtIndex:NSMaxRange(offsetRange) effectiveRange:&lineRange];

        NSUInteger relativeLinePosition = selection.interLineDesiredIndex;

        if (relativeLinePosition == NSNotFound) {
            relativeLinePosition = NSMaxRange(offsetRange) - lineRange.location;
        }

        // Move cursor (or range-selection) to the end of what was just added with 0-length.
        NSRange newInsertionPointRange = NSMakeRange(offsetRange.location + insertStringLength, 0);
        return [[MPXSelection alloc] initWithSelectionRange:newInsertionPointRange
                                      interLineDesiredIndex:relativeLinePosition
                                                     origin:newInsertionPointRange.location];
    } sequentialModification:YES];

    [self.mpx_textViewSelectionDecorator startBlinking];
}

- (void)deleteBackward:(id)sender
{
    // Sequential (negative) offset of characters added.
    __block NSInteger totalDelta = 0;

    [self mpx_mapAndFinalizeSelectedRanges:^MPXSelection *(MPXSelection *selection) {
        // Update the base range with the delta'd amount of change from previous mutations.
        NSRange range = [selection range];
        NSRange offsetRange = NSMakeRange(range.location + totalDelta, range.length);

        NSRange deletingRange = NSMakeRange(0, 0);
        if (offsetRange.length == 0) {
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
        totalDelta -= deletingRange.length;

        return newSelection;
    }];
}

#pragma mark - Indentations/Other insertions

- (void)insertNewline:(id)sender
{
    NSUndoManager *undoManager = self.undoManager;
    DVTTextStorage *textStorage = (DVTTextStorage *)self.textStorage;

    [self insertText:@"\n"];

    [self mpx_mapAndFinalizeSelectedRanges:^MPXSelection *(MPXSelection *selection) {
        NSRange range = selection.range;

        [textStorage indentAtBeginningOfLineForCharacterRange:range undoManager:undoManager];

        NSLayoutManager *layoutManager = [self layoutManager];
        NSRange lineRange;
        NSUInteger desiredIndex = [layoutManager glyphIndexForCharacterAtIndex:NSMaxRange(range)];
        NSUInteger lineNumber = 0;
        NSUInteger numberOfLines = 0;

        for (NSUInteger index = 0; index < [layoutManager numberOfGlyphs]; numberOfLines++) {
            (void)[layoutManager lineFragmentRectForGlyphAtIndex:index effectiveRange:&lineRange];

            if (desiredIndex >= lineRange.location && desiredIndex <= NSMaxRange(lineRange)) {
                lineNumber = numberOfLines;
                break;
            }

            index = NSMaxRange(lineRange);
        }

        NSUInteger firstNonBlank = [textStorage firstNonblankForLine:lineNumber + 1 convertTabs:YES];

        NSRange effectiveRange;
        (void)[self.layoutManager lineFragmentRectForGlyphAtIndex:desiredIndex
                                                   effectiveRange:&effectiveRange];
        return [MPXSelection selectionWithRange:NSMakeRange(effectiveRange.location + firstNonBlank, 0)];
    }];
}

#pragma mark - Range Manipulation

- (BOOL)mpx_validateMenuItem:(NSMenuItem *)item
{
    SEL theAction = item.action;
    if (theAction == @selector(copy:) || theAction == @selector(cut:)) {
        return [[[[self.mpx_selectionManager.visualSelections rac_sequence] filter:^BOOL(MPXSelection *selection) {
            return selection.range.length > 0;
        }] array] count] > 0;
    }

    return [self mpx_validateMenuItem:item];
}

- (void)selectAll:(id)sender
{
    self.mpx_selectionManager.finalizedSelections = @[[MPXSelection selectionWithRange:NSMakeRange(0, [self.textStorage.string length])]];
}

- (void)mpx_mapAndFinalizeSelectedRanges:(MPXSelection * (^)(MPXSelection *selection))mapBlock
{
    [self mpx_mapAndFinalizeSelectedRanges:mapBlock sequentialModification:NO];
}

- (void)mpx_mapAndFinalizeSelectedRanges:(MPXSelection * (^)(MPXSelection *selection))mapBlock
                  sequentialModification:(BOOL)sequentialModification
{
    NSArray *mappedValues = [[[self.mpx_selectionManager.visualSelections rac_sequence] map:mapBlock] array];
    self.mpx_selectionManager.finalizedSelections = mappedValues;

    [self.mpx_textViewSelectionDecorator startBlinking];
}

@end
