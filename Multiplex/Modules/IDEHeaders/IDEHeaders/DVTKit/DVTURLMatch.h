//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "CDStructures.h"

@class NSString;

@interface DVTURLMatch : NSObject
{
    struct _NSRange _range;
    NSString *_url;
}

@property(copy) NSString *url; // @synthesize url=_url;
@property struct _NSRange range; // @synthesize range=_range;
- (id)description;
- (id)init;
- (id)initWithRange:(struct _NSRange)arg1 url:(id)arg2;

@end
