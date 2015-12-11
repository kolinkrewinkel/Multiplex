//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "CDStructures.h"
#import <IDEFoundation/IDELocalizationStream.h>

@interface _IDELocalizationStreamMap : IDELocalizationStream
{
    BOOL _shouldComplete;
    id  _publisher;
    dispatch_block_t _work;
    unsigned long long _outstandingWork;
}

+ (id)withPublisher:(id)arg1 withWork:(dispatch_block_t)arg2;
@property BOOL shouldComplete; // @synthesize shouldComplete=_shouldComplete;
@property unsigned long long outstandingWork; // @synthesize outstandingWork=_outstandingWork;
@property(copy) dispatch_block_t work; // @synthesize work=_work;
@property(retain) id  publisher; // @synthesize publisher=_publisher;
- (void)onCompleted;
- (void)onError:(id)arg1;
- (void)onNext:(id)arg1;
- (id)subscribe:(id)arg1;

@end
