//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "CDStructures.h"

@class CALayer<DVTClickableLayer>;

@interface DVTLayerHostingView : NSView
{
    CALayer *_currentClickedLayer;
}

- (BOOL)clickableLayerExistsForEvent:(id)arg1;
- (void)mouseUp:(id)arg1;
- (void)mouseDown:(id)arg1;
- (id)clickableLayerForEvent:(id)arg1;
- (id)clickableLayerAtPoint:(struct CGPoint)arg1;
- (unsigned int)_CAViewFlags;
- (BOOL)requireOptimumPerformance;

@end
