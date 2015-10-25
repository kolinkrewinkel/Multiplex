//
//  MPXTextViewSelectionDecorator.h
//  Multiplex
//
//  Created by Kolin Krewinkel on 8/23/15.
//  Copyright © 2015 Kolin Krewinkel. All rights reserved.
//

#import "MPXSelectionManager.h"

@class DVTSourceTextView;
@interface MPXTextViewSelectionDecorator : NSObject <MPXSelectionManagerVisualizationDelegate>

#pragma mark - Initialization

- (instancetype)initWithTextView:(DVTSourceTextView *)textView;

#pragma mark - Caret Blink

- (void)startBlinking;
- (void)stopBlinking;
- (void)setCursorsVisible:(BOOL)visible;

@end
