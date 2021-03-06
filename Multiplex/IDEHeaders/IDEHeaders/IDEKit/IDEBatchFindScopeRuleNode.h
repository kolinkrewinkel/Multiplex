//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "CDStructures.h"

@class IDEBatchFindScopeRuleRow, NSIndexPath;

@interface IDEBatchFindScopeRuleNode : NSObject
{
    IDEBatchFindScopeRuleRow *_row;
    NSIndexPath *_indexPath;
}

+ (id)nodeArrayForIndexPath:(id)arg1 inRow:(id)arg2;
+ (id)nodeForIndexPath:(id)arg1 inRow:(id)arg2;
@property(readonly) NSIndexPath *indexPath; // @synthesize indexPath=_indexPath;
@property(readonly) IDEBatchFindScopeRuleRow *row; // @synthesize row=_row;
- (id)childAtIndex:(long long)arg1;
@property(readonly) long long childCount;
- (BOOL)isEqual:(id)arg1;
- (unsigned long long)hash;
- (id)initWithPath:(id)arg1 inRow:(id)arg2;

@end

