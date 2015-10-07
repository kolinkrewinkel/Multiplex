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
                          finalSelection:(MPXSelection *)finalSelection
                             mutatedText:(BOOL)mutatedText;

@property (nonatomic, readonly) MPXSelection *initialSelection;
@property (nonatomic, readonly) MPXSelection *finalSelection;

@property (nonatomic, readonly) BOOL mutatedText;

- (MPXSelection *)adjustTrailingSelection:(MPXSelection *)selection;

@end
