//
//  CATSelectionRange.h
//  Catalyst
//
//  Created by Kolin Krewinkel on 12/27/14.
//  Copyright (c) 2014 Kolin Krewinkel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CATSelectionRange : NSObject

#pragma mark -
#pragma mark Initialization

- (instancetype)initWithSelectionRange:(NSRange)range;
+ (instancetype)selectionWithRange:(NSRange)range;

#pragma mark -
#pragma mark Attributes

@property (nonatomic, readonly) NSRange range;
@property (nonatomic, readonly) NSUInteger intralineDesiredIndex;

@end
