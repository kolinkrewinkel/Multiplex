//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "CDStructures.h"
#import <IDEKit/IDEViewController.h>

@class NSArray, NSPopUpButton;

@interface IDEDistributionAppRecordSelectionViewController : IDEViewController
{
    NSArray *_applicationRecords;
    id  _selectedApplicationRecord;
    NSPopUpButton *_appRecordPopUpButton;
}

@property(retain) NSPopUpButton *appRecordPopUpButton; // @synthesize appRecordPopUpButton=_appRecordPopUpButton;
@property(retain, nonatomic) id  selectedApplicationRecord; // @synthesize selectedApplicationRecord=_selectedApplicationRecord;
- (void)selectAppRecord:(id)arg1;
@property(retain) NSArray *applicationRecords; // @synthesize applicationRecords=_applicationRecords;
- (id)nibName;

@end

