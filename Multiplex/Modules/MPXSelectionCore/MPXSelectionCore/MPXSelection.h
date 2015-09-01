//
//  MPXSelection.h
//  Multiplex
//
//  Created by Kolin Krewinkel on 12/27/14.
//  Copyright (c) 2014 Kolin Krewinkel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPXSelection : NSObject

#pragma mark - Designated Initializer

- (instancetype)initWithSelectionRange:(NSRange)range
                 interLineDesiredIndex:(NSUInteger)interLineDesiredIndex
                                origin:(NSUInteger)origin;

#pragma mark - New Range-Convenience Initializer

- (instancetype)initWithSelectionRange:(NSRange)range;
+ (instancetype)selectionWithRange:(NSRange)range;

#pragma mark - Attributes

@property (nonatomic, readonly) NSRange range;
@property (nonatomic, readonly) NSUInteger interLineDesiredIndex;
@property (nonatomic, readonly) NSUInteger origin;

@property (nonatomic, readonly) NSSelectionAffinity selectionAffinity;

@property (nonatomic) NSView *caretView;

@end
