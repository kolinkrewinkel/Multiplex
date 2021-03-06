//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "CDStructures.h"
#import <DVTFoundation/DTDKTeamBasedService.h>

@interface DTDKDownloadProvisioningProfileService : DTDKTeamBasedService
{
}

+ (id)keyPathsForValuesAffectingProfile;
+ (id)keyPathsForValuesAffectingEncodedProfile;
+ (id)keyPathsForValuesAffectingDevices;
+ (id)keyPathsForValuesAffectingExpirationDate;
+ (id)keyPathsForValuesAffectingCertificates;
+ (id)keyPathsForValuesAffectingProvisioningProfileID;
+ (id)keyPathsForValuesAffectingAppID;
+ (id)keyPathsForValuesAffectingProfileDictionary;
+ (id)serviceForTeam:(id)arg1 andPlatform:(id)arg2 andSubPlatform:(id)arg3 andAppIDIDs:(id)arg4;
+ (id)serviceForTeam:(id)arg1 andPlatform:(id)arg2 andProfileIDs:(id)arg3;
- (id)encodedProfile;
- (id)devices;
- (id)expirationDate;
- (id)certificates;
- (id)appID;
- (id)provisioningProfileID;
- (id)profileDictionary;

@end

