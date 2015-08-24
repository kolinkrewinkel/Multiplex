//
//  MPXSelectionManager.h
//  Multiplex
//
//  Created by Kolin Krewinkel on 8/23/15.
//  Copyright © 2015 Kolin Krewinkel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPXSelectionManager : NSObject

#pragma mark - Initialization

- (instancetype)initWithTextStorage:(DVTTextStorage *)textStorage;

/**
 * @return Selections which should be rendered onscreen.
 */
@property (nonatomic, readonly) NSArray *visualSelections;

/**
 * @return Selections which are finalized and not subject to mutation.
 */
@property (nonatomic) NSArray *finalizedSelections;

/**
 * Allows clients to temporarily alter the display attributes before a change to the selections is finalized.
 */
- (void)setTemporarySelections:(NSArray *)temporarySelections;


@end
