//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "CDStructures.h"


@class NSString;

@interface DVTFindPattern : NSObject <NSCoding, NSCopying>
{
    NSString *regularExpression;
    NSString *tokenString;
    NSString *displayString;
    NSString *replacementString;
    NSString *uniqueID;
    BOOL allowsBackreferences;
    BOOL isNegation;
    int groupID;
    int captureGroupID;
    int repeatedPatternID;
}

+ (id)placeholderFindPattern;
+ (unsigned long long)readingOptionsForType:(id)arg1 pasteboard:(id)arg2;
+ (id)readableTypesForPasteboard:(id)arg1;
@property(copy) NSString *replacementString; // @synthesize replacementString;
@property int repeatedPatternID; // @synthesize repeatedPatternID;
@property(readonly) NSString *uniqueID; // @synthesize uniqueID;
@property int captureGroupID; // @synthesize captureGroupID;
@property BOOL isNegation; // @synthesize isNegation;
@property BOOL allowsBackreferences; // @synthesize allowsBackreferences;
@property int groupID; // @synthesize groupID;
@property(copy) NSString *tokenString; // @synthesize tokenString;
@property(copy) NSString *regularExpression; // @synthesize regularExpression;
@property(copy) NSString *displayString; // @synthesize displayString;
- (id)backreferenceExpression;
- (id)replaceExpression;
- (id)copyWithZone:(struct _NSZone *)arg1;
- (id)initWithPropertyListRepresentation:(id)arg1;
- (id)propertyListRepresentation;
- (id)writableTypesForPasteboard:(id)arg1;
- (id)initWithCoder:(id)arg1;
- (void)encodeWithCoder:(id)arg1;
- (void)generateNewUniqueID;
- (void)_setUniqueID:(id)arg1;
- (id)description;
- (BOOL)isEqual:(id)arg1;

@end
