//
//  MPXGeometry.h
//  Multiplex
//
//  Created by Kolin Krewinkel on 8/23/15.
//  Copyright © 2015 Kolin Krewinkel. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_INLINE CGFloat MPXRoundedPixelValueForView(NSView *view, CGFloat value)
{
    CGFloat scale = view.window.screen.backingScaleFactor;
    return round(value * scale) / scale;
}

NS_INLINE CGRect MPXRoundedValueRectForView(CGRect rect, NSView *view)
{
    return CGRectMake(MPXRoundedPixelValueForView(view, rect.origin.x),
                      MPXRoundedPixelValueForView(view, rect.origin.y),
                      MPXRoundedPixelValueForView(view, rect.size.width),
                      MPXRoundedPixelValueForView(view, rect.size.height));
}
