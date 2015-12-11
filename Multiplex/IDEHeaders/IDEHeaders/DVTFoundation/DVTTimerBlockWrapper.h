//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "CDStructures.h"

#import "DVTCancellable-Protocol.h"

@class NSString, NSTimer;

@interface DVTTimerBlockWrapper : NSObject <DVTCancellable>
{
    NSTimer *_timer;
    dispatch_block_t _handler;
}

- (void)fire:(id)arg1;
- (void)cancel;
@property(readonly, getter=isCancelled) BOOL cancelled;
- (id)initWithTimeInterval:(double)arg1 repeats:(BOOL)arg2 handler:(dispatch_block_t)arg3;

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) unsigned long long hash;
@property(readonly) Class superclass;

@end
