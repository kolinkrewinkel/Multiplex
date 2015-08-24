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
                 intralineDesiredIndex:(NSUInteger)intralineDesiredIndex
                                origin:(NSUInteger)origin;

#pragma mark - New Range-Convenience Initializer

- (instancetype)initWithSelectionRange:(NSRange)range;
+ (instancetype)selectionWithRange:(NSRange)range;

#pragma mark - Attributes

@property (nonatomic, readonly) NSRange range;
@property (nonatomic, readonly) NSUInteger intralineDesiredIndex;
@property (nonatomic, readonly) NSUInteger origin;

@end
