//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "CDStructures.h"
#import "DVTViewController-Protocol.h"

@class DVTBorderedView, DVTSourceControlBranchAndTagLocations, DVTSourceControlRepository, DVTSourceControlWorkingCopy, IDESourceControlFilePickerWindowController, NSTextField;

@interface IDESourceControlSVNConfigViewController : DVTViewController
{
    NSTextField *_trunkField;
    NSTextField *_tagsField;
    NSTextField *_branchesField;
    DVTBorderedView *_containerBorderedView;
    DVTSourceControlWorkingCopy *_workingCopy;
    DVTSourceControlRepository *_repository;
    DVTSourceControlBranchAndTagLocations *_branchAndTagLocations;
    IDESourceControlFilePickerWindowController *_filePickerWindowController;
}

+ (id)defaultViewNibName;
+ (void)initialize;
- (void)primitiveInvalidate;
- (void)selectBranches:(id)arg1;
- (void)selectTags:(id)arg1;
- (void)selectTrunk:(id)arg1;
- (void)_setupView;
- (void)setBranches:(id)arg1;
- (void)setTags:(id)arg1;
- (void)setTrunk:(id)arg1;
- (void)_updateBranchingSupport;
- (id)currentBranchAndTagLocations;
- (void)awakeFromNib;
- (id)initWithNibName:(id)arg1 bundle:(id)arg2;
- (void)showBranchAndTagLocationsForRepository:(id)arg1 branchAndTagLocations:(id)arg2;
- (void)showBranchAndTagLocationsForWorkingCopy:(id)arg1;
- (void)loadView;

@end

