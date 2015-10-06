//
//  MPXSelectionMutation.h
//  MPXSelectionCore
//
//  Created by Kolin Krewinkel on 9/25/15.
//  Copyright © 2015 Kolin Krewinkel. All rights reserved.
//

@import Foundation;

@class MPXSelection;
@interface MPXSelectionMutation : NSObject

- (instancetype)initWithInitialSelection:(MPXSelection *)initialSelection
                          finalSelection:(MPXSelection *)finalSelection;

@property (nonatomic, readonly) MPXSelection *initialSelection;
@property (nonatomic, readonly) MPXSelection *finalSelection;

- (MPXSelection *)adjustTrailingSelection:(MPXSelection *)selection;

@end
