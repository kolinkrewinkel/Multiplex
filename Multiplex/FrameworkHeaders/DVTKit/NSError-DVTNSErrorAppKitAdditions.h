//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "CDStructures.h"

@interface NSError (DVTNSErrorAppKitAdditions)
+ (id)dvt_errorWithDomain:(id)arg1 errorCode:(long long)arg2 message:(id)arg3 recoverySuggestion:(id)arg4 recoveryOptions:(id)arg5 andErrorPanelProvider:(dispatch_block_t)arg6;
- (id)dvt_errorByAddingErrorPanelProvider:(dispatch_block_t)arg1;
@end
