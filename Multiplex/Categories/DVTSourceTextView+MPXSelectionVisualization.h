//
//  DVTSourceTextView+MPXSelectionVisualization.h
//  Multiplex
//
//  Created by Kolin Krewinkel on 8/26/15.
//  Copyright © 2015 Kolin Krewinkel. All rights reserved.
//

#import <DVTKit/DVTSourceTextView.h>

@class MPXTextViewSelectionDecorator;
@interface DVTSourceTextView (MPXSelectionVisualization)

@property (nonatomic) MPXTextViewSelectionDecorator *mpx_textViewSelectionDecorator;

#pragma mark - Swizzled Methods

- (void)mpx_viewWillMoveToWindow:(NSWindow *)window;

@end
