//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "CDStructures.h"
#import "DVTOperationGroup-Protocol.h"

@class IDEBuildOperation;

@interface IDEBuildOperationGroup : DVTOperationGroup
{
    IDEBuildOperation *_buildOperation;
}

+ (id)operationGroupWithSuboperations:(id)arg1;
+ (id)operationGroupWithBuildOperation:(id)arg1 otherOperations:(id)arg2;
@property(readonly) IDEBuildOperation *buildOperation; // @synthesize buildOperation=_buildOperation;

@end

