//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "CDStructures.h"

@class NSString, NSWindow;

@interface IDESourceControlMultiNewBranchWindowController : NSWindowController
{
    IDESourceControlMultiNewBranchWindowController *_wc;
    NSString *_name;
    dispatch_block_t _completionBlock;
    NSWindow *_parentWindow;
}

+ (id)keyPathsForValuesAffectingCanCreate;
@property(retain) NSWindow *parentWindow; // @synthesize parentWindow=_parentWindow;
@property(copy) dispatch_block_t completionBlock; // @synthesize completionBlock=_completionBlock;
@property(copy) NSString *name; // @synthesize name=_name;
- (void)createBranchSheetDidEnd:(id)arg1 returnCode:(long long)arg2 contextInfo:(void *)arg3;
- (void)cancel:(id)arg1;
- (void)create:(id)arg1;
@property(readonly) BOOL canCreate;
- (void)beginSheetForWindow:(id)arg1;
- (id)windowNibName;

@end

