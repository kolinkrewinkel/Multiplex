//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "CDStructures.h"

@interface NSData (DVTFoundationClassAdditions)
+ (id)dvt_dataWithStrictBase64EncodedString:(id)arg1 error:(id *)arg2;
+ (id)dvt_dataWithBase64EncodedString:(id)arg1 error:(id *)arg2;
+ (id)dvt_dataWithFirstBytes:(unsigned long long)arg1 ofFile:(id)arg2 error:(id *)arg3;
- (id)dvt_base64EncodedString;
- (id)dvt_hexString;
- (id)dvt_dataWithSHA1Digest;
- (id)dvt_dataWithMD5Digest;
@end

