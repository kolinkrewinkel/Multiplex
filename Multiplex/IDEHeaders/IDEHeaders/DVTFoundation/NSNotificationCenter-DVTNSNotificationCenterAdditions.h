//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "CDStructures.h"

@interface NSNotificationCenter (DVTNSNotificationCenterAdditions)
- (id)dvt_addObserverForName:(id)arg1 object:(id)arg2 queue:(id)arg3 usingBlock:(dispatch_block_t)arg4;
- (id)dvt_addObserver:(id)arg1 selector:(SEL)arg2 name:(id)arg3 object:(id)arg4;
- (void)_dvt_postNotificationName:(id)arg1 object:(id)arg2 userInfo:(id)arg3;
@end

