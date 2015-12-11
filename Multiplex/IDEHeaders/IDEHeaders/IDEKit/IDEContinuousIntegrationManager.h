//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "CDStructures.h"

@interface IDEContinuousIntegrationManager : NSObject
{
}

+ (id)botObservableStatusChangedPropertyName;
+ (id)integrationObservableStatusChangedPropertyName;
+ (id)documentLocationForLoadMoreItemWithNavigable:(id)arg1;
+ (void)additionalIntegrationsOnServerForBotNavigable:(id)arg1 completionBlock:(dispatch_block_t)arg2;
+ (void)loadMoreBotsInBotNavigable:(id)arg1 completionBlock:(dispatch_block_t)arg2;
+ (id)clickableStringForLegacyBotURL:(id)arg1;
+ (id)webURLForIntegration:(id)arg1;
+ (id)webURLForBot:(id)arg1;
+ (BOOL)canUserCreateAndDeleteBotsOnServiceForBotOrIntegration:(id)arg1;
+ (BOOL)canUserCreateBotsOnAnyService;
+ (void)addServerOnHostWindow:(id)arg1 connectionAddress:(id)arg2 completionBlock:(dispatch_block_t)arg3;
+ (void)addServerOnHostWindow:(id)arg1 completionBlock:(dispatch_block_t)arg2;
+ (void)showBotEditorForWorkspaceTabController:(id)arg1 bot:(id)arg2 errorPresenter:(id)arg3 errorWindow:(id)arg4 editingMode:(long long)arg5 completionBlock:(dispatch_block_t)arg6;
+ (void)showBotEditorForWorkspaceTabController:(id)arg1 bot:(id)arg2 errorPresenter:(id)arg3 errorWindow:(id)arg4 completionBlock:(dispatch_block_t)arg5;
+ (id)createEditBotAlertWithError:(id)arg1 validationErrors:(id)arg2;
+ (void)redefineBot:(id)arg1 workspaceTabController:(id)arg2 completionBlock:(dispatch_block_t)arg3;
+ (void)showNewBotEditorForWorkspaceTabController:(id)arg1 completionBlock:(dispatch_block_t)arg2;
+ (BOOL)verifySCMEnabled:(id *)arg1;
+ (void)deleteIntegration:(id)arg1 withCompletionBlock:(dispatch_block_t)arg2;
+ (void)cancelIntegration:(id)arg1 withCompletionBlock:(dispatch_block_t)arg2;
+ (void)deleteBot:(id)arg1 workspace:(id)arg2 withCompletionBlock:(dispatch_block_t)arg3;
+ (id)actionManager;
+ (id)serviceManager;
+ (void)compoundStatusForIntegrationOrBot:(id)arg1 completionBlock:(dispatch_block_t)arg2;
+ (int)statusOfIntegration:(id)arg1;
+ (BOOL)isIntegrationFinished:(id)arg1;
+ (id)logNavigatorHelper;
+ (void)performAction:(SEL)arg1 forNavigableItemSelection:(id)arg2 withNavigator:(id)arg3;
+ (id)titleForNavigableItemSelection:(id)arg1 action:(SEL)arg2;
+ (BOOL)navigableItemSelection:(id)arg1 allowsAction:(SEL)arg2;
+ (id)navigableItemForIntegration:(id)arg1;
+ (id)navigableItemForBotForGroupByTime:(id)arg1;
+ (id)navigableItemForBot:(id)arg1;
+ (id)navigableItemForService:(id)arg1;
+ (id)legacyBotNavigablesForLegacyBots:(id)arg1;
+ (id)projectNameInBlueprintForBot:(id)arg1;
+ (id)botIdentifierForIntegrationNavigableItem:(id)arg1;
+ (Class)serviceNavigableItemClass;
+ (Class)integrationNavigableItemClass;
+ (Class)botNavigableItemClass;
+ (Class)legacyNavigableItemClass;
+ (Class)navigableItemClass;
+ (Class)botIntegrationClass;
+ (Class)serviceClass;

@end
