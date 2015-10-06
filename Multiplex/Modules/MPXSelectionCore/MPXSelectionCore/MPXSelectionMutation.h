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

@property (nonatomic) MPXSelection *initialSelection;
@property (nonatomic) MPXSelection *finalSelection;

- (MPXSelection *)adjustTrailingSelection:(MPXSelection *)selection;

@end
