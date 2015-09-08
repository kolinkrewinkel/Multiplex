//
//  MPXSelection.h
//  Multiplex
//
//  Created by Kolin Krewinkel on 12/27/14.
//  Copyright (c) 2014 Kolin Krewinkel. All rights reserved.
//

@import Foundation;

/**
 * Describes a selection within the document, which may have a length of 0, and always displays a caret.
 */
@interface MPXSelection : NSObject

#pragma mark - Designated Initializer

- (instancetype)initWithSelectionRange:(NSRange)range
                 indexWantedWithinLine:(NSUInteger)indexWantedWithinLine
                                origin:(NSUInteger)origin;

#pragma mark - New Range-Convenience Initializer

- (instancetype)initWithSelectionRange:(NSRange)range;
+ (instancetype)selectionWithRange:(NSRange)range;

#pragma mark - Attributes

@property (nonatomic, readonly) NSRange range;

/**
 * The location from where the range began in its current context.
 * It's the client's responsibility to pass this on when it's appropriate (e.g. during arrow key-selection modification)
 */
@property (nonatomic, readonly) NSUInteger origin;

/**
 * The relative position within a line that should be moved to if the line is long enough to accomodate. This should
 * transfer always, and the fallback behavior should be to put it at the end of the line if indexWanted > length/line).
 */
@property (nonatomic, readonly) NSUInteger indexWantedWithinLine;

/**
 * Position at which caret should be drawn (in absolute terms), as well as where mutations should take place from for
 * expansions and contractions of the selection.
 */
@property (nonatomic, readonly) NSUInteger caretIndex;

/**
 * The direction the selection is moving, based on comparing the current range to `origin.`
 */
@property (nonatomic, readonly) NSSelectionAffinity selectionAffinity;

@end
