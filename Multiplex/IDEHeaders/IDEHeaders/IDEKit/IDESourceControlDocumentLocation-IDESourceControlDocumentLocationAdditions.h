//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "CDStructures.h"
#import "IDESourceControlDocumentLocation-Protocol.h"

@interface IDESourceControlDocumentLocation (IDESourceControlDocumentLocationAdditions)
- (id)exportDocumentUsingTemplateDocument:(id)arg1 completionBlock:(dispatch_block_t)arg2 primaryBehavior:(BOOL)arg3;
- (id)exportDocumentUsingTemplateDocument:(id)arg1 fromWorkspace:(id)arg2 completionBlock:(dispatch_block_t)arg3 primaryBehavior:(BOOL)arg4;
- (id)_exportTmpVersionFromOriginalDocument:(id)arg1 completionBlock:(dispatch_block_t)arg2;
@end
