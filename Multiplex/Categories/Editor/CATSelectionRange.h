//
//  CATSelectionRange.h
//  Multiplex
//
//  Created by Kolin Krewinkel on 12/27/14.
//  Copyright (c) 2014 Kolin Krewinkel. All rights reserved.
//

@interface CATSelectionRange : NSObject

#pragma mark -
#pragma mark Designated Initializer

- (instancetype)initWithSelectionRange:(NSRange)range
                 intralineDesiredIndex:(NSUInteger)intralineDesiredIndex;

#pragma mark -
#pragma mark New Range-Convenience Initializer

- (instancetype)initWithSelectionRange:(NSRange)range;
+ (instancetype)selectionWithRange:(NSRange)range;

#pragma mark -
#pragma mark Attributes

@property (nonatomic, readonly) NSRange range;
@property (nonatomic, readonly) NSUInteger intralineDesiredIndex;

@end
