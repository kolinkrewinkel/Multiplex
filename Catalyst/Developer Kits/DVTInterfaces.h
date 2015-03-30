//
//  DVTInterfaces.h
//  Catalyst
//
//  Created by Kolin Krewinkel on 3/30/14.
//  Copyright 2014 Apple Inc. All rights reserved.
//
//  Sourced from class-dump. Some borrowed from CodePilot for quick compilation.
//

#import <Cocoa/Cocoa.h>

@interface DVTSourceCodeSymbolKind : NSObject
+ (id)containerSymbolKind;
+ (id)globalSymbolKind;
+ (id)callableSymbolKind;
+ (id)memberSymbolKind;
+ (id)memberContainerSymbolKind;
+ (id)categorySymbolKind;
+ (id)classMethodSymbolKind;
+ (id)classSymbolKind;
+ (id)enumSymbolKind;
+ (id)enumConstantSymbolKind;
+ (id)fieldSymbolKind;
+ (id)functionSymbolKind;
+ (id)instanceMethodSymbolKind;
+ (id)instanceVariableSymbolKind;
+ (id)classVariableSymbolKind;
+ (id)macroSymbolKind;
+ (id)parameterSymbolKind;
+ (id)propertySymbolKind;
+ (id)protocolSymbolKind;
+ (id)structSymbolKind;
+ (id)typedefSymbolKind;
+ (id)unionSymbolKind;
+ (id)localVariableSymbolKind;
+ (id)globalVariableSymbolKind;
+ (id)ibActionMethodSymbolKind;
+ (id)ibOutletSymbolKind;
+ (id)ibOutletVariableSymbolKind;
+ (id)ibOutletPropertySymbolKind;
+ (id)ibOutletCollectionSymbolKind;
+ (id)ibOutletCollectionVariableSymbolKind;
+ (id)ibOutletCollectionPropertySymbolKind;
+ (id)namespaceSymbolKind;
+ (id)classTemplateSymbolKind;
+ (id)functionTemplateSymbolKind;
+ (id)instanceMethodTemplateSymbolKind;
+ (id)classMethodTemplateSymbolKind;
+ (void)initialize;
+ (id)sourceCodeSymbolKinds;
- (id)icon;
- (id)description;
- (id)conformedToSymbolKinds;
- (id)allConformingSymbolKinds;
- (char)isContainer;
- (id)identifier;
- (id)localizedDescription;
@end

@interface IDEDocumentController : NSObject
+ (id)sharedDocumentController;
- (NSArray *)workspaceDocuments;
@end

@class DVTDocumentLocation, DVTFileDataType;
@interface DVTFilePath : NSObject
- (NSURL *)fileURL;
- (NSString *)pathString;
- (NSString *)fileName;
+ (DVTFilePath *)filePathForPathString:(NSString *)path;
- (DVTFilePath *)file;
- (NSImage *)navigableItem_image;

- (DVTDocumentLocation *)navigableItem_contentDocumentLocation;
- (DVTFileDataType *)navigableItem_documentType;
- (DVTFilePath *)parentFilePath;
- (DVTFilePath *)volumeFilePath;
@end

@interface IDEIndex : NSObject
{
}

+ (BOOL)languageSupportsSymbolColoring:(id)arg1;
+ (id)resolutionForName:(id)arg1 kind:(id)arg2 containerName:(id)arg3;
+ (id)pathToClang;
+ (id)_dataSourceExtensionForFile:(id)arg1 withLanguage:(id)arg2;
+ (void)syncPerformBlockOnMainThread:(dispatch_block_t)arg1;
+ (void)initialize;
+ (BOOL)includeAutoImportResults;
+ (BOOL)indexFollowsActiveScheme;
+ (id)schedulingLogAspect;
+ (id)clangInvocationLogAspect;
+ (id)symbolAdditionLogAspect;
+ (id)deferredMetricLogAspect;
+ (id)metricLogAspect;
+ (id)logAspect;
@property(readonly, nonatomic) DVTFilePath *databaseFile; // @synthesize databaseFile=_databaseFile;
//@property(readonly, nonatomic) IDEIndexDatabase *database; // @synthesize database=_workspaceDatabase;
- (id)targetIdentifiersForFile:(id)arg1;
- (id)mainFilesForFile:(id)arg1;
- (id)sdkForFile:(id)arg1;
- (id)timestampForFile:(id)arg1;
- (void)_buildOperationDidStop:(id)arg1;
- (void)_buildSettingsDidChange:(id)arg1;
- (void)_activeRunDestinationDidChange:(id)arg1;
- (void)_activeRunContextDidChange:(id)arg1;
- (void)_clearAllCachedBuildSettings;
- (void)_computePreferredTargets;
- (BOOL)isPreferredTarget:(id)arg1 priority:(char *)arg2;
- (BOOL)isPreferredTarget:(id)arg1;
- (id)databaseQueryProvider;
- (id)queryProviderForLocation:(id)arg1 highPriority:(BOOL)arg2;
- (void)dontDeferJobForFile:(id)arg1 indexable:(id)arg2;
- (void)registerHotFile:(id)arg1;
- (id)queryProviderForFile:(id)arg1 highPriority:(BOOL)arg2;
- (id)resolutionForName:(id)arg1 kind:(id)arg2 containerName:(id)arg3;
- (id)indexableForCopiedHeader:(id)arg1;
- (id)originalPathsForPaths:(id)arg1;
- (id)effectivePathForHeader:(id)arg1;
- (void)_initCopiedHeaders;
- (void)indexModuleIfNeeded:(id)arg1;
- (void)_cleanupOldPCHs;
- (void)didCancelIndexingPCHFile:(id)arg1;
- (BOOL)createPCHFile:(id)arg1 arguments:(id)arg2 hashCriteria:(id)arg3 target:(id)arg4 session:(id)arg5 willIndex:(BOOL)arg6 translationUnit:(id *)arg7;
- (void)database:(id)arg1 reportAutoQueryProgress:(double)arg2;
- (void)clearPCHFailuresForDatabase:(id)arg1;
- (void)databaseDidReportError:(id)arg1;
- (void)databaseDidLoad:(id)arg1;
- (void)databaseDidOpen:(id)arg1;
- (id)databaseProvidersAndVersions:(id)arg1;
- (void)database:(id)arg1 didForgetFiles:(id)arg2;
- (void)database:(id)arg1 didEndImportSession:(id)arg2;
- (void)databaseDidSave:(id)arg1;
- (void)databaseDidIndexHotFile:(id)arg1;
- (void)_respondToFileChangeNotification:(id)arg1;
@property(readonly, nonatomic) DVTFilePath *workspaceFile;
@property(readonly, nonatomic) NSString *workspaceName;
- (id)dataSourceExtensionForFile:(id)arg1 settings:(id)arg2;
- (id)_dataSourceExtensionForFile:(id)arg1 withSettings:(id)arg2;
- (id)settingsForFile:(id)arg1 indexable:(id)arg2;
- (id)_waitForSettingsForFile:(id)arg1 object:(id)arg2;
- (id)_waitForSettingsFromObject:(id)arg1;
- (id)workspaceHeadersForIndexable:(id)arg1;
- (void)gatherProductHeadersForIndexable:(id)arg1;
- (long long)purgeCount;
- (void)purgeFileCaches;
- (void)close;
- (void)editorWillSaveFile:(id)arg1;
- (void)expediteIndexing;
- (void)_stopIndexing;
- (void)setThrottleFactor:(double)arg1;
- (void)resumeIndexing;
- (void)suspendIndexing;
@property(readonly, nonatomic) BOOL shouldAllowRefactoring;
@property(readonly, nonatomic) BOOL isQuiescent;
- (void)doWhenFilesReady:(dispatch_block_t)arg1;
- (void)willRegisterMoreFiles:(BOOL)arg1;
- (void)unregisterFile:(id)arg1;
- (void)registerFile:(id)arg1;
- (id)indexableForIdentifier:(id)arg1;
- (void)unregisterObject:(id)arg1;
- (void)registerObject:(id)arg1;
- (void)postNotificationName:(id)arg1;
- (void)postNotificationName:(id)arg1 userInfo:(id)arg2;
- (id)description;
- (void)setIndexState:(id)arg1;
- (id)indexState;
@property(readonly) DVTFilePath *workspaceBuildProductsDirPath;
@property(readonly) DVTFilePath *headerMapFilePath;
- (void)observeValueForKeyPath:(id)arg1 ofObject:(id)arg2 change:(id)arg3 context:(void *)arg4;
- (BOOL)isCurrentForWorkspace:(id)arg1;
- (void)beginTextIndexing;
- (id)initWithWorkspace:(id)arg1;
- (id)initWithFolder:(id)arg1;
- (id)initWithFolder:(id)arg1 forWorkspace:(id)arg2;
- (void)_cleanupOldIndexFoldersForWorkspace:(id)arg1;
- (double)_atime:(struct stat *)arg1;
- (BOOL)_stat:(struct stat *)arg1 filePath:(id)arg2;
- (id)_databaseFileURLForFolder:(id)arg1;
- (id)_databaseFolderForWorkspace:(id)arg1;
- (BOOL)_reopenDatabaseWithRemoval:(BOOL)arg1;
- (BOOL)_createDatabaseFolder;
- (void)_setupObservers;
- (id)allAutoImportItemsMatchingKind:(id)arg1 symbolLanguage:(id)arg2;
- (id)allAutoImportItemsMatchingKind:(id)arg1;
- (id)filesWithSymbolOccurrencesMatchingName:(id)arg1 kind:(id)arg2;
- (id)classesWithReferencesToSymbols:(id)arg1;
- (id)allClassesWithMembers:(id)arg1;
- (id)classesWithMembers:(id)arg1;
- (id)allMethodsMatchingMethod:(id)arg1 forReceiver:(id)arg2;
- (id)membersMatchingName:(id)arg1 kinds:(id)arg2 forInterfaces:(id)arg3;
- (id)membersMatchingKinds:(id)arg1 forInterfaces:(id)arg2;
- (id)symbolsForResolutions:(id)arg1;
- (id)parsedCodeCommentAtLocation:(id)arg1 withCurrentFileContentDictionary:(id)arg2;
- (id)codeDiagnosticsAtLocation:(id)arg1 withCurrentFileContentDictionary:(id)arg2;
- (id)codeCompletionsAtLocation:(id)arg1 withCurrentFileContentDictionary:(id)arg2 completionContext:(id *)arg3;
- (id)allParentsOfSymbols:(id)arg1 cancelWhen:(dispatch_block_t)arg2;
- (id)topLevelSymbolsInFile:(id)arg1;
- (unsigned long long)countOfSymbolsMatchingKind:(id)arg1 workspaceOnly:(BOOL)arg2;
- (id)allSymbolsMatchingKind:(id)arg1 workspaceOnly:(BOOL)arg2 cancelWhen:(dispatch_block_t)arg3;
- (id)allSymbolsMatchingKind:(id)arg1 workspaceOnly:(BOOL)arg2;
- (id)allSymbolsMatchingKind:(id)arg1;
- (id)testMethodsForClasses:(id)arg1;
- (id)allSubClassesForClasses:(id)arg1;
- (id)allSymbolsMatchingNames:(id)arg1 kind:(id)arg2;
- (id)allSymbolsMatchingName:(id)arg1 kind:(id)arg2;
- (id)allProtocolsMatchingName:(id)arg1;
- (id)allClassesMatchingName:(id)arg1;
- (id)impliedHeadersForModuleImportLocation:(id)arg1 withCurrentFileContentDictionary:(id)arg2;
- (id)importedFileAtDocumentLocation:(id)arg1 withCurrentFileContentDictionary:(id)arg2;
- (id)importedFilesAtDocument:(id)arg1 withCurrentFileContentDictionary:(id)arg2;
- (id)collectionElementTypeSymbolForSymbol:(id)arg1 withCurrentFileContentDictionary:(id)arg2;
- (id)typeSymbolForSymbol:(id)arg1 withCurrentFileContentDictionary:(id)arg2;
- (id)messageReceiverInContext:(id)arg1 withCurrentFileContentDictionary:(id)arg2;
- (id)referencesToSymbolMatchingName:(id)arg1 inContext:(id)arg2 withCurrentFileContentDictionary:(id)arg3;
- (id)referencesToSymbol:(id)arg1 inContext:(id)arg2 withCurrentFileContentDictionary:(id)arg3;
- (id)symbolsUsedInContext:(id)arg1 withCurrentFileContentDictionary:(id)arg2;
- (id)symbolsOccurrencesInContext:(id)arg1 withCurrentFileContentDictionary:(id)arg2;
- (id)symbolsMatchingName:(id)arg1 inContext:(id)arg2 withCurrentFileContentDictionary:(id)arg3;
- (id)symbolsMatchingName:(id)arg1 inContext:(id)arg2;
- (id)symbolsContaining:(id)arg1 anchorStart:(BOOL)arg2 anchorEnd:(BOOL)arg3 subsequence:(BOOL)arg4 ignoreCase:(BOOL)arg5 cancelWhen:(dispatch_block_t)arg6;
- (id)symbolsContaining:(id)arg1 anchorStart:(BOOL)arg2 anchorEnd:(BOOL)arg3 subsequence:(BOOL)arg4 ignoreCase:(BOOL)arg5;
- (id)topLevelProtocolsWorkspaceOnly:(BOOL)arg1 cancelWhen:(dispatch_block_t)arg2;
- (id)topLevelProtocolsWorkspaceOnly:(BOOL)arg1;
- (id)topLevelProtocols;
- (id)topLevelClassesWorkspaceOnly:(BOOL)arg1 cancelWhen:(dispatch_block_t)arg2;
- (id)topLevelClassesWorkspaceOnly:(BOOL)arg1;
- (id)topLevelClasses;
- (id)filesContaining:(id)arg1 anchorStart:(BOOL)arg2 anchorEnd:(BOOL)arg3 subsequence:(BOOL)arg4 ignoreCase:(BOOL)arg5 cancelWhen:(dispatch_block_t)arg6;
- (id)filesIncludedByFile:(id)arg1;
- (id)filesIncludingFile:(id)arg1;
- (id)mainFileForSelectionFilePath:(id)arg1 buildSettings:(id *)arg2;
- (id)objCOrCCompilationUnitIndexablesForMainFile:(id)arg1 indexableObjects:(id)arg2;
- (BOOL)isFileObjCCompilationUnitOrHeader:(id)arg1 error:(id *)arg2;
- (id)_localizedPhraseForDependentObjCCompilationUnit:(id)arg1 errorLanguages:(id)arg2 sharedLanguageIdentifier:(id)arg3 sharedIndexableObject:(id)arg4;
- (id)_localizedDescriptionForObjCCompilationUnit:(id)arg1 errorLanguages:(id)arg2;
- (BOOL)_errorLanguages:(id *)arg1 forFilePath:(id)arg2 indexableObjects:(id)arg3;

@end

@class IDEIndexDatabase;
@interface IDEIndexDatabaseQueryProvider : NSObject
- (id)topLevelSymbolsInFile:(NSString *)filePath forIndex:(IDEIndex *)index;
- (id)filesContaining:(NSString *)a anchorStart:(NSString *)b anchorEnd:(NSString *)c subsequence:(NSString *)d ignoreCase:(BOOL)ignoreCase forIndex:(IDEIndex *)wwefwew;
- (IDEIndexDatabase *)database;
@end

@interface IDEIndexDBConnection : NSObject
- (void)close;
- (void)finalize;
- (id)dbConnection;
@end

@interface IDEIndexDatabase : NSObject
- (IDEIndexDatabase *)initWithFileURL:(NSURL *)fileURL;
- (IDEIndexDatabaseQueryProvider *)queryProvider;
- (void)open;
- (void)openReadonly;
- (void)openInDiagnosticMode;
- (void)close;
- (id)mainFilesForTarget:(NSString *)targetNameOrWTF;
- (IDEIndexDBConnection *)newConnection;
- (NSURL *)fileURL;
@end

@interface DVTModelObject : NSObject
@end

@interface IDEContainerItem : DVTModelObject
@end

@interface IDEGroup : IDEContainerItem
- (NSArray *)subitems;
- (NSImage *)navigableItem_image;
@end

@interface IDEContainer : DVTModelObject
- (DVTFilePath *)filePath;
- (IDEGroup *)rootGroup;
- (void)debugPrintInnerStructure;
- (void)debugPrintStructure;
@end

@interface IDEXMLPackageContainer : IDEContainer
@end

@interface IDEWorkspace : IDEXMLPackageContainer
- (IDEIndex *)index;
- (NSString *)name;
- (NSSet *)referencedContainers;
@end

@interface IDEWorkspaceDocument : NSObject
- (IDEWorkspace *)workspace;
- (NSArray *)recentEditorDocumentURLs;
- (id)sdefSupport_fileReferences;
@end

@interface IDEWorkspaceWindow : NSWindow
- (IDEWorkspaceDocument *)document;
@end

@interface IDEWorkspaceWindow (MissingMethods)
+ (IDEWorkspaceWindow *)mc_lastActiveWorkspaceWindow;
@end

@interface IDEFileReference : NSObject
- (IDEContainer *)referencedContainer;
@end

@interface PBXObject : NSObject
@end

@interface PBXContainer : PBXObject
- (NSString *)name;
@end

@interface PBXContainerItem : PBXObject
@end

@class PBXGroup;
@interface PBXReference : PBXContainerItem
- (BOOL)isGroup;
- (NSString *)name;
- (NSString *)absolutePath;
- (PBXGroup *)group;
- (PBXContainer *)container;
@end

@interface PBXGroup : PBXReference
- (NSArray *)children;
@end

@interface Xcode3Group : IDEGroup
- (PBXGroup *)group;
@end

@interface Xcode3Project : IDEContainer
- (Xcode3Group *)rootGroup;
@end

@interface DVTApplication : NSApplication
@end

@interface IDEApplication : DVTApplication
+ (IDEApplication *)sharedApplication;
@end

@interface IDEApplicationController : NSObject
+ (IDEApplicationController *)sharedAppController;
- (BOOL)application:(IDEApplication *)application openFile:(NSString *)filePath;
@end

@interface XCSpecification : NSObject
@end

@interface PBXFileType : XCSpecification
- (BOOL)isBundle;
- (BOOL)isApplication;
- (BOOL)isLibrary;
- (BOOL)isFramework;
- (BOOL)isProjectWrapper;
- (BOOL)isTargetWrapper;
- (BOOL)isExecutable;
@end

@interface PBXFileReference : PBXReference
- (NSString *)resolvedAbsolutePath;
- (id)fileType;
- (NSArray *)children;
@end

@interface IDEIndexSymbolOccurrence : NSObject
- (id)file;
- (id)location;
- (long long)lineNumber;
@end

@interface IDEIndexCollection : NSObject
- (NSArray *)allObjects;
@end

@interface IDEIndexSymbolOccurrenceCollection : IDEIndexCollection <NSFastEnumeration>
@end

@interface IDEIndexSymbol : NSObject
- (NSString *)name;
- (DVTSourceCodeSymbolKind *)symbolKind;
- (NSString *)displayText;
- (NSString *)completionText;
- (NSString *)displayType;
- (NSString *)descriptionText;
- (NSImage *)icon;

- (IDEIndexSymbolOccurrence *)modelOccurrence;
- (IDEIndexSymbolOccurrenceCollection *)occurrences;
- (IDEIndexSymbolOccurrenceCollection *)declarations;
- (IDEIndexSymbolOccurrenceCollection *)definitions;

- (NSArray *)containerSymbols;
- (id)containerSymbol;

- (unsigned long long)hash;
@end

@interface IDEIndexContainerSymbol : IDEIndexSymbol
- (NSArray *)children;
@end

@interface IDEIndexClassSymbol : IDEIndexContainerSymbol
- (NSArray *)categories;
@end

@interface IDEIndexProtocolSymbol : IDEIndexContainerSymbol
@end

@interface IDEIndexCategorySymbol : IDEIndexContainerSymbol
- (NSArray *)classMethods;
- (NSArray *)instanceMethods;
- (NSArray *)properties;
@end

@interface IDENavigableItem : NSObject
+ (IDENavigableItem *)navigableItemWithRepresentedObject:(id)object;
@end

@interface IDEFileNavigableItem : IDENavigableItem
+ (IDEFileNavigableItem *)navigableItemWithRepresentedObject:(id)object;
@end

@interface IDEFileReferenceNavigableItem : IDEFileNavigableItem
+ (IDEFileReferenceNavigableItem *)navigableItemWithRepresentedObject:(id)object;
@end

@interface DVTDocumentLocation : NSObject
- (DVTDocumentLocation *)initWithDocumentURL:(NSURL *)documentURL timestamp:(NSNumber *)timestamp;
- (NSURL *)documentURL;
@end

@interface DVTTextDocumentLocation : DVTDocumentLocation
- (DVTTextDocumentLocation *)initWithDocumentURL:(NSURL *)documentURL timestamp:(NSNumber *)timestamp lineRange:(NSRange)lineRange;
- (NSRange)characterRange;
- (NSURL *)documentURL;
@end

@interface DVTViewController : NSViewController
@end

@class DVTExtension;
@interface IDEViewController : DVTViewController

@property (nonatomic, retain) DVTExtension *representedExtension;

@end

@interface IDEEditorOpenSpecifier : NSObject
- (IDEEditorOpenSpecifier *)initWithNavigableItem:(IDENavigableItem *)navigableItem error:(NSError *)error;
+ (IDEEditorOpenSpecifier *)structureEditorOpenSpecifierForDocumentLocation:(DVTDocumentLocation *)documentLocation inWorkspace:(IDEWorkspace *)workspace error:(NSError *)error;
@end

@interface IDEEditorHistoryItem : NSObject
- (NSString *)historyMenuItemTitle;
- (NSURL *)documentURL;
@end

@interface DVTSourceExpression : NSObject
- (NSString *)textSelectionString;
@end

@interface IDEEditorHistoryStack : NSObject
- (NSArray *)previousHistoryItems;
- (NSArray *)nextHistoryItems;
- (IDEEditorHistoryItem *)currentEditorHistoryItem;
@end

@class IDEEditor;
@interface IDEEditorContext : IDEViewController
- (BOOL)openEditorOpenSpecifier:(IDEEditorOpenSpecifier *)openSpecifier;
- (IDEEditorHistoryStack *)currentHistoryStack;
- (IDEEditor *)editor;
@end

@interface IDEEditorArea : IDEViewController
- (IDEEditorContext *)primaryEditorContext;
- (IDEEditorContext *)lastActiveEditorContext;
@end

@interface IDEWorkspaceWindowController : NSWindowController
+ (NSArray *)workspaceWindowControllers;
+ (IDEWorkspaceWindowController *)workspaceWindowControllerForWindow:(IDEWorkspaceWindow *)window;
- (IDEEditorArea *)editorArea;
@end

@interface IDEKeyBinding : NSObject
- (NSString *)title;
- (NSString *)group;
- (NSArray *)actions;
- (NSArray *)keyboardShortcuts;
+ (IDEKeyBinding *)keyBindingWithTitle:(NSString *)title group:(NSString *)group actions:(NSArray *)actions keyboardShortcuts:(NSArray *)keyboardShortcuts;
+ (IDEKeyBinding *)keyBindingWithTitle:(NSString *)title parentTitle:(NSString *)parentTitle group:(NSString *)group actions:(NSArray *)actions keyboardShortcuts:(NSArray *)keyboardShortcuts;
@end

@interface IDEMenuKeyBinding : IDEKeyBinding
- (NSString *)commandIdentifier;
+ (IDEMenuKeyBinding *)keyBindingWithTitle:(NSString *)title group:(NSString *)group actions:(NSArray *)actions keyboardShortcuts:(NSArray *)keyboardShortcuts;
+ (IDEMenuKeyBinding *)keyBindingWithTitle:(NSString *)title parentTitle:(NSString *)parentTitle group:(NSString *)group actions:(NSArray *)actions keyboardShortcuts:(NSArray *)keyboardShortcuts;
- (void)setCommandIdentifier:(NSString *)commandIdentifier;
@end

@class IDEKeyBindingPreferenceSetManager;
@class IDEMenuKeyBindingSet;
@interface IDEKeyBindingPreferenceSet : NSObject
+ (IDEKeyBindingPreferenceSetManager *)preferenceSetsManager;
- (IDEMenuKeyBindingSet *)menuKeyBindingSet;
@end

@interface IDEKeyBindingPreferenceSetManager : NSObject
- (IDEKeyBindingPreferenceSet *)currentPreferenceSet;
@end

@interface IDEKeyBindingSet : NSObject
- (void)addKeyBinding:(IDEKeyBinding *)keyBinding;
- (void)insertObject:(IDEKeyBinding *)keyBinding inKeyBindingsAtIndex:(NSUInteger)index;
- (void)updateDictionary;
@end

@interface IDEKeyboardShortcut : NSObject
+ (id)keyboardShortcutFromStringRepresentation:(NSString *)stringRep;
- (NSString *)stringRepresentation;
- (NSString *)keyEquivalent;
- (IDEKeyboardShortcut *)keyboardShortcutFromStringRepresentation:(NSString *)stringRep;
- (unsigned long long)modifierMask;
@end

@interface IDEMenuKeyBindingSet : IDEKeyBindingSet
- (NSArray *)keyBindings;
@end

@interface DVTLayoutView_ML : NSView
{
    NSMutableDictionary *invalidationTokens;
    BOOL _layoutNeeded;
    BOOL _implementsLayoutCompletionCallback;
    NSCountedSet *_frameChangeObservations;
    NSCountedSet *_boundsChangeObservations;
    BOOL _implementsDrawRect;
    BOOL _needsSecondLayoutPass;
}

+ (void)_layoutWindow:(id)arg1;
+ (void)_recursivelyLayoutSubviewsOfView:(id)arg1 populatingSetWithLaidOutViews:(id)arg2;
+ (void)_doRecursivelyLayoutSubviewsOfView:(id)arg1 populatingSetWithLaidOutViews:(id)arg2 completionCallBackHandlers:(id)arg3 currentLayoutPass:(long long)arg4 needsSecondPass:(char *)arg5;
+ (void)scheduleWindowForLayout:(id)arg1;
+ (id)alreadyLaidOutViewsForCurrentDisplayPassOfWindow:(id)arg1;
+ (void)clearAlreadyLaidOutViewsForCurrentDisplayPassOfWindow:(id)arg1;
@property BOOL needsSecondLayoutPass; // @synthesize needsSecondLayoutPass=_needsSecondLayoutPass;
@property(getter=isLayoutNeeded) BOOL layoutNeeded; // @synthesize layoutNeeded=_layoutNeeded;
- (BOOL)wantsDefaultClipping;
- (void)stopInvalidatingLayoutWithChangesToKeyPath:(id)arg1 ofObject:(id)arg2;
- (void)invalidateLayoutWithChangesToKeyPath:(id)arg1 ofObject:(id)arg2;
- (void)_autoLayoutViewViewFrameDidChange:(id)arg1;
- (void)_autoLayoutViewViewBoundsDidChange:(id)arg1;
- (void)stopInvalidatingLayoutWithBoundsChangesToView:(id)arg1;
- (void)stopInvalidatingLayoutWithFrameChangesToView:(id)arg1;
- (void)invalidateLayoutWithBoundsChangesToView:(id)arg1;
- (void)invalidateLayoutWithFrameChangesToView:(id)arg1;
- (void)tearDownObservationForObservedObject:(id)arg1 notificationName:(id)arg2 table:(id)arg3;
- (void)setupObservationForObservedObject:(id)arg1 selector:(SEL)arg2 notificationName:(id)arg3 table:(id *)arg4;
- (void)setFrameSize:(struct CGSize)arg1;
- (void)didCompleteLayout;
- (void)layoutBottomUp;
- (void)layoutTopDown;
- (void)layoutIfNeeded;
- (void)didLayoutSubview:(id)arg1;
- (id)subviewsOrderedForLayout;
- (void)viewWillDraw;
- (void)_reallyLayoutIfNeededBottomUp;
- (void)_reallyLayoutIfNeededTopDown;
- (void)invalidateLayout;
- (void)viewDidMoveToWindow;
- (id)initWithCoder:(id)arg1;
- (id)initWithFrame:(struct CGRect)arg1;
- (void)_DVTLayoutView_MLSharedInit;
- (void)dealloc;

@end

@class DVTExtension, DVTStackBacktrace, DVTViewController, NSMapTable, NSString;

@interface DVTReplacementView : DVTLayoutView_ML
{
    Class _controllerClass;
    NSString *_controllerExtensionIdentifier;
    DVTExtension *_controllerExtension;
    DVTViewController *_installedViewController;
    id _forwardedBindingInfo;
//    id <DVTReplacementViewDelegate> _delegate;
    int _horizontalContentViewResizingMode;
    int _verticalContentViewResizingMode;
    struct {
        unsigned int _needToReloadSubview:1;
        unsigned int _shouldNotifyInstalledViewControllerObservers:1;
        unsigned int _delegate_willInstallViewController:1;
        unsigned int _delegate_didInstallViewController:1;
        unsigned int _delegate_willCloseViewController:1;
        unsigned int _delegate_willDisplayInRect:1;
        unsigned int _reserved:26;
    } _DVTReplacementViewFlags;
    BOOL _isGrouped;
    NSMapTable *_subviewFrameChangeTokens;
    void *_keepSelfAliveUntilCancellationRef;
}

+ (void)initialize;
@property BOOL isGrouped; // @synthesize isGrouped=_isGrouped;
@property(nonatomic) Class controllerClass; // @synthesize controllerClass=_controllerClass;
@property(nonatomic) int verticalContentViewResizingMode; // @synthesize verticalContentViewResizingMode=_verticalContentViewResizingMode;
@property(nonatomic) int horizontalContentViewResizingMode; // @synthesize horizontalContentViewResizingMode=_horizontalContentViewResizingMode;
- (void)discardEditing;
- (BOOL)commitEditingForAction:(int)arg1 errors:(id)arg2;
- (void)updateBoundControllerExtensionIdentifier;
- (void)updateBoundControllerClass;
@property(copy) NSString *controllerExtensionIdentifier;
- (void)_clearCurrentController;
- (void)_tearDownBinding:(id)arg1;
- (void)_forwardBinding:(id)arg1 toObject:(id)arg2 withKeyPath:(id)arg3 options:(id)arg4;
- (void)_tearDownBindings;
- (void)_forwardBindings;
- (void)layoutBottomUp;
- (void)layoutTopDown;
@property(retain) DVTViewController *installedViewController;
- (void)_tearDownViewController;
- (void)_setupViewController;
- (void)_configureExtension;
- (id)infoForBinding:(id)arg1;
- (void)unbind:(id)arg1;
- (void)bind:(id)arg1 toObject:(id)arg2 withKeyPath:(id)arg3 options:(id)arg4;
- (id)_forwardedBindingInfo;
- (void)_clearInfoForBinding:(id)arg1;
- (void)_recordInfoForBinding:(id)arg1 toObject:(id)arg2 keyPath:(id)arg3 options:(id)arg4;
- (void)primitiveInvalidate;
- (void)_recursiveDisplayAllDirtyWithLockFocus:(BOOL)arg1 visRect:(struct CGRect)arg2;
- (id)exposedBindings;
- (void)_invalidateLayoutBecauseOfSubviewFrameChange:(id)arg1;
- (void)willRemoveSubview:(id)arg1;
- (void)didAddSubview:(id)arg1;
- (id)initWithFrame:(struct CGRect)arg1;
- (void)awakeFromNib;
- (void)encodeWithCoder:(id)arg1;
- (id)initWithCoder:(id)arg1;
- (void)_commonInit;
//@property(retain, nonatomic) id <DVTReplacementViewDelegate> delegate;
- (id)accessibilityAttributeValue:(id)arg1;
- (BOOL)accessibilityIsIgnored;

// Remaining properties
@property(nonatomic, retain) DVTStackBacktrace *creationBacktrace;
@property(readonly) DVTStackBacktrace *invalidationBacktrace;
@property(readonly, nonatomic, getter=isValid) BOOL valid;

@end

@class DVTDelayedInvocation, DVTExtension, DVTReplacementView, DVTStateRepository, DVTStateToken, IDEViewController, NSString;

@interface IDEPreferencesController : NSWindowController <NSToolbarDelegate, NSWindowRestoration>
{
    DVTReplacementView *_paneReplacementView;
    DVTExtension *_currentExtension;
    DVTStateRepository *_stateRepository;
    DVTDelayedInvocation *_stateSavingInvocation;
    DVTStateToken *_stateToken;
}

+ (void)configureStateSavingObjectPersistenceByName:(id)arg1;
+ (void)restoreWindowWithIdentifier:(id)arg1 state:(id)arg2 completionHandler:(id)arg3;
+ (id)defaultPreferencesController;
@property(readonly) DVTDelayedInvocation *stateSavingInvocation; // @synthesize stateSavingInvocation=_stateSavingInvocation;
@property(retain) DVTStateToken *stateToken; // @synthesize stateToken=_stateToken;
@property(readonly) DVTStateRepository *stateRepository; // @synthesize stateRepository=_stateRepository;
@property(retain) DVTExtension *currentExtension; // @synthesize currentExtension=_currentExtension;
@property(retain) DVTReplacementView *paneReplacementView; // @synthesize paneReplacementView=_paneReplacementView;
- (BOOL)_loadStateData:(id *)arg1;
- (BOOL)_saveStateData:(id *)arg1;
- (id)_stateRepositoryFilePath;
- (void)commitStateToDictionary:(id)arg1;
- (void)revertStateWithDictionary:(id)arg1;
- (void)replacementView:(id)arg1 willCloseViewController:(id)arg2;
- (void)replacementView:(id)arg1 didInstallViewController:(id)arg2;
- (void)replacementView:(id)arg1 willInstallViewController:(id)arg2;
- (void)stateRepositoryDidChange:(id)arg1;
- (void)selectPreviousTab:(id)arg1;
- (void)selectNextTab:(id)arg1;
- (void)_selectToolbarItem:(id)arg1;
- (void)showPreferencesPanel:(id)arg1;
- (id)toolbarSelectableItemIdentifiers:(id)arg1;
- (id)toolbarDefaultItemIdentifiers:(id)arg1;
- (id)toolbarAllowedItemIdentifiers:(id)arg1;
- (id)toolbar:(id)arg1 itemForItemIdentifier:(id)arg2 willBeInsertedIntoToolbar:(BOOL)arg3;
- (void)windowWillClose:(id)arg1;
- (void)selectPreferencePaneWithIdentifier:(id)arg1;
@property(readonly) IDEViewController *currentPreferencePaneViewController;
@property(readonly) NSString *downloadsPrefPaneIdentifier;
- (void)windowDidLoad;
- (id)initWithWindow:(id)arg1;
- (void)_cachePreferencePaneExtensions;

@end

@interface DVTPlugInManager : NSObject
{
//    DVTDispatchLock *_plugInManagerLock;
    NSFileManager *_fileManager;
    NSString *_hostAppName;
    NSString *_hostAppContainingPath;
    NSMutableArray *_searchPaths;
    NSArray *_extraSearchPaths;
    NSMutableSet *_pathExtensions;
    NSMutableSet *_exposedCapabilities;
    NSMutableSet *_defaultPlugInCapabilities;
    NSMutableSet *_requiredPlugInIdentifiers;
    NSString *_plugInCachePath;
    NSDictionary *_plugInCache;
    BOOL _shouldClearPlugInCaches;
    id _plugInLocator;
    NSMutableDictionary *_plugInsByIdentifier;
    NSMutableDictionary *_extensionPointsByIdentifier;
    NSMutableDictionary *_extensionsByIdentifier;
    NSMutableDictionary *_invalidExtensionsByIdentifier;
    NSMutableSet *_warnedExtensionPointFailures;
    NSMutableSet *_nonApplePlugInSanitizedStatuses;
}

+ (void)_setDefaultPlugInManager:(id)arg1;
+ (id)defaultPlugInManager;
+ (void)initialize;
@property(retain) id plugInLocator; // @synthesize plugInLocator=_plugInLocator;
@property BOOL shouldClearPlugInCaches; // @synthesize shouldClearPlugInCaches=_shouldClearPlugInCaches;
- (id)_invalidExtensionWithIdentifier:(id)arg1;
- (id)_plugInCachePath;
- (id)_applicationCachesPath;
- (id)_toolsVersionName;
- (void)_createPlugInObjectsFromCache;
- (BOOL)_savePlugInCacheWithScanRecords:(id)arg1 error:(id *)arg2;
- (BOOL)_removePlugInCacheAndReturnError:(id *)arg1;
- (BOOL)_removePlugInCacheAtPath:(id)arg1 error:(id *)arg2;
- (id)_plugInCacheSaveFailedErrorWithUnderlyingError:(id)arg1;
- (BOOL)_loadPlugInCache:(id *)arg1;
- (BOOL)_cacheCoversPlugInsWithScanRecords:(id)arg1;
- (id)_modificationDateOfFileAtPath:(id)arg1;
@property(readonly) BOOL usePlugInCache;
- (void)_preLoadPlugIns;
- (BOOL)_checkPresenceOfRequiredPlugIns:(id)arg1 error:(id *)arg2;
- (BOOL)_checkMarketingVersionOfApplePlugIns:(id)arg1 error:(id *)arg2;
- (BOOL)shouldPerformConsistencyCheck;
- (void)_registerPlugInsFromScanRecords:(id)arg1;
- (void)_pruneUnusablePlugInsAndScanRecords:(id)arg1;
- (void)_recordSanitizedPluginStatus:(id)arg1 errorMessage:(id)arg2;
- (void)_addSanitizedNonApplePlugInStatusForBundle:(id)arg1 reason:(id)arg2;
@property(readonly) NSSet *sanitizedNonApplePlugInStatuses;
- (void)_createPlugInObjectsFromScanRecords:(id)arg1;
- (void)_applyActivationRulesToScanRecords:(id)arg1;
- (id)_scanForPlugInsInDirectories:(id)arg1 skippingDuplicatesOfPlugIns:(id)arg2;
- (BOOL)_scanForPlugIns:(id *)arg1;
@property(readonly) NSUUID *plugInHostUUID;
@property BOOL hasScannedForPlugIns; // @dynamic hasScannedForPlugIns;
- (id)_scanRecordForBundle:(id)arg1 atPath:(id)arg2;
- (BOOL)_isInitialScan;
- (id)_defaultPathExtensions;
@property(readonly) NSArray *defaultSearchPaths;
- (id)_defaultApplicationSupportSubdirectory;
@property(readonly) NSArray *extraSearchPaths;
- (id)_extensionsForExtensionPoint:(id)arg1 matchingPredicate:(id)arg2;
- (id)sharedExtensionsForExtensionPoint:(id)arg1 matchingPredicate:(id)arg2;
- (id)sharedExtensionWithIdentifier:(id)arg1;
- (id)extensionWithIdentifier:(id)arg1;
- (id)extensionPointWithIdentifier:(id)arg1;
- (id)plugInWithIdentifier:(id)arg1;
- (BOOL)scanForPlugIns:(id *)arg1;
- (id)init;
- (id)_hostAppName;
- (id)_hostAppContainingPath;

// Remaining properties
@property(copy) NSSet *defaultPlugInCapabilities; // @dynamic defaultPlugInCapabilities;
@property(copy) NSSet *exposedCapabilities; // @dynamic exposedCapabilities;
@property(readonly) NSMutableSet *mutableDefaultPlugInCapabilities; // @dynamic mutableDefaultPlugInCapabilities;
@property(readonly) NSMutableSet *mutableExposedCapabilities; // @dynamic mutableExposedCapabilities;
@property(readonly) NSMutableSet *mutablePathExtensions; // @dynamic mutablePathExtensions;
@property(readonly) NSMutableSet *mutableRequiredPlugInIdentifiers; // @dynamic mutableRequiredPlugInIdentifiers;
@property(readonly) NSMutableArray *mutableSearchPaths; // @dynamic mutableSearchPaths;
@property(copy) NSSet *pathExtensions; // @dynamic pathExtensions;
@property(copy) NSSet *requiredPlugInIdentifiers; // @dynamic requiredPlugInIdentifiers;
@property(copy) NSArray *searchPaths; // @dynamic searchPaths;

@end

@class DVTDispatchLock, DVTExtensionPoint, DVTPlugIn, DVTPlugInManager, NSBundle, NSDictionary, NSMutableDictionary, NSString, NSXMLElement;

@interface DVTExtension : NSObject
{

}

+ (void)initialize;
@property(readonly) DVTExtension *basedOnExtension; // @synthesize basedOnExtension=_basedOnExtension;
@property(readonly) DVTExtensionPoint *extensionPoint; // @synthesize extensionPoint=_extensionPoint;
@property(readonly) DVTPlugIn *plugIn; // @synthesize plugIn=_plugIn;
@property(readonly) NSDictionary *extensionData; // @synthesize extensionData=_extensionData;
@property(readonly) DVTPlugInManager *plugInManager; // @synthesize plugInManager=_plugInManager;
@property(readonly) NSString *name; // @synthesize name=_name;
@property(readonly) NSString *version; // @synthesize version=_version;
@property(readonly) NSString *identifier; // @synthesize identifier=_identifier;
- (id)_localizedStringForString:(id)arg1;
- (BOOL)_fireExtensionFault:(id *)arg1;
- (void)_adjustClassReferencesInParameterData:(id)arg1 usingSchema:(id)arg2;
- (void)_adjustElementClassAttributes:(id)arg1 forKey:(id)arg2 inParameterData:(id)arg3;
- (void)_adjustClassAttribute:(id)arg1 forKey:(id)arg2 inParameterData:(id)arg3;
- (BOOL)_adjustElement:(id)arg1 forKey:(id)arg2 inParameterData:(id)arg3;
- (BOOL)_adjustAttribute:(id)arg1 forKey:(id)arg2 inParameterData:(id)arg3;
- (BOOL)_adjustParameterData:(id)arg1 usingSchema:(id)arg2;
- (BOOL)hasValueForKey:(id)arg1;
- (BOOL)_hasValueForKey:(id)arg1 inParameterData:(id)arg2 usingSchema:(id)arg3;
- (id)valueForKey:(id)arg1 error:(id *)arg2;
- (id)valueForKey:(id)arg1;
- (id)_valueForKey:(id)arg1 inParameterData:(id)arg2 usingSchema:(id)arg3 error:(id *)arg4;
@property(readonly) NSXMLElement *extensionElement;
@property(readonly, getter=isValid) BOOL valid;
@property(readonly) NSBundle *bundle;
- (id)description;
- (void)encodeIntoPropertyList:(id)arg1;
- (void)awakeWithPropertyList:(id)arg1;
- (id)initWithPropertyList:(id)arg1 owner:(id)arg2;
- (id)initWithExtensionData:(id)arg1 plugIn:(id)arg2;

@end

@interface IDEEditor : IDEViewController
- (NSArray *)currentSelectedDocumentLocations;
- (DVTSourceExpression *)selectedExpression;
@end

@interface DVTSourceLandmarkItem : NSObject
- (NSString *)name;
@end

@interface IDEDocSymbolUtilities : NSObject
- (NSDictionary *)queryInfoFromIndexSymbol:(IDEIndexSymbol *)symbol;
- (id)typeForSymbol:(IDEIndexSymbol *)symbol;
- (void)queryInfoFromIndexSymbol:(IDEIndexSymbol *)symbol handlerBlock:(void(^)(id foo))block;
@end

@interface IDEQuickHelpQueries : NSObject
@end

@protocol IDEDocumentStructureProviding <NSObject>
@property(readonly) NSArray *ideTopLevelStructureObjects;
@end


@interface Xcode3FileReference <NSObject>
- (id)resolvedFilePath;
@end

@interface DVTSourceNodeTypes : NSObject
{
}

+ (BOOL)nodeType:(short)arg1 conformsToNodeTypeNamed:(id)arg2;
+ (long long)nodeTypesCount;
+ (id)nodeTypeNameForId:(short)arg1;
+ (short)registerNodeTypeNamed:(id)arg1;
+ (void)initialize;

@end

@interface DVTSourceModelItem : NSObject
{
    int _rc;
    struct _NSRange _relativeLocation;
    long long _langId;
    long long _token;
    DVTSourceModelItem *_parent;
    NSMutableArray *_children;
    unsigned int _nodeType:15;
    unsigned int _isOpaque:1;
    unsigned int _dirty:1;
    unsigned int _isBlock:1;
    unsigned int _ignoreToken:1;
    unsigned int _inheritsNodeType:1;
    unsigned int _isIdentifier:1;
    unsigned int _needsAdjustNodeType:1;
    unsigned int _isSimpleToken:1;
    unsigned int _isVolatile:1;
    unsigned int _needToDirtyRightEdges:1;
}

+ (id)sourceModelItemWithRange:(struct _NSRange)arg1 language:(long long)arg2 token:(long long)arg3 nodeType:(short)arg4;
@property struct _NSRange relativeLocation; // @synthesize relativeLocation=_relativeLocation;
@property(retain, nonatomic) NSMutableArray *children; // @synthesize children=_children;
@property(nonatomic) DVTSourceModelItem *parent; // @synthesize parent=_parent;
@property long long token; // @synthesize token=_token;
@property long long langId; // @synthesize langId=_langId;
- (void)enumerateIdentifierItemsInRelativeRange:(struct _NSRange)arg1 usingBlock:(id)arg2;
- (void)clearAdjustedNodeTypes;
- (long long)compare:(id)arg1;
- (id)followingItem;
- (id)precedingItem;
- (id)_lastLeafItem;
- (id)_firstLeafItem;
- (id)nextItem;
- (id)previousItem;
- (BOOL)isAncestorOf:(id)arg1;
- (id)childAdjoiningLocation:(unsigned long long)arg1;
- (id)childEnclosingLocation:(unsigned long long)arg1;
- (id)_childEnclosingLocation:(unsigned long long)arg1;
- (unsigned long long)indexOfChildAtLocation:(unsigned long long)arg1;
- (unsigned long long)indexOfChildAfterLocation:(unsigned long long)arg1;
- (unsigned long long)indexOfChildBeforeLocation:(unsigned long long)arg1;
- (unsigned long long)numberOfChildren;
- (void)addChildrenFromArray:(id)arg1 inRange:(struct _NSRange)arg2;
- (void)addChildren:(id)arg1;
- (void)addChild:(id)arg1;
- (void)assignAllParents:(id)arg1;
- (void)assignParents:(id)arg1;
- (BOOL)isVolatile;
- (void)setVolatile:(BOOL)arg1;
@property BOOL needsAdjustNodeType;
- (BOOL)needToDirtyRightEdges;
- (void)setNeedToDirtyRightEdges:(BOOL)arg1;
- (BOOL)isSimpleToken;
- (void)setIsSimpleToken:(BOOL)arg1;
- (BOOL)inheritsNodeType;
- (void)setInheritsNodeType:(BOOL)arg1;
- (BOOL)ignoreToken;
- (void)setIgnoreToken:(BOOL)arg1;
- (BOOL)dirty;
- (void)setDirty:(BOOL)arg1;
- (BOOL)isIdentifier;
- (short)rawNodeType;
- (BOOL)isOpaque;
- (void)setIsOpaque:(BOOL)arg1;
- (short)nodeType;
- (void)setNodeType:(short)arg1;
- (struct _NSRange)innerRange;
- (void)offsetBy:(long long)arg1;
- (void)setRange:(struct _NSRange)arg1;
- (struct _NSRange)range;
- (id)enclosingBlock;
- (long long)blockDepth;
- (void)setIsBlock:(BOOL)arg1;
- (BOOL)isBlock;
- (void)dirtyRange:(struct _NSRange)arg1 changeInLength:(long long)arg2;
- (void)dirtyRelativeRange:(struct _NSRange)arg1 changeInLength:(long long)arg2;
- (void)validate;
- (id)dumpContext;
- (id)contextArray;
- (id)simpleDescription;
- (id)diffableDescription;
- (id)description;
- (id)innerDescription:(id)arg1 showSelf:(BOOL)arg2;
- (id)initWithRange:(struct _NSRange)arg1 language:(long long)arg2 token:(long long)arg3 nodeType:(short)arg4;
- (BOOL)_isDeallocating;
- (BOOL)_tryRetain;
- (unsigned long long)retainCount;
- (oneway void)release;
- (id)retain;

@end

#pragma mark -

@interface DVTSourceModel : NSObject
{
    struct _NSRange _dirtyRange;
    long long _batchDelta;
    DVTSourceModelItem *_sourceItems;
    BOOL _isDoingBatchEdit;
}

+ (id)editorResponsivenessPerformanceLogAspect;
+ (void)initialize;
@property BOOL isDoingBatchEdit; // @synthesize isDoingBatchEdit=_isDoingBatchEdit;
@property long long batchDelta; // @synthesize batchDelta=_batchDelta;
@property struct _NSRange dirtyRange; // @synthesize dirtyRange=_dirtyRange;
@property(retain) DVTSourceModelItem *sourceItems; // @synthesize sourceItems=_sourceItems;
- (id)objCMethodNameForItem:(id)arg1 nameRanges:(id *)arg2;
- (BOOL)isItemDictionaryLiteral:(id)arg1;
- (BOOL)isItemObjectLiteral:(id)arg1;
- (BOOL)isItemForStatement:(id)arg1;
- (BOOL)isItemSemanticBlock:(id)arg1;
- (BOOL)isItemBracketExpression:(id)arg1;
- (BOOL)isItemAngleExpression:(id)arg1;
- (BOOL)isItemParenExpression:(id)arg1;
- (BOOL)isPostfixExpressionAtLocation:(unsigned long long)arg1;
- (BOOL)isInTokenizableCodeAtLocation:(unsigned long long)arg1;
- (BOOL)isInPlainCodeAtLocation:(unsigned long long)arg1;
- (BOOL)isInKeywordAtLocation:(unsigned long long)arg1;
- (BOOL)isIncompletionPlaceholderAtLocation:(unsigned long long)arg1;
- (BOOL)isInNumberConstantAtLocation:(unsigned long long)arg1;
- (BOOL)isInCharacterConstantAtLocation:(unsigned long long)arg1;
- (BOOL)isInIdentifierAtLocation:(unsigned long long)arg1;
- (BOOL)isInStringConstantAtLocation:(unsigned long long)arg1;
- (BOOL)isInIncludeStatementAtLocation:(unsigned long long)arg1;
- (BOOL)isInPreprocessorStatementAtLocation:(unsigned long long)arg1;
- (BOOL)isInDocCommentAtLocation:(unsigned long long)arg1;
- (BOOL)isInCommentAtLocation:(unsigned long long)arg1;
- (id)completionPlaceholderItemAtLocation:(unsigned long long)arg1;
- (id)identOrKeywordItemAtLocation:(unsigned long long)arg1;
- (id)objCDeclaratorItemAtLocation:(unsigned long long)arg1;
- (id)numberConstantAtLocation:(unsigned long long)arg1;
- (id)characterConstantAtLocation:(unsigned long long)arg1;
- (id)stringConstantAtLocation:(unsigned long long)arg1;
- (id)moduleImportStatementAtLocation:(unsigned long long)arg1;
- (id)includeStatementAtLocation:(unsigned long long)arg1;
- (id)preprocessorStatementAtLocation:(unsigned long long)arg1;
- (id)docCommentAtLocation:(unsigned long long)arg1;
- (id)commentAtLocation:(unsigned long long)arg1;
- (id)placeholderItemsFromItem:(id)arg1;
- (id)identifierItemsFromItem:(id)arg1;
- (id)commentBlockItems;
- (id)functionsAndMethodItems;
- (id)classItems;
- (void)addBlockItemsInTypeList:(long long *)arg1 fromItem:(id)arg2 toArray:(id)arg3;
- (void)addIdentifierItemsFromItem:(id)arg1 toArray:(id)arg2;
- (void)addItemsInTypeList:(long long *)arg1 fromItem:(id)arg2 toArray:(id)arg3;
- (id)functionOrMethodDefinitionAtLocation:(unsigned long long)arg1;
- (id)functionOrMethodAtLocation:(unsigned long long)arg1;
- (id)interfaceDeclarationAtLocation:(unsigned long long)arg1;
- (id)typeDeclarationAtLocation:(unsigned long long)arg1;
- (id)classAtLocation:(unsigned long long)arg1;
- (id)itemNameAtLocation:(unsigned long long)arg1 inTypeList:(long long *)arg2 nameRanges:(id *)arg3 scopeRange:(struct _NSRange *)arg4;
- (id)nameOfItem:(id)arg1 nameRanges:(id *)arg2 scopeRange:(struct _NSRange *)arg3;
- (void)enumerateIdentifierItemsInRange:(struct _NSRange)arg1 usingBlock:(id)arg2;
- (id)itemAtLocation:(unsigned long long)arg1 ofType:(id)arg2;
- (id)itemAtLocation:(unsigned long long)arg1 inTypeList:(long long *)arg2;
- (long long *)typeListForSpecNames:(id)arg1;
- (id)builtUpNameForItem:(id)arg1 nameRanges:(id *)arg2;
- (id)_builtUpNameForItem:(id)arg1 mutableNameRanges:(id)arg2;
- (id)_builtUpNameForSubTree:(id)arg1 mutableNameRanges:(id)arg2;
- (id)objectLiteralItemAtLocation:(unsigned long long)arg1;
- (id)parenItemAtLocation:(unsigned long long)arg1;
- (id)parenLikeItemAtLocation:(unsigned long long)arg1;
- (id)foldableBlockItemForLocation:(unsigned long long)arg1;
- (id)foldableBlockItemForLineAtLocation:(unsigned long long)arg1;
- (id)blockItemAtLocation:(unsigned long long)arg1;
- (long long)indentForItem:(id)arg1;
- (id)adjoiningItemAtLocation:(unsigned long long)arg1;
- (id)enclosingItemAtLocation:(unsigned long long)arg1;
- (id)_topLevelSourceItem;
- (void)parse;
- (void)doingBatchEdit:(BOOL)arg1;
- (void)dirtyRange:(struct _NSRange)arg1 changeInLength:(long long)arg2;
- (id)initWithSourceBufferProvider:(id)arg1;

@end

#pragma mark -

@protocol DVTTextStorageDelegate <NSTextStorageDelegate>

@optional
@property(readonly, nonatomic) NSDictionary *sourceLanguageServiceContext;
- (void)sourceLanguageServiceAvailabilityNotification:(BOOL)arg1 message:(id)arg2;
- (BOOL)textStorageShouldAllowEditing:(id)arg1;
- (void)textStorageDidUpdateSourceLandmarks:(id)arg1;
- (long long)nodeTypeForItem:(id)arg1 withContext:(id)arg2;
@end



@class DVTAnnotationManager, DVTHashTable, DVTMutableRangeArray, DVTObservingToken, DVTTextAnnotationIndicatorAnimation, DVTTextDocumentLocation, DVTTextPageGuideVisualization, NSAnimation, NSArray, NSDictionary, NSMutableArray, NSString, NSTimer, NSView, NSWindow;

@interface DVTSourceTextView : NSTextView <NSAnimationDelegate, NSLayoutManagerDelegate>
{
    unsigned long long _oldFocusLocation;
    NSAnimation *_blockAnimation;
    struct CGPoint _lastMouseMovedLocation;
    struct _NSRange _foldingHoverRange;
    DVTTextAnnotationIndicatorAnimation *_annotationIndicatorAnimation;
    unsigned long long _temporaryLinkHoverModifierFlags;
    unsigned long long _temporaryLinkHoverAltModifierFlags;
    NSArray *_clickedTemporaryLinkRanges;
    NSMutableArray *_clickedLinkProgressIndicators;
    struct _NSRange _ghostStringRange;
    NSTimer *_autoHighlightTokenMenuTimer;
    struct _NSRange _autoHighlightTokenMenuRange;
    double _autoHighlightTokenMenuAnimationDuration;
    NSTimer *_autoHighlightTokenMenuAnimationTimer;
    double _autoHighlightTokenMenuAnimationStartTime;
    NSWindow *_autoHighlightTokenWindow;
    NSArray *_foundLocations;
    DVTTextDocumentLocation *_currentFoundLocation;
    NSMutableArray *_visualizations;
    unsigned long long _pageGuideColumn;
    DVTTextPageGuideVisualization *_pageGuideVisualization;
    unsigned long long _locationOfAutoOpenedCloseBracket;
    unsigned long long _locationOfOpenBracePendingClose;
    NSTimer *_scrollbarMarkerUpdateTimer;
    DVTAnnotationManager *_annotationManager;
    DVTHashTable *_preparedViewAnnotations;
    NSView *_staticVisualizationView;
    int _findResultStyle;
    DVTMutableRangeArray *_typeOverCompletionRanges;
    DVTMutableRangeArray *_typeOverCompletionOpenRanges;
    NSString *_pendingTypeOverCompletion;
    struct _NSRange _pendingTypeOverCompletionOpenRange;
    BOOL _didChangeText;
    struct {
        unsigned int dDidFinishAnimatingScroll:1;
        unsigned int dDidScroll:1;
        unsigned int dColoringContext:1;
        unsigned int delegateRespondsToWillReturnPrintJobTitle:1;
        unsigned int updatingInsertionPoint:1;
        unsigned int wasPostsFrameChangedNotifications:1;
        unsigned int doingDidChangeSelection:1;
        unsigned int delegateRespondsToConstrainMinAccessoryAnnotationWidth:1;
        unsigned int delegateRespondsToConstrainMaxAccessoryAnnotationWidth:1;
        unsigned int delegateRespondsToConstrainAccessoryAnnotationWidth:1;
    } _sFlags;
    BOOL _isDoingBatchEdit;
    BOOL _allowsCodeFolding;
    BOOL _showingCodeFocus;
    BOOL _lastMouseEventWasClick;
    BOOL _tokenizedEditingEnabled;
    BOOL _animatesCurrentScroll;
    BOOL _disableUpdatingInsertionPointCount;
    BOOL _currentlyAutoCompletingBracket;
    BOOL _addedSpaceWhenAutoOpeningCloseBracket;
    BOOL _wrapsLines;
    BOOL _postsLayoutManagerNotifications;
    BOOL _scrollingInScrollView;
    DVTObservingToken *_autoHighlightTokenRangesObservingToken;
    BOOL _annotationLayoutScheduled;
    struct _NSRange _selectedRangeBeforeMouseDown;
    BOOL _ensuringLayoutForScroll;
}

+ (BOOL)_shouldEnableResponsiveScrolling;
+ (id)drawingLogAspect;
+ (id)foldingLogAspect;
+ (void)initialize;
+ (BOOL)isCompatibleWithResponsiveScrolling;
+ (id)keyPathsForValuesAffectingAccessoryAnnotationCollapsed;
+ (id)performanceLogAspect;
- (void)PBX_toggleShowsControlCharacters:(id)arg1;
- (void)PBX_toggleShowsInvisibleCharacters:(id)arg1;
- (id)_accessibilityProxiesByRange;
- (void)_adjustAccessoryAnnotations;
- (void)_adjustClickedLinkProgressIndicator:(id)arg1 withRect:(struct CGRect)arg2;
- (void)_adjustClickedLinkProgressIndicators;
- (void)_adjustSizeOfAccessoryAnnotation:(id)arg1;
- (struct _NSRange)_adjustedSelectedRange:(struct _NSRange)arg1 fromChangeIndex:(unsigned long long)arg2;
- (void)_animateAutoHighlightTokenMenuWithTimer:(id)arg1;
- (void)_animateBubbleView:(id)arg1;
- (id)_autoHighlightTokenMenu;
- (struct _NSRange)_autoHighlightTokenMenuRangeAtPoint:(struct CGPoint)arg1;
- (struct CGRect)_autoHighlightTokenRectAtPoint:(struct CGPoint)arg1;
- (id)_autoHighlightTokenWindowWithTokenRect:(struct CGRect)arg1;
- (void)_centeredScrollRectToVisible:(struct CGRect)arg1 forceCenter:(BOOL)arg2;
- (void)_clearAutoHighlightTokenMenu;
- (void)_clearClickedLinkProgressIndicators;
- (id)_clickedLinkProgressIndicatorWithRect:(struct CGRect)arg1;
- (void)_clipViewAncestorDidScroll:(id)arg1;
- (void)_commonInitDVTSourceTextView;
- (BOOL)_couldHaveBlinkTimer;
- (long long)_currentLineNumber;
- (void)_delayedTrimTrailingWhitespaceForLine:(id)arg1;
- (void)_didChangeSelection:(id)arg1;
- (void)_didClickOnTemporaryLinkWithEvent:(id)arg1;
- (void)_drawCaretForTextAnnotationsInRect:(struct CGRect)arg1;
- (long long)_drawRoundedBackgroundForFoldableBlockRangeAtLocation:(unsigned long long)arg1;
- (void)_drawViewBackgroundInRect:(struct CGRect)arg1;
- (void)_enumerateMessageBubbleAnnotationsInSelection:(id)arg1;
- (id)_findResultCurrentGradient;
- (id)_findResultCurrentUnderlineColor;
- (id)_findResultGradient;
- (id)_findResultUnderlineColor;
- (void)_finishedAnimatingScroll;
- (double)_grayLevelForDepth:(long long)arg1;
- (struct CGRect)_hitTestRectForAutoHighlightTokenWindow:(id)arg1;
- (struct _NSRange)_indentInsertedTextIfNecessaryAtRange:(struct _NSRange)arg1;
- (void)_indentSelectionByNumberOfLevels:(long long)arg1;
- (void)_invalidateAllRevealovers;
- (void)_invalidateClickedLinks;
- (void)_invalidateDisplayForViewStatusChange;
- (void)_loadColorsFromCurrentTheme;
- (double)_markForLineNumber:(unsigned long long)arg1;
- (double)_maxAllowableAccessoryAnnotationWidth;
- (double)_minAllowableAccessoryAnnotationWidth;
- (void)_mouseInside:(id)arg1;
- (unsigned long long)_nonBlankCharIndexUnderMouse;
- (void)_paste:(id)arg1 indent:(BOOL)arg2;
- (void)_popUpTokenMenu:(id)arg1;
- (void)_refreshScrollerMarkers;
- (void)_reloadAnnotationProviders;
- (void)_scheduleAnnotationLayoutAfterResize;
- (void)_scheduleAutoHighlightTokenMenuAnimationTimerIfNeeded;
- (void)_scheduleAutoHighlightTokenMenuTimerIfNeeded;
- (BOOL)_shouldHaveBlinkTimer;
- (void)_showAutoHighlightTokenMenuWithTimer:(id)arg1;
- (void)_showClickedLinkProgressIndicators;
- (void)_showTemporaryLinkForExpressionUnderMouse:(BOOL)arg1 isAlternate:(BOOL)arg2;
- (struct _NSRange)_suggestedOpenRangeForTypeOverRange:(struct _NSRange)arg1;
- (void)_themeColorsChanged:(id)arg1;
- (void)_trimTrailingWhitespaceOnLineAfterIndent:(unsigned long long)arg1 trimWhitespaceOnlyLine:(BOOL)arg2;
- (void)_unloadAnnotationProviders;
- (void)_updateAccessoryAnnotationViewsInRect:(struct CGRect)arg1;
- (void)_updateLayoutEstimation;
- (void)_updateTemporaryLinkUnderMouseForEvent:(id)arg1;
- (id)accessibilityAXAttributedStringForCharacterRange:(struct _NSRange)arg1 parent:(id)arg2;
- (id)accessibilityAttributeValue:(id)arg1;
- (id)accessibilityHitTest:(struct CGPoint)arg1;
- (id)accessibilityProxyForSelectedRange:(struct _NSRange)arg1;
- (void)addStaticVisualizationView:(id)arg1;
- (void)addTypeOverCompletionForRange:(struct _NSRange)arg1 openRange:(struct _NSRange)arg2;
- (void)addVisualization:(id)arg1 fadeIn:(BOOL)arg2 completionBlock:(id)arg3;
@property BOOL addedSpaceWhenAutoOpeningCloseBracket; // @synthesize addedSpaceWhenAutoOpeningCloseBracket=_addedSpaceWhenAutoOpeningCloseBracket;
- (void)adjustTypeOverCompletionForEditedRange:(struct _NSRange)arg1 changeInLength:(long long)arg2;
- (void)adjustTypeOverCompletionForSelectionChange:(struct _NSRange)arg1;
- (BOOL)allowsCodeFolding;
- (id)alternateColor;
- (void)animation:(id)arg1 didReachProgressMark:(float)arg2;
- (void)animationDidEnd:(id)arg1;
- (void)animationDidStop:(id)arg1;
- (BOOL)animationShouldStart:(id)arg1;
- (id)annotationForRepresentedObject:(id)arg1;
@property(retain) DVTAnnotationManager *annotationManager; // @synthesize annotationManager=_annotationManager;
@property(readonly) NSArray *annotations;
- (id)attributedStringForCompletionPlaceholderCell:(id)arg1 atCharacterIndex:(unsigned long long)arg2 withDefaultAttributes:(id)arg3;
- (id)autoCloseStringForString:(id)arg1;
- (void)autoInsertCloseBrace;
- (void)balance:(id)arg1;
- (void)breakUndoCoalescing;
- (void)clickedOnCell:(id)arg1 inRect:(struct CGRect)arg2 atIndexInToken:(unsigned long long)arg3;
- (id)codeFocusBlockAnimation;
- (BOOL)codeFocusFollowsSelection;
- (void)commentAndUncommentCurrentLines:(id)arg1;
- (id)contextForCompletionStrategiesAtWordStartLocation:(unsigned long long)arg1;
- (void)contextMenu_toggleMessageBubbleShown:(id)arg1;
- (void)deleteBackward:(id)arg1;
- (void)deleteExpressionBackward:(id)arg1;
- (void)deleteExpressionForward:(id)arg1;
- (void)deleteForward:(id)arg1;
- (void)deleteSubWordBackward:(id)arg1;
- (void)deleteSubWordForward:(id)arg1;
- (void)didAddAnnotations:(id)arg1;
- (void)didBeginScrollInScrollView:(id)arg1;
- (void)didChangeText;
- (void)didEndScrollInScrollView:(id)arg1;
- (void)didInsertCompletionTextAtRange:(struct _NSRange)arg1;
- (void)didRemoveAnnotations:(id)arg1;
- (void)doingBatchEdit:(BOOL)arg1;
- (void)drawFoundLocationsInRange:(struct _NSRange)arg1;
- (void)drawRect:(struct CGRect)arg1;
- (void)drawTextAnnotationsInRect:(struct CGRect)arg1;
- (void)dvt_viewDidEndLiveAnimation;
- (void)dvt_viewWillBeginLiveAnimation;
@property int findResultStyle; // @synthesize findResultStyle=_findResultStyle;
- (void)flagsChanged:(id)arg1;
- (long long)fmc_lineNumberForPosition:(double)arg1;
- (double)fmc_maxY;
- (double)fmc_startOfLine:(long long)arg1;
- (void)focusLocationMayHaveChanged:(id)arg1;
- (void)fold:(id)arg1;
- (void)foldAllComments:(id)arg1;
- (void)foldAllMethods:(id)arg1;
- (void)foldRecursive:(id)arg1;
- (void)foldSelection:(id)arg1;
- (id)foldString;
- (unsigned long long)foldedCharacterIndexForPoint:(struct CGPoint)arg1;
- (struct _NSRange)foldingHoverRange;
- (struct CGRect)frameForRange:(struct _NSRange)arg1 ignoreWhitespace:(BOOL)arg2;
- (void)getParagraphRect:(struct CGRect *)arg1 firstLineRect:(struct CGRect *)arg2 forLineRange:(struct _NSRange)arg3 ensureLayout:(BOOL)arg4;
@property(nonatomic) struct _NSRange ghostStringRange; // @synthesize ghostStringRange=_ghostStringRange;
- (BOOL)handleInsertTab;
- (BOOL)handleSelectNextPlaceholder;
- (BOOL)handleSelectPreviousPlaceholder;
- (void)indentSelection:(id)arg1;
- (void)indentSelectionIfIndentable:(id)arg1;
- (void)indentUserChangeBy:(long long)arg1;
- (id)initWithCoder:(id)arg1;
- (id)initWithFrame:(struct CGRect)arg1 textContainer:(id)arg2;
- (void)insertNewline:(id)arg1;
- (void)insertText:(id)arg1;
@property(readonly, getter=isAccessoryAnnotationCollapsed) BOOL accessoryAnnotationCollapsed;
- (BOOL)isCandidateTypeOverString:(id)arg1;
- (BOOL)isEditable;
- (id)language;
- (struct _NSRange)lastTypeOverCompletionRange;
- (void)layoutManager:(id)arg1 didCompleteLayoutForTextContainer:(id)arg2 atEnd:(BOOL)arg3;
- (id)layoutManager:(id)arg1 shouldUseTemporaryAttributes:(id)arg2 forDrawingToScreen:(BOOL)arg3 atCharacterIndex:(unsigned long long)arg4 effectiveRange:(struct _NSRange *)arg5;
- (unsigned long long)lineNumberForPoint:(struct CGPoint)arg1;
- (struct _NSRange)lineNumberRangeForBoundingRect:(struct CGRect)arg1;
@property unsigned long long locationOfAutoOpenedCloseBracket; // @synthesize locationOfAutoOpenedCloseBracket=_locationOfAutoOpenedCloseBracket;
@property(readonly) double maxPossibleAccessoryAnnotationWidth;
- (id)menuForEvent:(id)arg1;
@property(readonly) double minPossibleAccessoryAnnotationWidth;
- (void)mouseDown:(id)arg1;
- (void)mouseDragged:(id)arg1;
- (void)mouseMoved:(id)arg1;
- (void)mouseUp:(id)arg1;
- (void)moveCurrentLineDown:(id)arg1;
- (void)moveCurrentLineUp:(id)arg1;
- (void)moveDown:(id)arg1;
- (void)moveExpressionBackward:(id)arg1;
- (void)moveExpressionBackwardAndModifySelection:(id)arg1;
- (void)moveExpressionForward:(id)arg1;
- (void)moveExpressionForwardAndModifySelection:(id)arg1;
- (void)moveSubWordBackward:(id)arg1;
- (void)moveSubWordBackwardAndModifySelection:(id)arg1;
- (void)moveSubWordForward:(id)arg1;
- (void)moveSubWordForwardAndModifySelection:(id)arg1;
- (void)moveUp:(id)arg1;
@property(nonatomic) unsigned long long pageGuideColumn; // @synthesize pageGuideColumn=_pageGuideColumn;
- (void)paste:(id)arg1;
- (void)pasteAndPreserveFormatting:(id)arg1;
@property BOOL postsLayoutManagerNotifications; // @synthesize postsLayoutManagerNotifications=_postsLayoutManagerNotifications;
- (void)prepareContentInRect:(struct CGRect)arg1;
- (id)printJobTitle;
- (void)quickLookWithEvent:(id)arg1;
- (struct _NSRange)rangeOfCenterLine;
- (void)removeFromSuperview;
- (void)removeInvalidTypeOverCompletion;
- (void)removeStaticVisualizationView;
- (void)removeTypeOverCompletionIfAppropriateForEditedRange:(struct _NSRange)arg1 changeInLength:(long long)arg2;
- (void)removeVisualization:(id)arg1 fadeOut:(BOOL)arg2 completionBlock:(id)arg3;
- (void)resetCursorRects;
- (BOOL)resignFirstResponder;
- (void)resignKeyWindow;
- (void)rightMouseDown:(id)arg1;
- (void)rightMouseUp:(id)arg1;
- (void)scrollPoint:(struct CGPoint)arg1;
- (void)scrollRangeToVisible:(struct _NSRange)arg1;
- (void)scrollRangeToVisible:(struct _NSRange)arg1 animate:(BOOL)arg2;
- (BOOL)scrollRectToVisible:(struct CGRect)arg1;
- (void)scrollViewDidSetFrameSize:(id)arg1;
- (void)scrollWheel:(id)arg1;
- (void)selectNextToken:(id)arg1;
- (void)selectPreviousToken:(id)arg1;
- (void)setAccessoryAnnotationWidth:(double)arg1;
- (void)setAllowsCodeFolding:(BOOL)arg1;
- (void)setCurrentFoundLocation:(id)arg1;
- (void)setFoldingHoverRange:(struct _NSRange)arg1;
- (void)setFoldsFromString:(id)arg1;
- (void)setFoundLocations:(id)arg1;
- (void)setFrameSize:(struct CGSize)arg1;
- (void)setMarkedText:(id)arg1 selectedRange:(struct _NSRange)arg2;
- (void)setSelectedRange:(struct _NSRange)arg1;
- (void)setSelectedRanges:(id)arg1 affinity:(unsigned long long)arg2 stillSelecting:(BOOL)arg3;
- (void)setShowsFoldingSidebar:(BOOL)arg1;
@property unsigned long long temporaryLinkHoverAltModifierFlags; // @synthesize temporaryLinkHoverAltModifierFlags=_temporaryLinkHoverAltModifierFlags;
@property unsigned long long temporaryLinkHoverModifierFlags; // @synthesize temporaryLinkHoverModifierFlags=_temporaryLinkHoverModifierFlags;
- (void)setTextContainer:(id)arg1;
- (void)setTextStorage:(id)arg1;
- (void)setTextStorage:(id)arg1 keepOldLayout:(BOOL)arg2;
- (void)setUsesMarkedScrollbar:(BOOL)arg1;
@property(nonatomic) BOOL wrapsLines; // @synthesize wrapsLines=_wrapsLines;
- (void)shiftLeft:(id)arg1;
- (void)shiftRight:(id)arg1;
- (BOOL)shouldAutoCompleteAtLocation:(unsigned long long)arg1;
- (BOOL)shouldChangeTextInRanges:(id)arg1 replacementStrings:(id)arg2;
- (BOOL)shouldIndentPastedText:(id)arg1;
- (BOOL)shouldSuppressTextCompletion;
- (BOOL)shouldTrimTrailingWhitespace;
- (void)showAnnotation:(id)arg1 animateIndicator:(BOOL)arg2;
- (BOOL)showsFoldingSidebar;
- (void)startBlockHighlighting;
- (void)stopBlockHighlighting;
@property(readonly) NSDictionary *syntaxColoringContext;
- (void)textStorage:(id)arg1 didEndEditRange:(struct _NSRange)arg2 changeInLength:(long long)arg3;
- (void)textStorage:(id)arg1 willEndEditRange:(struct _NSRange)arg2 changeInLength:(long long)arg3;
- (void)toggleCodeFocus:(id)arg1;
- (void)toggleMessageBubbleShown:(id)arg1;
- (void)toggleTokenizedEditing:(id)arg1;
- (void)tokenizableRangesWithRange:(struct _NSRange)arg1 completionBlock:(id)arg2;
- (void)trimTrailingWhitespaceOnLine:(unsigned long long)arg1;
- (void)trimTrailingWhitespaceOnLine:(unsigned long long)arg1 trimWhitespaceOnlyLine:(BOOL)arg2;
- (void)trimTrailingWhitespaceOnLineFromCharacterIndex:(unsigned long long)arg1 trimWhitespaceOnlyLine:(BOOL)arg2;
- (struct _NSRange)typeOverCompletionRangeFollowingLocation:(unsigned long long)arg1;
- (void)unfold:(id)arg1;
- (void)unfoldAll:(id)arg1;
- (void)unfoldAllComments:(id)arg1;
- (void)unfoldAllMethods:(id)arg1;
- (void)unfoldRecursive:(id)arg1;
- (void)updateInsertionPointStateAndRestartTimer:(BOOL)arg1;
- (void)useSelectionForReplace:(id)arg1;
- (BOOL)validateMenuItem:(id)arg1;
- (BOOL)validateUserInterfaceItem:(id)arg1;
- (void)viewDidEndLiveResize;
- (void)viewDidMoveToWindow;
- (void)viewWillDraw;
- (void)viewWillMoveToWindow:(id)arg1;
- (void)viewWillStartLiveResize;
- (id)visibleAnnotationsForLineNumberRange:(struct _NSRange)arg1;
- (struct _NSRange)visibleParagraphRange;
@property(readonly) NSArray *visualizations; // @synthesize visualizations=_visualizations;
- (id)writablePasteboardTypes;
- (BOOL)writeRTFSelectionToPasteboard:(id)arg1;
- (BOOL)writeSelectionToPasteboard:(id)arg1 type:(id)arg2;

@end

#pragma mark -

@protocol DVTSourceLanguageSourceModelService <NSObject>
- (struct _NSRange)rangeForBlockContainingRange:(struct _NSRange)arg1;
- (NSString *)stringForItem:(DVTSourceModelItem *)arg1;
- (DVTSourceModelItem *)commonSourceModelItemAtRange:(struct _NSRange)arg1;
- (DVTSourceModelItem *)sourceModelItemAtCharacterIndex:(unsigned long long)arg1;
- (DVTSourceModelItem *)sourceModelItemAtCharacterIndex:(unsigned long long)arg1 affinity:(unsigned long long)arg2;
- (DVTSourceModel *)sourceModelWithoutParsing;
- (DVTSourceModel *)sourceModel;
@end

@class DVTFontAndColorTheme, DVTObservingToken, DVTSourceCodeLanguage, DVTSourceLandmarkItem, DVTSourceModel, NSDictionary, NSMutableAttributedString, NSString, NSTimer, _LazyInvalidationHelper;

@interface DVTTextStorage : NSTextStorage
{
    NSMutableAttributedString *_contents;
//    struct _DVTTextLineOffsetTable _lineOffsets;
    unsigned long long _changeCapacity;
    unsigned long long _numChanges;
    struct _DVTTextChangeEntry *_changes;
    DVTSourceCodeLanguage *_language;
    NSTimer *_sourceModelUpdater;
    DVTSourceLandmarkItem *_topSourceLandmark;
    DVTSourceLandmarkItem *_rootImportLandmark;
    NSTimer *_landmarksCacheTimer;
    double _lastEditTimestamp;
    unsigned long long _tabWidth;
    unsigned long long _indentWidth;
    unsigned long long _wrappedLineIndentWidth;
    DVTObservingToken *_wrappedLinesIndentObserver;
    double _advancementForSpace;
    DVTFontAndColorTheme *_fontAndColorTheme;
    struct _NSRange _rangeNeedingInvalidation;
    struct {
        unsigned int lineEndings:2;
        unsigned int usesTabs:1;
        unsigned int syntaxColoringEnabled:1;
        unsigned int processingLazyInvalidation:1;
        unsigned int breakChangeCoalescing:1;
        unsigned int doingBatchEdit:1;
        unsigned int batchEditMayContainTokens:1;
        unsigned int batchEditMayContainLinks:1;
        unsigned int batchEditMayContainAttachments:1;
        unsigned int doingSubwordMovement:1;
        unsigned int doingExpressionMovement:1;
        unsigned int delegateRespondsToShouldAllowEditing:1;
        unsigned int delegateRespondsToDidUpdateSourceLandmarks:1;
        unsigned int delegateRespondsToNodeTypeForItem:1;
        unsigned int delegateRespondsToSourceLanguageServiceContext:1;
        unsigned int forceFixAttributes:1;
        unsigned int languageServiceSupportsSourceModel:1;
    } _tsflags;
    _LazyInvalidationHelper *_lazyInvalidationHelper;
    id<DVTSourceLanguageSourceModelService> _sourceLanguageService;
    DVTObservingToken *_sourceLanguageServiceContextObservingToken;
}

+ (id)keyPathsForValuesAffectingSourceLanguageServiceContext;
+ (void)initialize;
+ (BOOL)usesScreenFonts;
+ (id)_changeTrackingLogAspect;
+ (id)_sourceLandmarksLogAspect;
@property unsigned long long wrappedLineIndentWidth; // @synthesize wrappedLineIndentWidth=_wrappedLineIndentWidth;
@property unsigned long long indentWidth; // @synthesize indentWidth=_indentWidth;
@property double lastEditTimestamp; // @synthesize lastEditTimestamp=_lastEditTimestamp;
- (id)updatedLocationFromLocation:(id)arg1 toTimestamp:(double)arg2;
- (id)compatibleLocationFromLocation:(id)arg1;
- (id)convertLocationToNativeNSStringEncodedLocation:(id)arg1;
- (id)convertLocationToUTF8EncodedLocation:(id)arg1;
- (void)_restoreRecomputableState;
- (void)_dropRecomputableState;
- (unsigned long long)lineBreakBeforeIndex:(unsigned long long)arg1 withinRange:(struct _NSRange)arg2;
- (id)_ancestorItemForTokenizableItem:(id)arg1;
- (long long)nodeTypeForTokenizableItem:(id)arg1;
- (double)indentationForWrappedLineAtIndex:(unsigned long long)arg1;
- (unsigned long long)leadingWhitespacePositionsForLine:(unsigned long long)arg1;
- (long long)syntaxTypeForItem:(id)arg1 context:(id)arg2;
- (id)colorAtCharacterIndex:(unsigned long long)arg1 effectiveRange:(struct _NSRange *)arg2 context:(id)arg3;
- (long long)nodeTypeAtCharacterIndex:(unsigned long long)arg1 effectiveRange:(struct _NSRange *)arg2 context:(id)arg3;
- (void)_themeColorsChanged:(id)arg1;
@property(retain) DVTFontAndColorTheme *fontAndColorTheme;
@property(getter=isSyntaxColoringEnabled) BOOL syntaxColoringEnabled;
- (id)stringBySwappingRange:(struct _NSRange)arg1 withAdjacentRange:(struct _NSRange)arg2;
- (struct _NSRange)functionOrMethodBodyRangeAtIndex:(unsigned long long)arg1;
- (struct _NSRange)functionRangeAtIndex:(unsigned long long)arg1 isDefinitionOrCall:(char *)arg2;
- (struct _NSRange)methodDefinitionRangeAtIndex:(unsigned long long)arg1;
- (struct _NSRange)methodCallRangeAtIndex:(unsigned long long)arg1;
- (id)importStatementStringAtCharacterIndex:(unsigned long long)arg1;
- (id)importStatementStringAtCharacterIndex:(unsigned long long)arg1 isModule:(char *)arg2;
- (id)symbolNameAtCharacterIndex:(unsigned long long)arg1 nameRanges:(id *)arg2;
- (unsigned long long)nextExpressionFromIndex:(unsigned long long)arg1 forward:(BOOL)arg2;
@property(getter=isExpressionMovement) BOOL expressionMovement;
- (unsigned long long)dvt_nextWordFromIndex:(unsigned long long)arg1 forward:(BOOL)arg2;
- (unsigned long long)nextWordFromIndex:(unsigned long long)arg1 forward:(BOOL)arg2;
@property(getter=isSubwordMovement) BOOL subwordMovement;
- (struct _NSRange)doubleClickAtIndex:(unsigned long long)arg1 inRange:(struct _NSRange)arg2;
- (struct _NSRange)rangeOfWordAtIndex:(unsigned long long)arg1;
- (struct _NSRange)rangeOfWordAtIndex:(unsigned long long)arg1 allowNonWords:(BOOL)arg2;
- (id)sourceLandmarkAtCharacterIndex:(unsigned long long)arg1;
- (id)_sourceLandmarkAtCharacterIndex:(unsigned long long)arg1 inLandmarkItems:(id)arg2;
- (id)importLandmarkItems;
@property(readonly) DVTSourceLandmarkItem *topSourceLandmark;
@property(readonly) BOOL hasPendingSourceLandmarkInvalidation;
- (void)_invalidateSourceLandmarks:(id)arg1;
- (void)invalidateAllLandmarks;
- (id)stringForItem:(id)arg1;
@property(readonly) DVTSourceModel *sourceModelWithoutParsing;
@property(readonly) DVTSourceModel *sourceModel;
@property(readonly) id<DVTSourceLanguageSourceModelService> sourceModelService;
@property(readonly, nonatomic) NSDictionary *sourceLanguageServiceContext;
//@property(readonly) DVTSourceLanguageService<DVTSourceLanguageSyntaxTypeService> *languageService;
@property(copy) DVTSourceCodeLanguage *language;
- (void)didReplaceCharactersInRange:(struct _NSRange)arg1 withString:(id)arg2 changeInLength:(long long)arg3 replacedString:(id)arg4;
- (void)willReplaceCharactersInRange:(struct _NSRange)arg1 withString:(id)arg2 changeInLength:(long long)arg3;
- (void)_dumpChangeHistory;
- (struct _NSRange)lineRangeForLineRange:(struct _NSRange)arg1 fromTimestamp:(double)arg2 toTimestamp:(double)arg3;
- (struct _NSRange)characterRangeForCharacterRange:(struct _NSRange)arg1 fromTimestamp:(double)arg2 toTimestamp:(double)arg3;
- (id)_debugInfoForChangeIndex:(unsigned long long)arg1 toChangeIndex:(unsigned long long)arg2;
- (unsigned long long)changeIndexForTimestamp:(double)arg1;
- (struct _NSRange)lineRangeForLineRange:(struct _NSRange)arg1 fromChangeIndex:(unsigned long long)arg2 toChangeIndex:(unsigned long long)arg3;
- (struct _NSRange)characterRangeForCharacterRange:(struct _NSRange)arg1 fromChangeIndex:(unsigned long long)arg2 toChangeIndex:(unsigned long long)arg3;
- (void)breakChangeTrackingCoalescing;
- (void)clearChangeHistory;
@property(readonly) unsigned long long currentChangeIndex;
- (id)_debugInfoString;
@property(readonly) unsigned long long numberOfLines;
- (struct _NSRange)currentWordAtIndex:(unsigned long long)arg1;
- (struct _NSRange)lineRangeForCharacterRange:(struct _NSRange)arg1;
- (struct _NSRange)characterRangeForLineRange:(struct _NSRange)arg1;
- (struct _NSRange)characterRangeFromDocumentLocation:(id)arg1;
- (void)_dumpLineOffsetsTable;
- (id)_debugStringFromUnsignedIntegers:(const unsigned long long *)arg1 count:(unsigned long long)arg2;
- (void)serviceAvailabilityNotification:(BOOL)arg1 message:(id)arg2;
- (void)scheduleLazyInvalidationForRange:(struct _NSRange)arg1;
- (void)_updateLazyInvalidationForEditedRange:(struct _NSRange)arg1 changeInLength:(long long)arg2;
- (void)_processLazyInvalidation;
- (void)_invalidateCallback:(id)arg1;
@property BOOL processingLazyInvalidation;
- (void)invalidateLayoutForLineRange:(struct _NSRange)arg1;
- (void)delayedInvalidateDisplayForLineRange:(struct _NSRange)arg1;
- (void)invalidateDisplayForLineRange:(struct _NSRange)arg1;
- (void)invalidateDisplayInRange:(struct _NSRange)arg1;
- (void)updateAttributesInRange:(struct _NSRange)arg1;
- (void)fixAttributesInRange:(struct _NSRange)arg1;
- (void)fixSyntaxColoringInRange:(struct _NSRange)arg1;
- (void)fixAttachmentAttributeInRange:(struct _NSRange)arg1;
@property id <DVTTextStorageDelegate> delegate;
- (id)_associatedTextViews;
- (void)replaceCharactersInRange:(struct _NSRange)arg1 withAttributedString:(id)arg2 withUndoManager:(id)arg3;
- (void)replaceCharactersInRange:(struct _NSRange)arg1 withString:(id)arg2 withUndoManager:(id)arg3;
- (void)addLayoutManager:(id)arg1;
- (void)invalidateAttributesInRange:(struct _NSRange)arg1;
- (BOOL)fixesAttributesLazily;
- (BOOL)_forceFixAttributes;
- (void)_setForceFixAttributes:(BOOL)arg1;
- (void)processEditing;
- (void)endEditing;
- (void)beginEditing;
- (void)replaceCharactersInRange:(struct _NSRange)arg1 withAttributedString:(id)arg2;
- (void)removeAttribute:(id)arg1 range:(struct _NSRange)arg2;
- (void)addAttributes:(id)arg1 range:(struct _NSRange)arg2;
- (void)addAttribute:(id)arg1 value:(id)arg2 range:(struct _NSRange)arg3;
- (void)setAttributes:(id)arg1 range:(struct _NSRange)arg2;
- (void)replaceCharactersInRange:(struct _NSRange)arg1 withString:(id)arg2;
- (BOOL)isDoingBatchEdit;
- (void)doingBatchEdit:(BOOL)arg1;
- (void)doingBatchEdit:(BOOL)arg1 notifyModel:(BOOL)arg2;
@property BOOL batchEditMayContainAttachments;
@property BOOL batchEditMayContainLinks;
@property BOOL batchEditMayContainTokens;
- (void)resetAdvancementForSpace;
@property(readonly) double advancementForTab;
@property(readonly) double advancementForSpace;
@property BOOL usesTabs;
@property(nonatomic) unsigned long long tabWidth;
@property(readonly) BOOL isEditable;
@property unsigned long long lineEndings;
@property(readonly, copy) NSString *description;
- (void)dealloc;
- (id)init;
- (id)initWithString:(id)arg1;
- (id)initWithString:(id)arg1 attributes:(id)arg2;
- (id)initWithAttributedString:(id)arg1;
- (id)initWithOwnedMutableAttributedString:(id)arg1;
- (void)_dvtTextStorageCommonInit;
- (BOOL)_isExpressionItemLikeFunction:(id)arg1;
- (BOOL)_isExpressionItemLikelyTarget:(id)arg1;
- (BOOL)_isItemExpression:(id)arg1;
- (unsigned long long)_reverseParseExpressionFromIndex:(unsigned long long)arg1 ofParent:(id)arg2;
- (unsigned long long)_startLocationForObjCMethodCallAtLocation:(unsigned long long)arg1 withArgs:(char *)arg2;
- (unsigned long long)locationForOpeningBracketForClosingBracket:(unsigned long long)arg1 withArgs:(char *)arg2;
- (BOOL)isAtFirstArgumentInMethodCallAtLocation:(unsigned long long)arg1 inCall:(char *)arg2;
- (BOOL)_isTextEmptyInBetweenItem:(id)arg1 prevItem:(id)arg2;
- (id)_textInBetweenItem:(id)arg1 prevItem:(id)arg2;
- (id)_parenLikeItemAtLocation:(unsigned long long)arg1;
- (BOOL)_isItemParenExpression:(id)arg1;
- (BOOL)_isItemBlockExpression:(id)arg1;
- (BOOL)_isItemBracketLikeExpression:(id)arg1;
- (BOOL)_isItemBracketExpression:(id)arg1;
- (BOOL)indentAtBeginningOfLineForCharacterRange:(struct _NSRange)arg1 undoManager:(id)arg2;
- (BOOL)isAtBOL:(struct _NSRange)arg1;
- (void)indentCharacterRange:(struct _NSRange)arg1 undoManager:(id)arg2;
- (void)indentLineRange:(struct _NSRange)arg1 undoManager:(id)arg2;
- (BOOL)indentLine:(long long)arg1 options:(unsigned long long)arg2 undoManager:(id)arg3;
- (long long)firstNonblankForLine:(long long)arg1 convertTabs:(BOOL)arg2;
- (id)getTextForLineSansBlanks:(long long)arg1;
@property(readonly, getter=isIndentable) BOOL indentable;
- (long long)getIndentForLine:(long long)arg1;
- (long long)_getIndentForObjectLiteral:(id)arg1 atLocation:(unsigned long long)arg2;
- (BOOL)_isInvalidObjectLiteralItem:(id)arg1;
- (unsigned long long)firstColonAfterItem:(id)arg1 inRange:(struct _NSRange)arg2;
- (long long)columnForPositionConvertingTabs:(unsigned long long)arg1;
- (id)attribute:(id)arg1 atIndex:(unsigned long long)arg2 longestEffectiveRange:(struct _NSRange *)arg3 inRange:(struct _NSRange)arg4;
- (id)attributesAtIndex:(unsigned long long)arg1 longestEffectiveRange:(struct _NSRange *)arg2 inRange:(struct _NSRange)arg3;
- (id)attributedSubstringFromRange:(struct _NSRange)arg1;
- (id)attribute:(id)arg1 atIndex:(unsigned long long)arg2 effectiveRange:(struct _NSRange *)arg3;
- (unsigned long long)length;
- (id)attributesAtIndex:(unsigned long long)arg1 effectiveRange:(struct _NSRange *)arg2;
- (id)contents;
- (id)string;

@end


@class DVTCustomDataSpecifier, DVTPointerArray, DVTStackBacktrace, NSColor, NSFont, NSImage, NSString, NSURL;

@interface DVTFontAndColorTheme : NSObject
{
    NSString *_name;
    NSImage *_image;
    NSURL *_dataURL;
    DVTCustomDataSpecifier *_customDataSpecifier;
    NSColor *_sourceTextBackgroundColor;
    NSColor *_sourceTextSidebarBackgroundColor;
    NSColor *_sourceTextSidebarEdgeColor;
    NSColor *_sourceTextSidebarNumbersColor;
    NSColor *_sourceTextFoldbarBackgroundColor;
    NSColor *_sourceTextSelectionColor;
    NSColor *_sourceTextSecondarySelectionColor;
    NSColor *_sourceTextInsertionPointColor;
    NSColor *_sourceTextInvisiblesColor;
    NSColor *_sourceTextBlockDimBackgroundColor;
    NSColor *_sourceTextTokenizedBorderColor;
    NSColor *_sourceTextTokenizedBackgroundColor;
    NSColor *_sourceTextTokenizedBorderSelectedColor;
    NSColor *_sourceTextTokenizedBackgroundSelectedColor;
    NSColor *_consoleTextBackgroundColor;
    NSColor *_consoleTextSelectionColor;
    NSColor *_consoleTextSecondarySelectionColor;
    NSColor *_consoleTextInsertionPointColor;
    NSColor *_consoleDebuggerPromptTextColor;
    NSColor *_consoleDebuggerInputTextColor;
    NSColor *_consoleDebuggerOutputTextColor;
    NSColor *_consoleExecutableInputTextColor;
    NSColor *_consoleExecutableOutputTextColor;
    NSFont *_consoleDebuggerPromptTextFont;
    NSFont *_consoleDebuggerInputTextFont;
    NSFont *_consoleDebuggerOutputTextFont;
    NSFont *_consoleExecutableInputTextFont;
    NSFont *_consoleExecutableOutputTextFont;
    NSColor *_debuggerInstructionPointerColor;
    NSColor *_sourcePlainTextColor;
    NSFont *_sourcePlainTextFont;
    DVTPointerArray *_syntaxColorsByNodeType;
    DVTPointerArray *_syntaxFontsByNodeType;
    NSColor *_sourceTextCompletionPreviewColor;
    BOOL _builtIn;
    BOOL _loadedData;
    BOOL _contentNeedsSaving;
    BOOL _hasMultipleSourceTextFonts;
}

+ (id)_defaultSourceCodeFont;
+ (id)keyPathsForValuesAffectingConsoleTextSecondarySelectionColor;
+ (id)keyPathsForValuesAffectingSourceTextSecondarySelectionColor;
+ (id)titleForNewPreferenceSetFromTemplate;
+ (id)preferenceSetsListHeader;
+ (id)preferenceSetsFileExtension;
+ (id)defaultKeyForExcludedBuiltInPreferenceSets;
+ (id)defaultKeyForCurrentPreferenceSet;
+ (id)builtInPreferenceSetsDirectoryURL;
+ (id)systemPreferenceSet;
+ (id)preferenceSetGroupingName;
+ (id)_nodeTypesIncludedInPreferences;
+ (id)_stringRepresentationOfFont:(id)arg1;
+ (id)_fontWithName:(id)arg1 size:(double)arg2;
+ (id)currentTheme;
+ (id)preferenceSetsManager;
+ (void)initialize;
@property(readonly) BOOL loadedData; // @synthesize loadedData=_loadedData;
@property(readonly) DVTPointerArray *syntaxFontsByNodeType; // @synthesize syntaxFontsByNodeType=_syntaxFontsByNodeType;
@property(readonly) DVTPointerArray *syntaxColorsByNodeType; // @synthesize syntaxColorsByNodeType=_syntaxColorsByNodeType;
@property(nonatomic) BOOL hasMultipleSourceTextFonts; // @synthesize hasMultipleSourceTextFonts=_hasMultipleSourceTextFonts;
@property BOOL contentNeedsSaving; // @synthesize contentNeedsSaving=_contentNeedsSaving;
@property(retain) DVTCustomDataSpecifier *customDataSpecifier; // @synthesize customDataSpecifier=_customDataSpecifier;
@property(readonly, getter=isBuiltIn) BOOL builtIn; // @synthesize builtIn=_builtIn;
@property(retain) NSImage *image; // @synthesize image=_image;
@property(copy) NSString *name; // @synthesize name=_name;
- (void)setFont:(id)arg1 forNodeTypes:(id)arg2;
- (void)setColor:(id)arg1 forNodeTypes:(id)arg2;
- (void)_setColorOrFont:(id)arg1 forNodeTypes:(id)arg2;
- (id)fontForNodeType:(short)arg1;
- (id)colorForNodeType:(short)arg1;
@property(readonly) NSFont *sourcePlainTextFont;
@property(readonly) NSColor *sourcePlainTextColor;
- (void)setDebuggerInstructionPointerColor:(id)arg1;
- (void)setConsoleExecutableOutputTextFont:(id)arg1;
- (void)setConsoleExecutableInputTextFont:(id)arg1;
- (void)setConsoleDebuggerOutputTextFont:(id)arg1;
- (void)setConsoleDebuggerInputTextFont:(id)arg1;
- (void)setConsoleDebuggerPromptTextFont:(id)arg1;
- (void)setConsoleExecutableOutputTextColor:(id)arg1;
- (void)setConsoleExecutableInputTextColor:(id)arg1;
- (void)setConsoleDebuggerOutputTextColor:(id)arg1;
- (void)setConsoleDebuggerInputTextColor:(id)arg1;
- (void)setConsoleDebuggerPromptTextColor:(id)arg1;
- (void)primitiveSetConsoleDebuggerPromptTextColor:(id)arg1;
- (void)setConsoleTextInsertionPointColor:(id)arg1;
- (void)setConsoleTextSelectionColor:(id)arg1;
- (void)setConsoleTextBackgroundColor:(id)arg1;
- (void)setSourceTextInvisiblesColor:(id)arg1;
- (void)setSourceTextInsertionPointColor:(id)arg1;
- (void)setSourceTextSelectionColor:(id)arg1;
- (void)setSourceTextBackgroundColor:(id)arg1;
- (void)_setColorOrFont:(id)arg1 forKey:(id)arg2 colorOrFontivar:(id *)arg3;
@property(readonly) NSColor *debuggerInstructionPointerColor;
@property(readonly) NSFont *consoleExecutableOutputTextFont;
@property(readonly) NSFont *consoleExecutableInputTextFont;
@property(readonly) NSFont *consoleDebuggerOutputTextFont;
@property(readonly) NSFont *consoleDebuggerInputTextFont;
@property(readonly) NSFont *consoleDebuggerPromptTextFont;
@property(readonly) NSColor *consoleExecutableOutputTextColor;
@property(readonly) NSColor *consoleExecutableInputTextColor;
@property(readonly) NSColor *consoleDebuggerOutputTextColor;
@property(readonly) NSColor *consoleDebuggerInputTextColor;
@property(readonly) NSColor *consoleDebuggerPromptTextColor;
@property(readonly) NSColor *consoleTextInsertionPointColor;
@property(readonly) NSColor *consoleTextSecondarySelectionColor;
@property(readonly) NSColor *consoleTextSelectionColor;
@property(readonly) NSColor *consoleTextBackgroundColor;
@property(readonly) NSColor *sourceTextTokenizedBackgroundSelectedColor;
@property(readonly) NSColor *sourceTextTokenizedBorderSelectedColor;
@property(readonly) NSColor *sourceTextTokenizedBackgroundColor;
@property(readonly) NSColor *sourceTextTokenizedBorderColor;
@property(readonly) NSColor *sourceTextLinkColor;
@property(readonly) NSColor *sourceTextCompletionPreviewColor;
@property(readonly) NSColor *sourceTextBlockDimBackgroundColor;
@property(readonly) NSColor *sourceTextInvisiblesColor;
@property(readonly) NSColor *sourceTextInsertionPointColor;
@property(readonly) NSColor *sourceTextSecondarySelectionColor;
@property(readonly) NSColor *sourceTextSelectionColor;
@property(readonly) NSColor *sourceTextFoldbarBackgroundColor;
@property(readonly) NSColor *sourceTextSidebarNumbersColor;
@property(readonly) NSColor *sourceTextSidebarEdgeColor;
@property(readonly) NSColor *sourceTextSidebarBackgroundColor;
@property(readonly) NSColor *sourceTextBackgroundColor;
- (id)description;
@property(readonly) NSString *localizedName;
- (void)_updateHasMultipleSourceTextFonts;
- (void)_updateDerivedColors;
- (BOOL)_loadFontsAndColors;
- (id)dataRepresentationWithError:(id *)arg1;
- (void)primitiveInvalidate;
- (id)initWithCustomDataSpecifier:(id)arg1 basePreferenceSet:(id)arg2;
- (id)initWithName:(id)arg1 dataURL:(id)arg2;
- (id)_initWithName:(id)arg1 syntaxColorsByNodeType:(id)arg2 syntaxFontsByNodeType:(id)arg3;
- (void)_themeCommonInit;
- (id)init;

// Remaining properties
@property(retain) DVTStackBacktrace *creationBacktrace;
@property(readonly) DVTStackBacktrace *invalidationBacktrace;
@property(readonly, nonatomic, getter=isValid) BOOL valid;

@end

@interface DVTControllerContentView : DVTLayoutView_ML
{
    struct CGSize _minContentFrameSize;
    struct CGSize _maxContentFrameSize;
    DVTViewController *_viewController;
    NSWindow *_kvoWindow;
    int _horizontalAlignmentWhenClipping;
    int _horizontalAlignmentWhenPadding;
    int _verticalAlignmentWhenClipping;
    int _verticalAlignmentWhenPadding;
    int _verticalContentViewResizingMode;
    int _horizontalContentViewResizingMode;
    BOOL _isInstalled;
    BOOL _isPadding;
    BOOL _isReplacingSubview;
    BOOL _disablePaddingWarning;
    BOOL _isGrouped;
    NSMutableArray *_frameChangeTokens;
    NSArray *_currentContentViewConstraints;
    BOOL _constraintsCameFromNib;
}

+ (void)initialize;
@property BOOL isGrouped; // @synthesize isGrouped=_isGrouped;
@property BOOL disablePaddingWarning; // @synthesize disablePaddingWarning=_disablePaddingWarning;
@property(nonatomic) int verticalContentViewResizingMode; // @synthesize verticalContentViewResizingMode=_verticalContentViewResizingMode;
@property(nonatomic) int horizontalContentViewResizingMode; // @synthesize horizontalContentViewResizingMode=_horizontalContentViewResizingMode;
@property(nonatomic) int verticalAlignmentWhenClipping; // @synthesize verticalAlignmentWhenClipping=_verticalAlignmentWhenClipping;
@property(nonatomic) int horizontalAlignmentWhenClipping; // @synthesize horizontalAlignmentWhenClipping=_horizontalAlignmentWhenClipping;
@property(nonatomic) struct CGSize minimumContentViewFrameSize; // @synthesize minimumContentViewFrameSize=_minContentFrameSize;
@property(nonatomic) int verticalAlignmentWhenPadding; // @synthesize verticalAlignmentWhenPadding=_verticalAlignmentWhenPadding;
@property(nonatomic) int horizontalAlignmentWhenPadding; // @synthesize horizontalAlignmentWhenPadding=_horizontalAlignmentWhenPadding;
@property(nonatomic) struct CGSize maximumContentViewFrameSize; // @synthesize maximumContentViewFrameSize=_maxContentFrameSize;
- (BOOL)performKeyEquivalent:(id)arg1;
- (void)_invalidateLayoutBecauseOfSubviewFrameChange:(id)arg1;
- (void)willRemoveSubview:(id)arg1;
- (void)didAddSubview:(id)arg1;
- (void)windowWillClose:(id)arg1;
- (void)viewDidMoveToSuperview;
- (void)viewDidMoveToWindow;
- (void)viewWillMoveToSuperview:(id)arg1;
- (void)viewWillMoveToWindow:(id)arg1;
@property(readonly) BOOL isInstalled;
- (void)_viewDidInstall;
- (void)_viewWillUninstall;
@property(retain) IBOutlet NSView *contentView;
- (void)replaceSubview:(id)arg1 with:(id)arg2;
- (void)setSubviews:(id)arg1;
- (void)addSubview:(id)arg1;
- (void)layoutBottomUp;
- (void)layoutTopDown;
- (void)setTranslatesAutoresizingMaskIntoConstraints:(BOOL)arg1;
- (void)_syncContentViewTranslatesAutoresizingMaskIntoConstraintsValue;
- (void)updateConstraints;
- (void)setNextResponder:(id)arg1;
@property(retain, nonatomic) DVTViewController *viewController;
- (void)_checkKvoWindow;
@property(readonly) NSWindow *kvoWindow;
- (void)primitiveInvalidate;
- (id)initWithFrame:(struct CGRect)arg1;
- (void)awakeFromNib;
- (id)accessibilityAttributeValue:(id)arg1;
- (BOOL)accessibilityIsIgnored;

// Remaining properties
@property(retain) DVTStackBacktrace *creationBacktrace;
@property(readonly) DVTStackBacktrace *invalidationBacktrace;
@property(readonly, nonatomic, getter=isValid) BOOL valid;

@end

@interface DVTBorderedView : DVTLayoutView_ML
{
    NSColor *_topBorderColor;
    NSColor *_bottomBorderColor;
    NSColor *_leftBorderColor;
    NSColor *_rightBorderColor;
    NSColor *_topInactiveBorderColor;
    NSColor *_bottomInactiveBorderColor;
    NSColor *_leftInactiveBorderColor;
    NSColor *_rightInactiveBorderColor;
    NSColor *_shadowColor;
    NSColor *_backgroundColor;
    NSColor *_inactiveBackgroundColor;
    NSGradient *_backgroundGradient;
    NSGradient *_inactiveBackgroundGradient;
    NSView *_contentView;
    int _verticalContentViewResizingMode;
    int _horizontalContentViewResizingMode;
    int _borderSides;
    int _shadowSides;
//    id <DVTCancellable> _windowActivationObservation;
//    int _highlightSides;
//    id <DVTPainter> _backgroundPainter;
}

//@property(retain) id <DVTPainter> backgroundPainter; // @synthesize backgroundPainter=_backgroundPainter;
@property(nonatomic) int highlightSides; // @synthesize highlightSides=_highlightSides;
@property(nonatomic) int verticalContentViewResizingMode; // @synthesize verticalContentViewResizingMode=_verticalContentViewResizingMode;
@property(copy, nonatomic) NSColor *topInactiveBorderColor; // @synthesize topInactiveBorderColor=_topInactiveBorderColor;
@property(copy, nonatomic) NSColor *topBorderColor; // @synthesize topBorderColor=_topBorderColor;
@property int shadowSides; // @synthesize shadowSides=_shadowSides;
@property(copy) NSColor *shadowColor; // @synthesize shadowColor=_shadowColor;
@property(copy, nonatomic) NSColor *rightInactiveBorderColor; // @synthesize rightInactiveBorderColor=_rightInactiveBorderColor;
@property(copy, nonatomic) NSColor *rightBorderColor; // @synthesize rightBorderColor=_rightBorderColor;
@property(copy, nonatomic) NSColor *leftInactiveBorderColor; // @synthesize leftInactiveBorderColor=_leftInactiveBorderColor;
@property(copy, nonatomic) NSColor *leftBorderColor; // @synthesize leftBorderColor=_leftBorderColor;
@property(copy, nonatomic) NSGradient *inactiveBackgroundGradient; // @synthesize inactiveBackgroundGradient=_inactiveBackgroundGradient;
@property(copy, nonatomic) NSColor *inactiveBackgroundColor; // @synthesize inactiveBackgroundColor=_inactiveBackgroundColor;
@property(nonatomic) int horizontalContentViewResizingMode; // @synthesize horizontalContentViewResizingMode=_horizontalContentViewResizingMode;
@property(nonatomic) NSView *contentView; // @synthesize contentView=_contentView;
@property(copy, nonatomic) NSColor *bottomInactiveBorderColor; // @synthesize bottomInactiveBorderColor=_bottomInactiveBorderColor;
@property(copy, nonatomic) NSColor *bottomBorderColor; // @synthesize bottomBorderColor=_bottomBorderColor;
@property(nonatomic) int borderSides; // @synthesize borderSides=_borderSides;
@property(copy, nonatomic) NSGradient *backgroundGradient; // @synthesize backgroundGradient=_backgroundGradient;
@property(copy, nonatomic) NSColor *backgroundColor; // @synthesize backgroundColor=_backgroundColor;
- (void)window:(id)arg1 didChangeActivationState:(long long)arg2;
- (void)viewWillMoveToWindow:(id)arg1;
- (void)drawRect:(struct CGRect)arg1;
- (void)drawBorderInRect:(struct CGRect)arg1;
- (void)drawHighlightInRect:(struct CGRect)arg1;
- (void)drawBackgroundInRect:(struct CGRect)arg1;
- (BOOL)_isInactive;
- (void)layoutBottomUp;
- (void)layoutTopDown;
- (void)_contentViewFrameDidChange:(id)arg1;
- (struct CGSize)frameSizeForContentSize:(struct CGSize)arg1;
- (struct CGSize)boundSizeForContentSize:(struct CGSize)arg1;
@property(readonly) struct CGRect contentRect;
- (struct CGRect)_contentRectExcludingShadow;
//- (CDStruct_bf6d4a14)_contentInset;
//- (CDStruct_bf6d4a14)_borderInset;
//- (CDStruct_bf6d4a14)_shadowInset;
- (BOOL)isShowingShadow;
- (void)setAllInactiveBordersToColor:(id)arg1;
- (void)setAllBordersToColor:(id)arg1;
- (void)setShadowSide:(int)arg1;
- (void)_setBorderSides:(int)arg1;
- (void)dealloc;
- (void)encodeWithCoder:(id)arg1;
- (id)initWithCoder:(id)arg1;
- (id)initWithFrame:(struct CGRect)arg1;

@end

@class DVTBorderedView, DVTObservingToken, DVTReplacementView, DVTTabChooserView, NSArray, NSArrayController, NSColor, NSFont, NSObjectController, NSTableView, NSView;

@interface IDEFontAndColorPrefsPaneController : IDEViewController <NSTableViewDelegate>
{
    DVTReplacementView *preferenceSetReplacementView;
    DVTBorderedView *_fontAndColorBorderView;
    DVTTabChooserView *_tabChooserView;
    NSTableView *_fontAndColorItemTable;
    NSArrayController *_categoriesArrayController;
    NSObjectController *_currentThemeObjectController;
    DVTBorderedView *_generalColorView;
    NSView *_sourceEditorGeneralView;
    NSView *_consoleGeneralView;
    NSArray *_fontAndColorItems;
    DVTObservingToken *_selectedTabObserver;
    DVTObservingToken *_backgroundColorObserver;
    DVTObservingToken *_selectionIndexesObserver;
}

+ (void)initialize;
@property(readonly) NSArrayController *categoriesArrayController; // @synthesize categoriesArrayController=_categoriesArrayController;
@property(retain) NSArray *fontAndColorItems; // @synthesize fontAndColorItems=_fontAndColorItems;
- (void)changeFont:(id)arg1;
- (void)chooseFont:(id)arg1;
- (double)tableView:(id)arg1 heightOfRow:(long long)arg2;
- (void)tableView:(id)arg1 willDisplayCell:(id)arg2 forTableColumn:(id)arg3 row:(long long)arg4;
- (id)_theme;
- (void)_sourceTextColorsChanged:(id)arg1;
- (void)_updateBindingsBasedOnSelectedTab;
- (void)_handleTabChanged;
- (void)_initTabChooserView;
- (void)viewWillUninstall;
- (void)viewDidInstall;
- (void)loadView;
- (void)_updateFontPickerAndColorWell;
@property(copy) NSFont *combinedSyntaxFont;
@property(copy) NSColor *combinedSyntaxColor;
- (void)primitiveInvalidate;

@end

@class DVTChoice, NSArray, NSMapTable, NSMutableArray, NSSearchField;

@interface DVTTabChooserView : DVTBorderedView
{
    double *_currentChoiceXCoordinates;
    NSSearchField *_searchField;
    DVTChoice *_selectedChoice;
    long long _pressedIndex;
    long long _mouseDownIndex;
    NSMutableArray *_choices;
    NSMapTable *_accessibilityProxiesByChoice;
    struct {
        unsigned int hasSearchField:1;
        unsigned int _reserved:7;
    } _flags;
//    id <DVTTabChooserViewDelegate> _delegate;
    double _choicesOffset;
}

+ (id)keyPathsForValuesAffectingSelectedChoice;
+ (void)initialize;
@property double choicesOffset; // @synthesize choicesOffset=_choicesOffset;
//@property __weak id <DVTTabChooserViewDelegate> delegate; // @synthesize delegate=_delegate;
@property(retain, nonatomic) NSSearchField *searchField; // @synthesize searchField=_searchField;
- (id)accessibilityHitTest:(struct CGPoint)arg1;
- (BOOL)accessibilityIsAttributeSettable:(id)arg1;
- (id)accessibilityAttributeValue:(id)arg1;
- (id)accessibilityAttributeNames;
- (BOOL)accessibilityIsIgnored;
- (id)accessibilityProxyForChoice:(id)arg1;
@property BOOL hasSearchField;
- (void)installSearchField;
- (struct CGRect)searchFieldFrame;
- (void)mouseUp:(id)arg1;
- (void)mouseDragged:(id)arg1;
- (void)mouseDown:(id)arg1;
- (BOOL)acceptsFirstMouse:(id)arg1;
- (id)choiceForEvent:(id)arg1 index:(long long *)arg2;
- (id)choiceForPoint:(struct CGPoint)arg1 index:(long long *)arg2;
- (void)drawRect:(struct CGRect)arg1;
- (void)drawChoiceAtIndex:(long long)arg1;
- (void)drawOneChoice;
- (id)attributedTitleForChoice:(id)arg1 forceActive:(BOOL)arg2;
- (void)updateGeometryForDrawing;
- (struct CGRect)rectForChoice:(id)arg1;
- (struct CGRect)rectForChoiceAtIndex:(long long)arg1;
@property(readonly) double minimumWidth;
- (struct CGRect)totalChoicesRect;
- (double)totalWidth;
- (double)widthForChoiceAtIndex:(long long)arg1;
- (double)widthForChoice:(id)arg1;
- (void)updateBoundSelectedObjects;
@property(retain) DVTChoice *selectedChoice; // @synthesize selectedChoice=_selectedChoice;
@property(readonly) NSMutableArray *mutableChoices;
- (void)updateBoundContent;
@property(copy) NSArray *choices;
- (id)choiceWithIdentifier:(id)arg1;
- (id)choiceAtIndex:(long long)arg1;
- (void)viewWillMoveToWindow:(id)arg1;
- (void)dealloc;
- (id)initWithCoder:(id)arg1;
- (id)initWithFrame:(struct CGRect)arg1;
- (void)commonInit;
- (id)dvtExtraBindings;

@end


@interface DVTChoice : NSObject
{
    NSString *_title;
    NSString *_toolTip;
    NSImage *_image;
    NSString *_identifier;
    id _representedObject;
    BOOL _enabled;
}

@property(getter=isEnabled) BOOL enabled; // @synthesize enabled=_enabled;
@property(readonly) id representedObject; // @synthesize representedObject=_representedObject;
@property(copy) NSString *identifier; // @synthesize identifier=_identifier;
@property(readonly) NSImage *image; // @synthesize image=_image;
@property(readonly) NSString *toolTip; // @synthesize toolTip=_toolTip;
@property(readonly) NSString *title; // @synthesize title=_title;
- (id)description;
- (id)initWithTitle:(id)arg1 toolTip:(id)arg2 image:(id)arg3 representedObject:(id)arg4;

@end

@interface IDEFontAndColorFontTransformer : NSValueTransformer
{
}

+ (BOOL)allowsReverseTransformation;
+ (Class)transformedValueClass;
- (id)transformedValue:(id)arg1;

@end

@class DVTDispatchLock, DVTLayoutManager, DVTNotificationToken, DVTObservingToken, DVTOperation, DVTSDK, DVTScopeBarController, DVTSourceExpression, DVTSourceLanguageService, DVTSourceTextView, DVTStackBacktrace, DVTTextDocumentLocation, DVTTextSidebarView, DVTWeakInterposer, IDEAnalyzerResultsExplorer, IDENoteAnnotationExplorer, IDESingleFileProcessingToolbarController, IDESourceCodeDocument, IDESourceCodeEditorAnnotationProvider, IDESourceCodeEditorContainerView, IDESourceCodeHelpNavigationRequest, IDESourceCodeNavigationRequest, IDESourceCodeSingleLineBlameProvider, IDESourceControlLogDetailViewController, IDEViewController;

@interface IDESourceCodeEditor : IDEEditor <NSTextViewDelegate, NSMenuDelegate, NSPopoverDelegate>
{
    NSScrollView *_scrollView;
    DVTSourceTextView *_textView;
//    DVTLayoutManager *_layoutManager;
    //    IDESourceCodeEditorContainerView *_containerView;
    //    DVTTextSidebarView *_sidebarView;
    NSArray *_currentSelectedItems;
    NSDictionary *_syntaxColoringContext;
    DVTSourceExpression *_selectedExpression;
    DVTSourceExpression *_mouseOverExpression;
    //    IDESourceCodeNavigationRequest *_currentNavigationRequest;
    //    IDESourceCodeHelpNavigationRequest *_helpNavigationRequest;
    NSObject<OS_dispatch_queue> *_symbolLookupQueue;
    NSMutableArray *_stateChangeObservingTokens;
    DVTObservingToken *_topLevelItemsObserverToken;
    DVTObservingToken *_firstResponderObserverToken;
    DVTObservingToken *_editorLiveIssuesEnabledObserverToken;
    DVTObservingToken *_navigatorLiveIssuesEnabledObserverToken;
    DVTNotificationToken *_workspaceLiveSourceIssuesEnabledObserver;
    DVTObservingToken *_needsDiagnosisObserverToken;
    DVTObservingToken *_diagnosticItemsObserverToken;
    NSOperationQueue *_diagnoseRelatedFilesQueue;
    //    DVTOperation *_findRelatedFilesOperation;
    DVTObservingToken *_sessionInProgressObserverToken;
    DVTNotificationToken *_blueprintDidChangeNotificationObservingToken;
    DVTNotificationToken *_textStorageDidProcessEndingObserver;
    DVTNotificationToken *_textViewBoundsDidChangeObservingToken;
    DVTNotificationToken *_sourceCodeDocumentDidSaveNotificationToken;
    DVTNotificationToken *_indexDidChangeNotificationToken;
    //    IDESourceCodeEditorAnnotationProvider *_annotationProvider;
    //    IDEAnalyzerResultsExplorer *_analyzerResultsExplorer;
    //    DVTWeakInterposer *_analyzerResultsScopeBar_dvtWeakInterposer;
    BOOL _hidingAnalyzerExplorer;
    //    IDENoteAnnotationExplorer *_noteAnnotationExplorer;
    //    IDESourceCodeSingleLineBlameProvider *_blameProvider;
    NSPopover *_blameLogPopover;
    //    IDESourceControlLogDetailViewController *_blameDetailController;
    //    IDESingleFileProcessingToolbarController *_singleFileProcessingToolbarController;
    NSView *_emptyView;
    NSView *_contentGenerationBackgroundView;
    NSProgressIndicator *_contentGenerationProgressIndicator;
    NSTimer *_contentGenerationProgressTimer;
    NSOperationQueue *_tokenizeQueue;
    //    DVTDispatchLock *_tokenizeAccessLock;
    unsigned long long _tokenizeGeneration;
    NSTrackingArea *_mouseTracking;
    NSDictionary *_previouslyRestoredStateDictionary;
    struct _NSRange _previousSelectedLineRange;
    unsigned long long _lastFocusedAnnotationIndex;
    struct _NSRange _lastEditedCharRange;
    //    DVTTextDocumentLocation *_continueToHereDocumentLocation;
    //    DVTTextDocumentLocation *_continueToLineDocumentLocation;
    //    DVTWeakInterposer *_hostViewController_dvtWeakInterposer;
    struct {
        unsigned int wantsDidScroll:1;
        unsigned int wantsDidFinishAnimatingScroll:1;
        unsigned int supportsContextMenuCustomization:1;
        unsigned int supportsAnnotationContextCreation:1;
        unsigned int wantsDidLoadAnnotationProviders:1;
        unsigned int reserved:3;
    } _hvcFlags;
    BOOL _trackingMouse;
    BOOL _scheduledInitialSetup;
    BOOL _initialSetupDone;
    BOOL _nodeTypesPrefetchingStarted;
    BOOL _isUninstalling;
}

+ (id)keyPathsForValuesAffectingIsWorkspaceBuilding;
+ (void)revertStateWithDictionary:(id)arg1 withSourceTextView:(id)arg2 withEditorDocument:(id)arg3;
+ (void)commitStateToDictionary:(id)arg1 withSourceTextView:(id)arg2;
+ (long long)version;
+ (void)configureStateSavingObjectPersistenceByName:(id)arg1;
//@property(retain) IDESingleFileProcessingToolbarController *singleFileProcessingToolbarController; // @synthesize singleFileProcessingToolbarController=_singleFileProcessingToolbarController;
@property struct _NSRange lastEditedCharacterRange; // @synthesize lastEditedCharacterRange=_lastEditedCharRange;
                                                    //@property(retain) IDEAnalyzerResultsExplorer *analyzerResultsExplorer; // @synthesize analyzerResultsExplorer=_analyzerResultsExplorer;
@property(retain, nonatomic) DVTSourceExpression *mouseOverExpression; // @synthesize mouseOverExpression=_mouseOverExpression;
                                                                       //@property(retain) IDESourceCodeEditorContainerView *containerView; // @synthesize containerView=_containerView;
                                                                       //@property(retain) DVTLayoutManager *layoutManager; // @synthesize layoutManager=_layoutManager;
@property(retain) DVTSourceTextView *textView; // @synthesize textView=_textView;
@property(retain) NSScrollView *scrollView; // @synthesize scrollView=_scrollView;
- (BOOL)editorDocumentIsCurrentRevision;
- (BOOL)editorIsHostedInComparisonEditor;
- (id)_documentLocationForLineNumber:(long long)arg1;
- (void)_createFileBreakpointAtLocation:(long long)arg1;
- (id)_breakpointManager;
- (long long)_currentOneBasedLineNubmer;
- (id)currentEditorContext;
- (id)documentLocationForOpenQuicklyQuery:(id)arg1;
- (void)openQuicklyScoped:(id)arg1;
- (void)debugLogJumpToDefinitionState:(id)arg1;
- (id)_jumpToDefinitionOfExpression:(id)arg1 fromScreenPoint:(struct CGPoint)arg2 clickCount:(long long)arg3 modifierFlags:(unsigned long long)arg4;
- (void)_cancelHelpNavigationRequest;
- (void)_cancelCurrentNavigationRequest;
- (void)contextMenu_revealInSymbolNavigator:(id)arg1;
- (void)jumpToSelection:(id)arg1;
- (void)jumpToOriginalSourceOfGeneratedFileWithShiftPlusAlternate:(id)arg1;
- (void)jumpToOriginalSourceOfGeneratedFileWithAlternate:(id)arg1;
- (void)jumpToOriginalSourceOfGeneratedFile:(id)arg1;
- (void)jumpToDefinitionWithShiftPlusAlternate:(id)arg1;
- (void)jumpToDefinitionWithAlternate:(id)arg1;
- (void)jumpToDefinition:(id)arg1;
- (void)revealInSymbolNavigator:(id)arg1;
- (unsigned long long)_insertionIndexUnderMouse;
- (id)_documentLocationUnderMouse;
- (id)_calculateContinueToDocumentLocationFromDocumentLocation:(id)arg1;
- (id)_calculateContinueToLineDocumentLocation;
- (id)_calculateContinueToHereDocumentLocation;
- (BOOL)validateMenuItem:(id)arg1;
- (void)menuNeedsUpdate:(id)arg1;
- (void)mouseExited:(id)arg1;
- (void)mouseEntered:(id)arg1;
- (void)mouseMoved:(id)arg1;
- (void)deregisterForMouseEvents;
- (void)registerForMouseEvents;
@property(readonly, nonatomic) DVTSourceLanguageService *languageService;
- (struct CGRect)expressionFrameForExpression:(id)arg1;
- (id)importStringInExpression:(id)arg1;
- (BOOL)isExpressionModuleImport:(id)arg1;
- (BOOL)isExpressionPoundImport:(id)arg1;
- (BOOL)_isExpressionImport:(id)arg1 module:(BOOL)arg2;
- (BOOL)expressionContainsExecutableCode:(id)arg1;
- (BOOL)isExpressionFunctionOrMethodCall:(id)arg1;
- (BOOL)isExpressionInFunctionOrMethodBody:(id)arg1;
- (BOOL)isLocationInFunctionOrMethodBody:(id)arg1;
- (BOOL)isExpressionFunctionOrMethodDefinition:(id)arg1;
- (BOOL)isExpressionInPlainCode:(id)arg1;
- (BOOL)isExpressionWithinComment:(id)arg1;
- (void)symbolsForExpression:(id)arg1 inQueue:(id)arg2 completionBlock:(id)arg3;
@property(readonly, nonatomic) NSString *selectedText;
@property(readonly, nonatomic) struct CGRect currentSelectionFrame;
- (void)_sendDelayedSelectedExpressionDidChangeMessage;
@property(retain, nonatomic) DVTSourceExpression *selectedExpression; // @synthesize selectedExpression=_selectedExpression;
- (void)_invalidateMouseOverExpression;
@property(readonly) DVTSourceExpression *quickHelpExpression;
@property(readonly) DVTSourceExpression *contextMenuExpression;
- (void)_updatedMouseOverExpression;
- (void)_updateSelectedExpression;
- (BOOL)_expression:(id)arg1 representsTheSameLocationAsExpression:(id)arg2;
- (id)_expressionAtCharacterIndex:(unsigned long long)arg1;
- (id)refactoringExpressionUsingContextMenu:(BOOL)arg1;
- (id)selectedTestsAndTestables;
- (id)_testFromModelItem:(id)arg1 fromTests:(id)arg2;
- (void)specialPaste:(id)arg1;
- (id)_specialPasteContext;
- (void)_changeSourceCodeLanguageAction:(id)arg1;
- (void)_useSourceCodeLanguageFromFileDataTypeAction:(id)arg1;
- (void)_askToPromoteToUnicodeSheetDidEnd:(id)arg1 returnCode:(long long)arg2 contextInfo:(void *)arg3;
- (void)_askToPromoteToUnicode;
- (void)_applyPerFileTextSettings;
- (void)textView:(id)arg1 doubleClickedOnCell:(id)arg2 inRect:(struct CGRect)arg3 atIndex:(unsigned long long)arg4;
- (void)textView:(id)arg1 clickedOnCell:(id)arg2 inRect:(struct CGRect)arg3 atIndex:(unsigned long long)arg4;
- (void)contextMenu_toggleIssueShown:(id)arg1;
- (void)toggleIssueShown:(id)arg1;
- (void)_enumerateDiagnosticAnnotationsInSelection:(id)arg1;
- (id)_jumpToAnnotationWithSelectedRange:(struct _NSRange)arg1 fixIt:(BOOL)arg2 backwards:(BOOL)arg3;
- (void)fixAllInScope:(id)arg1;
- (id)fixableDiagnosticAnnotationsInScope;
- (id)_diagnosticAnnotationsInScopeFixableOnly:(BOOL)arg1;
- (id)_diagnosticAnnotationsInRange:(struct _NSRange)arg1 fixableOnly:(BOOL)arg2;
- (void)popoverWillClose:(id)arg1;
- (id)viewWindow;
- (BOOL)detailShouldShowOpenBlameView;
- (void)openBlameView;
- (void)openComparisonView;
- (void)blameSelectedLine:(id)arg1;
- (void)_showDocumentationForSelectedSymbol:(id)arg1;
- (void)showQuickHelp:(id)arg1;
- (void)continueToCurrentLine:(id)arg1;
- (void)continueToHere:(id)arg1;
- (void)toggleInvisibleCharactersShown:(id)arg1;
- (void)toggleBreakpointAtCurrentLine:(id)arg1;
- (void)_stopShowingContentGenerationProgressInidcator;
- (void)_showContentGenerationProgressIndicatorWithDelay:(double)arg1;
- (void)_contentGenerationProgressTimerFired:(id)arg1;
- (void)_hideEmptyView;
- (void)_showEmptyViewWithMessage:(id)arg1;
- (void)_centerViewInSuperView:(id)arg1;
- (void)compileCurrentFile;
- (void)analyzeCurrentFile;
- (void)preprocessCurrentFile;
- (void)assembleCurrentFile;
- (void)_processCurrentFileUsingBuildCommand:(int)arg1;
- (id)_singleFileProcessingFilePath;
- (void)startSingleProcessingModeForURL:(id)arg1;
@property(readonly) BOOL isWorkspaceBuilding;
- (BOOL)canAssembleFile;
- (BOOL)canPreprocessFile;
- (BOOL)canAnalyzeFile;
- (BOOL)canCompileFile;
- (void)stopNoteExplorer;
- (void)startNoteExplorerForItem:(id)arg1;
- (void)showErrorsOnly:(id)arg1;
- (void)showAllIssues:(id)arg1;
- (void)toggleMessageBubbles:(id)arg1;
- (void)hideAnalyzerExplorerAnimate:(BOOL)arg1;
- (void)showAnalyzerExplorerForMessage:(id)arg1 animate:(BOOL)arg2;
- (void)_startPrefetchingNodeTypesInUpDirection:(BOOL)arg1 initialLineRange:(struct _NSRange)arg2 noProgressIterations:(unsigned long long)arg3;
- (void)revertStateWithDictionary:(id)arg1;
- (void)commitStateToDictionary:(id)arg1;
- (void)configureStateSavingObservers;
- (id)_transientStateDictionaryForDocument:(id)arg1;
- (id)_stateDictionariesForDocuments;
- (id)cursorForAltTemporaryLink;
- (void)_textViewDidLoseFirstResponder;
- (BOOL)completingTextViewHandleCancel:(id)arg1;
- (void)textViewDidScroll:(id)arg1;
- (void)textViewDidFinishAnimatingScroll:(id)arg1;
- (id)textView:(id)arg1 menu:(id)arg2 forEvent:(id)arg3 atIndex:(unsigned long long)arg4;
- (void)tokenizableRangesWithRange:(struct _NSRange)arg1 completionBlock:(id)arg2;
- (void)textViewBoundsDidChange:(id)arg1;
- (void)textView:(id)arg1 handleMouseDidExitSidebar:(id)arg2;
- (void)textView:(id)arg1 handleMouseDidMoveOverSidebar:(id)arg2 atLineNumber:(unsigned long long)arg3;
- (void)textView:(id)arg1 handleMouseDownInSidebar:(id)arg2 atLineNumber:(unsigned long long)arg3;
- (id)completingTextView:(id)arg1 documentLocationForWordStartLocation:(unsigned long long)arg2;
- (void)completingTextView:(id)arg1 willPassContextToStrategies:(id)arg2 atWordStartLocation:(unsigned long long)arg3;
- (void)textView:(id)arg1 didClickOnTemporaryLinkAtCharacterIndex:(unsigned long long)arg2 event:(id)arg3 isAltEvent:(BOOL)arg4;
- (void)_doubleClickOnTemporaryHelpLinkTimerExpired;
- (void)_doubleClickOnTemporaryLinkTimerExpired;
- (BOOL)textView:(id)arg1 shouldShowTemporaryLinkForCharacterAtIndex:(unsigned long long)arg2 proposedRange:(struct _NSRange)arg3 effectiveRanges:(id *)arg4;
- (void)textView:(id)arg1 didRemoveAnnotations:(id)arg2;
- (void)textViewDidLoadAnnotationProviders:(id)arg1;
- (id)annotationContextForTextView:(id)arg1;
- (id)syntaxColoringContextForTextView:(id)arg1;
- (BOOL)textView:(id)arg1 shouldChangeTextInRange:(struct _NSRange)arg2 replacementString:(id)arg3;
- (void)setupTextViewContextMenuWithMenu:(id)arg1;
- (void)setupGutterContextMenuWithMenu:(id)arg1;
- (void)textViewDidChangeSelection:(id)arg1;
- (void)textDidChange:(id)arg1;
- (void)removeVisualization:(id)arg1 fadeOut:(BOOL)arg2 completionBlock:(id)arg3;
- (void)addVisualization:(id)arg1 fadeIn:(BOOL)arg2 completionBlock:(id)arg3;
@property(readonly) NSArray *visualizations;
- (id)pathCell:(id)arg1 menuItemForNavigableItem:(id)arg2 defaultMenuItem:(id)arg3;
- (BOOL)pathCell:(id)arg1 shouldInitiallyShowMenuSearch:(id)arg2;
- (BOOL)pathCell:(id)arg1 shouldSeparateDisplayOfChildItemsForItem:(id)arg2;
- (struct _NSRange)selectedRangeForFindBar:(id)arg1;
- (id)startingLocationForFindBar:(id)arg1 findingBackwards:(BOOL)arg2;
- (void)dvtFindBar:(id)arg1 didUpdateCurrentResult:(id)arg2;
- (void)dvtFindBar:(id)arg1 didUpdateResults:(id)arg2;
- (void)didSetupEditor;
- (void)takeFocus;
- (BOOL)canBecomeMainViewController;
- (id)undoManagerForTextView:(id)arg1;
- (void)viewWillUninstall;
- (void)viewDidInstall;
- (void)contentViewDidCompleteLayout;
- (void)_doInitialSetup;
- (void)_liveIssuesPreferencesUpdatedInvalidateDiagnosticController:(BOOL)arg1;
- (void)_blueprintDidChangeForSourceCodeEditor:(id)arg1;
- (void)_endObservingDiagnosticItems;
- (void)_startObservingDiagnosticItems;
- (void)primitiveInvalidate;
- (void)selectDocumentLocations:(id)arg1 highlightSelection:(BOOL)arg2;
- (void)selectAndHighlightDocumentLocations:(id)arg1;
- (void)selectDocumentLocations:(id)arg1;
- (void)navigateToAnnotationWithRepresentedObject:(id)arg1 wantsIndicatorAnimation:(BOOL)arg2 exploreAnnotationRepresentedObject:(id)arg3;
- (id)currentSelectedDocumentLocations;
- (id)_currentSelectedLandmarkItem;
- (void)setCurrentSelectedItems:(id)arg1;
- (id)currentSelectedItems;
- (void)_refreshCurrentSelectedItemsIfNeeded;
- (BOOL)_isCurrentSelectedItemsValid;
//@property __weak IDEViewController<IDESourceEditorViewControllerHost> *hostViewController;
@property(readonly) IDESourceCodeEditorAnnotationProvider *annotationProvider; // @synthesize annotationProvider=_annotationProvider;
- (id)mainScrollView;
@property(readonly) IDESourceCodeDocument *sourceCodeDocument;
- (void)loadView;
- (id)initWithNibName:(id)arg1 bundle:(id)arg2 document:(id)arg3;
@property __weak DVTScopeBarController *analyzerResultsScopeBar;

// Remaining properties
@property(retain) DVTStackBacktrace *creationBacktrace;
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) unsigned long long hash;
@property(readonly) DVTStackBacktrace *invalidationBacktrace;
@property(readonly) DVTSDK *sdk;
@property(readonly) Class superclass;
@property(readonly, nonatomic, getter=isValid) BOOL valid;

@end

@class DVTDispatchLock, DVTExtension, DVTFileDataType, DVTFilePath, DVTMapTable, DVTNotificationToken, DVTStackBacktrace, DVTUndoManager, NSDictionary, NSMutableArray, NSMutableSet, NSSet, NSString, NSURL;

@interface IDEEditorDocument : NSDocument
{
    DVTDispatchLock *_editorDocumentLock;
    DVTExtension *_extension;
    DVTFileDataType *_ide_hintedFileDataType;
    DVTFilePath *_filePath;
    DVTFilePath *autosavedContentsFilePath;
    DVTMapTable *_readOnlyClientsForRegistrationBacktrace;
    DVTNotificationToken *_willRedoChangeNotificationToken;
    DVTNotificationToken *_willUndoChangeNotificationToken;
    DVTStackBacktrace *_addedToDocumentControllerBacktrace;
    DVTStackBacktrace *_savePresentedItemChanges;
    DVTStackBacktrace *_autosaveWithImplicitCancellabilityCallerBacktrace;
    DVTStackBacktrace *_beginUnlockingBacktrace;
    DVTStackBacktrace *_canCloseDocumentCallPriorToClosingDocumentStackBacktrace;
    DVTStackBacktrace *_continueActivityCallerBacktrace;
    DVTStackBacktrace *_continueAsynchronousWorkOnMainThreadCallerBacktrace;
    DVTStackBacktrace *_continueFileAccessCallerBacktrace;
    DVTStackBacktrace *_creationBacktrace;
    DVTStackBacktrace *_firstPerformActivityMessageBacktrace;
    DVTStackBacktrace *_invalidationBacktrace;
    DVTStackBacktrace *_lastUndoChangeNotificationBacktrace;
    DVTUndoManager *_dvtUndoManager;
    int _readOnlyStatus;
    NSDictionary *_willCloseNotificationUserInfo;
    NSMutableArray *_pendingChanges;
    NSMutableSet *_documentEditors;
    NSURL *_ide_representedURL;
    //    id <DVTCancellable> _closeAfterDelayToken;
    id _filePresenterWriter;
    BOOL _cachedHasRecentChanges;
    BOOL _didDisableAutomaticTermination;
    BOOL _ide_isTemporaryDocument;
    BOOL _inSetUndoManager;
    BOOL _inWriteSafelyToURL;
    BOOL _isAttemptingToRespondToSaveDocumentAction;
    BOOL _isClosing;
    BOOL _isClosingForRevert;
    BOOL _isInvalidated;
    BOOL _isRespondingToFSChanges;
    BOOL _isSafeToCallClose;
    BOOL _isUndoingAfterFailureToUnlockDocument;
    BOOL _isWritingToDisk;
    BOOL _shouldAssertIfNotInvalidatedBeforeDealloc;
    BOOL _trackFileSystemChanges;
    BOOL _wholeDocumentChanged;
    NSSet *_readOnlyClients;
    DVTFilePath *_autosavedContentsFilePath;
}

+ (BOOL)_presentsVersionsUserInterface;
+ (BOOL)autosavesInPlace;
+ (id)editedFileContents;
+ (id)keyPathsForValuesAffectingIde_displayName;
+ (id)readableTypes;
+ (BOOL)_validateDocumentExtension:(id)arg1;
+ (BOOL)_shouldShowUtilititesAreaAtLoadForSimpleFilesFocusedWorkspace;
+ (BOOL)shouldTrackFileSystemChanges;
+ (BOOL)shouldUnlockFileURLBeforeMakingChanges;
+ (void)initialize;
@property(retain, nonatomic) DVTExtension *extension; // @synthesize extension=_extension;
@property(retain) DVTStackBacktrace *creationBacktrace; // @synthesize creationBacktrace=_creationBacktrace;
@property(retain) DVTFilePath *autosavedContentsFilePath; // @synthesize autosavedContentsFilePath=_autosavedContentsFilePath;
@property(retain) DVTFilePath *filePath; // @synthesize filePath=_filePath;
@property int readOnlyStatus; // @synthesize readOnlyStatus=_readOnlyStatus;
@property(readonly) DVTStackBacktrace *invalidationBacktrace; // @synthesize invalidationBacktrace=_invalidationBacktrace;
@property BOOL trackFileSystemChanges; // @synthesize trackFileSystemChanges=_trackFileSystemChanges;
- (void)restoreStateWithCoder:(id)arg1;
- (void)encodeRestorableStateWithCoder:(id)arg1;
- (void)restoreDocumentWindowWithIdentifier:(id)arg1 state:(id)arg2 completionHandler:(id)arg3;
- (void)unregisterReadOnlyClient:(id)arg1;
- (void)registerReadOnlyClient:(id)arg1;
@property(readonly) NSSet *readOnlyClients; // @synthesize readOnlyClients=_readOnlyClients;
- (BOOL)makeWritableWithError:(id *)arg1;
@property(readonly) NSURL *readOnlyItemURL;
- (void)_updateReadOnlyStatus;
- (void)exportDocument:(id)arg1;
@property(readonly) BOOL canExportDocument;
- (void)duplicateDocument:(id)arg1;
- (void)revertDocumentToSaved:(id)arg1;
- (BOOL)_checkAutosavingPossibilityAndReturnError:(id *)arg1;
- (BOOL)checkAutosavingSafetyAndReturnError:(id *)arg1;
- (BOOL)editingShouldAutomaticallyDuplicate;
- (id)duplicateAndReturnError:(id *)arg1;
- (id)printOperationWithSettings:(id)arg1 error:(id *)arg2;
- (BOOL)readFromData:(id)arg1 ofType:(id)arg2 error:(id *)arg3;
- (id)dataOfType:(id)arg1 error:(id *)arg2;
- (void)presentedItemDidChange;
- (void)presentedItemDidMoveToURL:(id)arg1;
- (BOOL)canRevert;
- (id)editedContents;
- (id)diffDataSource;
- (id)updatedLocationFromLocation:(id)arg1 toTimestamp:(double)arg2;
- (id)emptyPrivateCopy;
- (id)privateCopy;
- (void)updateChangedLocation:(id)arg1;
- (void)_sendOutDocumentUpdateLocation;
- (void)updateChangeCountWithToken:(id)arg1 forSaveOperation:(unsigned long long)arg2;
- (void)updateChangeCount:(unsigned long long)arg1;
- (void)ide_didFixupChangeCountWithWasEdited:(BOOL)arg1 didHaveEditsSinceLastUserInitiatedSave:(BOOL)arg2 changeString:(id)arg3;
- (BOOL)dvt_hasBeenEditedSinceLastUserInitiatedSave;
- (BOOL)hasBeenEditedSinceLastUserInitiatedSave;
- (void)ide_revertDocumentToSaved:(id)arg1;
- (void)ide_moveDocumentTo:(id)arg1;
- (void)ide_renameDocument:(id)arg1;
- (void)ide_saveDocumentAs:(id)arg1;
- (void)ide_duplicateDocument:(id)arg1;
- (void)ide_saveDocument:(id)arg1;
- (BOOL)validateUserInterfaceItem:(id)arg1;
@property(readonly) BOOL canSaveAs;
@property(readonly) BOOL canSave;
- (BOOL)isClosingForRevert;
- (void)didExternallyRelocateFileContent;
- (void)willExternallyRelocateFileContent;
- (void)closeToRevert;
@property(readonly, getter=isClosed) BOOL closed;
- (void)close;
- (BOOL)_isClosing;
- (void)closePrivateDocumentSynchronously;
- (void)tryCloseAsynchronouslyWithCompletionBlock:(id)arg1;
- (void)_tryCloseAsynchronouslyToRevert:(BOOL)arg1 withCompletionBlock:(id)arg2;
- (void)_tryCloseAsynchronouslyToRevert:(BOOL)arg1 promptForUnsavedChanges:(BOOL)arg2 withCompletionBlock:(id)arg3;
- (void)_canCloseAsynchronouslyToRevert:(BOOL)arg1 promptForUnsavedChanges:(BOOL)arg2 withCompletionBlock:(id)arg3;
- (void)performActivityWithSynchronousWaiting:(BOOL)arg1 usingBlock:(id)arg2;
- (void)_didAddToDocumentController;
- (void)canCloseDocumentWithDelegate:(id)arg1 shouldCloseSelector:(SEL)arg2 contextInfo:(void *)arg3;
- (void)ide_editorDocument:(id)arg1 shouldClose:(BOOL)arg2 contextInfo:(void *)arg3;
@property(readonly) NSString *messageForIsValidAssertion;
- (void)editorDocumentDidClose;
- (void)editorDocumentWillClose;
- (void)saveDocumentAs:(id)arg1;
- (void)saveDocument:(id)arg1;
- (id)initForURL:(id)arg1 withContentsOfURL:(id)arg2 ofType:(id)arg3 error:(id *)arg4;
- (id)initWithContentsOfURL:(id)arg1 ofType:(id)arg2 error:(id *)arg3;
- (id)initWithType:(id)arg1 error:(id *)arg2;
- (void)_handleDocumentFileChanges:(id)arg1;
- (id)windowForSheet;
- (BOOL)_windowForSheet:(id *)arg1 workspaceForSheet:(id *)arg2 editor:(id *)arg3;
@property(readonly, copy) NSString *ide_displayName;
- (void)setAutosavedContentsFileURL:(id)arg1;
- (id)autosavedContentsFileURL;
- (void)setFileURL:(id)arg1;
- (id)fileURL;
- (void)relinquishPresentedItemToWriter:(id)arg1;
- (void)_respondToFileChangeOnDiskWithFilePath:(id)arg1;
- (void)saveForOperation:(unsigned long long)arg1 withCompletionHandler:(id)arg2;
- (void)saveToURL:(id)arg1 ofType:(id)arg2 forSaveOperation:(unsigned long long)arg3 completionHandler:(id)arg4;
- (void)ide_finishSaving:(BOOL)arg1 forSaveOperation:(unsigned long long)arg2 previousPath:(id)arg3;
- (BOOL)writeSafelyToURL:(id)arg1 ofType:(id)arg2 forSaveOperation:(unsigned long long)arg3 error:(id *)arg4;
- (id)fileNameExtensionForType:(id)arg1 saveOperation:(unsigned long long)arg2;
- (BOOL)revertToContentsOfURL:(id)arg1 ofType:(id)arg2 error:(id *)arg3;
- (void)unregisterDocumentEditor:(id)arg1;
- (void)registerDocumentEditor:(id)arg1;
- (id)_documentEditors;
- (void)undoManagerWillModifyItself:(id)arg1;
- (void)setHasUndoManager:(BOOL)arg1;
@property(retain) DVTUndoManager *undoManager;
- (void)ide_setUndoManager:(id)arg1;
- (void)teardownUndoManager:(id)arg1;
- (void)setupUndoManager:(id)arg1;
- (id)newUndoManager;
- (void)_startUnlockIfNeededForWorkspace:(id)arg1 window:(id)arg2 completionBlock:(id)arg3;
- (void)_unlockIfNeededCompletionBlock:(id)arg1;
- (id)init;
- (void)_changeWasRedone:(id)arg1;
- (void)_changeWasUndone:(id)arg1;
- (void)_changeWasDone:(id)arg1;
- (void)savePresentedItemChangesWithCompletionHandler:(id)arg1;
- (void)autosaveWithImplicitCancellability:(BOOL)arg1 completionHandler:(id)arg2;
- (void)continueAsynchronousWorkOnMainThreadUsingBlock:(id)arg1;
- (void)continueActivityUsingBlock:(id)arg1;
- (void)continueFileAccessUsingBlock:(id)arg1;
- (id)applicableInspectorCategoriesGivenSuggestion:(id)arg1;
- (void)setSdefSupport_displayName:(id)arg1;
- (id)sdefSupport_displayName;
@property(retain) DVTFileDataType *ide_hintedFileDataType;
@property(copy) NSURL *ide_representedURL;
@property(readonly) BOOL ide_isTextRepresentation;
- (void)convertToDocumentAtFilePath:(id)arg1 forFileDataType:(id)arg2 completionBlock:(id)arg3;
@property BOOL ide_isTemporaryDocument;

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) unsigned long long hash;
@property(readonly) Class superclass;

@end

extern NSString *IDEEditorDocumentDidChangeNotification;

@class DVTDelayedInvocation, DVTFileDataType, DVTGeneratedContentProvider, DVTNotificationToken, DVTObservingToken, DVTPerformanceMetric, DVTSourceCodeLanguage, DVTTextStorage, IDEDiagnosticController, IDEGeneratedContentStatusContext, IDESourceCodeAdjustNodeTypesRequest, NSArray, NSDictionary, NSMutableArray, NSMutableSet, NSString, NSURL;

@interface IDESourceCodeDocument : IDEEditorDocument </* IDEDiagnosticControllerDataSource, */ IDEDocumentStructureProviding /*, DVTTextFindable, DVTTextReplacable, DVTTextStorageDelegate, IDEObjectiveCSourceCodeGenerationDestination, DVTSourceLandmarkProvider, DVTSourceTextViewDelegate */>
{
    DVTTextStorage *_textStorage;
    DVTSourceCodeLanguage *_language;
    IDEDiagnosticController *_diagnosticController;
    NSArray *_sourceLandmarks;
    NSMutableSet *_pendingAdjustNodeTypeRequests;
    IDESourceCodeAdjustNodeTypesRequest *_lastAdjustNodeTypesRequest;
    struct _NSRange _prefetchedNodeTypesLineRange;
    DVTGeneratedContentProvider *_generatedContentProvider;
    IDEGeneratedContentStatusContext *_generatedContentStatusContext;
    BOOL _generatesContent;
    DVTObservingToken *_generatedContentProviderDisplayNameObserver;
    DVTNotificationToken *_indexDidIndexWorkspaceObserver;
    DVTNotificationToken *_indexDidChangeObserver;
    unsigned long long _lineEndings;
    unsigned long long _textEncoding;
    BOOL _usesLanguageFromFileDataType;
    BOOL _languageSupportsSymbolColoring;
    BOOL _setUpPrintInfoDefaults;
    BOOL _isUnicodeWithBOM;
    BOOL _isUnicodeBE;
    BOOL _droppedRecomputableState;
    DVTDelayedInvocation *_dropRecomputableState;
    DVTObservingToken *_firstEditorWorkspaceToken;
    NSMutableArray *_registeredEditors;
    BOOL _notifiesWhenClosing;
    NSDictionary *__firstEditorWorkspaceBuildSettings;
}

+ (id)keyPathsForValuesAffecting_firstEditorWorkspace;
+ (id)keyPathsForValuesAffectingSourceLanguageServiceContext;
+ (id)syntaxColoringPrefetchLogAspect;
+ (id)topLevelStructureLogAspect;
+ (void)initialize;
@property(copy) NSDictionary *_firstEditorWorkspaceBuildSettings; // @synthesize _firstEditorWorkspaceBuildSettings=__firstEditorWorkspaceBuildSettings;
@property BOOL notifiesWhenClosing; // @synthesize notifiesWhenClosing=_notifiesWhenClosing;
@property(retain) IDEGeneratedContentStatusContext *generatedContentStatusContext; // @synthesize generatedContentStatusContext=_generatedContentStatusContext;
@property BOOL generatesContent; // @synthesize generatesContent=_generatesContent;
@property(readonly) struct _NSRange prefetchedNodeTypesLineRange; // @synthesize prefetchedNodeTypesLineRange=_prefetchedNodeTypesLineRange;
@property(nonatomic) unsigned long long lineEndings; // @synthesize lineEndings=_lineEndings;
@property unsigned long long textEncoding; // @synthesize textEncoding=_textEncoding;
@property(nonatomic) BOOL usesLanguageFromFileDataType; // @synthesize usesLanguageFromFileDataType=_usesLanguageFromFileDataType;
@property(retain, nonatomic) DVTSourceCodeLanguage *language; // @synthesize language=_language;
@property(readonly) DVTTextStorage *textStorage; // @synthesize textStorage=_textStorage;
- (void)_delayedDropRecomputableState:(id)arg1;
- (void)_restoreRecomputableState;
- (void)_dropRecomputableState;
- (void)_documentMovingToForeground;
- (void)_documentMovingToBackground:(BOOL)arg1;
- (void)registerDocumentEditor:(id)arg1;
- (void)unregisterDocumentEditor:(id)arg1;
- (id)_firstEditorWorkspace;
- (id)_firstEditor;
- (id)sourceCodeGenerator:(id)arg1 commitInsertionOfSourceCodeForCompositeResult:(id)arg2 error:(id *)arg3;
- (id)sourceCodeGenerator:(id)arg1 prepareToAddObjectiveCAtSynthesizeWithName:(id)arg2 inClassNamed:(id)arg3 options:(id)arg4 error:(id *)arg5;
- (id)sourceCodeGenerator:(id)arg1 prepareToAddObjectiveCPropertyDeclarationWithName:(id)arg2 type:(id)arg3 inClassNamed:(id)arg4 options:(id)arg5 error:(id *)arg6;
- (id)sourceCodeGenerator:(id)arg1 prepareToAddObjectiveCPropertyReleaseForTeardownWithName:(id)arg2 type:(id)arg3 inClassNamed:(id)arg4 options:(id)arg5 error:(id *)arg6;
- (id)sourceCodeGenerator:(id)arg1 prepareToAddObjectiveCInstanceVariableReleaseForTeardownWithName:(id)arg2 inClassNamed:(id)arg3 options:(id)arg4 error:(id *)arg5;
- (id)_primitiveAddObjectiveCReleaseForTeardownMethodWithSourceCodeGenerator:(id)arg1 withReleaseCallCode:(id)arg2 inClassNamed:(id)arg3 options:(id)arg4 error:(id *)arg5;
- (id)sourceCodeGenerator:(id)arg1 prepareToAddObjectiveCInstanceVariableDeclarationWithName:(id)arg2 type:(id)arg3 inClassNamed:(id)arg4 options:(id)arg5 error:(id *)arg6;
- (id)sourceCodeGenerator:(id)arg1 prepareToAddObjectiveCClassMethodDefinitionWithName:(id)arg2 inClassNamed:(id)arg3 options:(id)arg4 error:(id *)arg5;
- (id)sourceCodeGenerator:(id)arg1 prepareToAddObjectiveCClassMethodDeclarationWithName:(id)arg2 inClassNamed:(id)arg3 options:(id)arg4 error:(id *)arg5;
- (id)sourceCodeGenerator:(id)arg1 prepareToAddObjectiveCInstanceMethodDefinitionWithName:(id)arg2 inClassNamed:(id)arg3 options:(id)arg4 error:(id *)arg5;
- (id)_primitiveAppendObjectiveCSourceCode:(id)arg1 afterItem:(id)arg2 prependNewLine:(BOOL)arg3;
- (id)sourceCodeGenerator:(id)arg1 prepareToAddObjectiveCInstanceMethodDeclarationWithName:(id)arg2 inClassNamed:(id)arg3 options:(id)arg4 error:(id *)arg5;
- (id)_primitiveAddObjectiveCMethodSourceCode:(id)arg1 toClassItem:(id)arg2 withOptions:(id)arg3 error:(id *)arg4;
- (id)_primitiveAddObjectiveCSourceCode:(id)arg1 toClassItem:(id)arg2 withOptions:(id)arg3 insertAdditionalNewlineWhenInsertingWithAfterBeforeHint:(BOOL)arg4 insertAtEndWhenInsertingWithoutHint:(BOOL)arg5 insertAfterObjCBlockWhenInsertingAtBeginning:(BOOL)arg6 ignoreHintItemsConformingToSpecifications:(id)arg7 onlyConsiderItemsConformingToSpecifications:(id)arg8 error:(id *)arg9;
- (id)_insertObjectiveCSourceCode:(id)arg1 inTeardownMethodForClassNamed:(id)arg2 options:(id)arg3 error:(id *)arg4;
- (id)_teardownMethodNameForSourceCodeGeneratorWithOptions:(id)arg1;
- (BOOL)_hasObjCMethodImplementationForName:(id)arg1 forClassNamed:(id)arg2;
- (id)_objCMethodImplementationItemForName:(id)arg1 inClassItem:(id)arg2;
- (id)_insertObjCSourceCode:(id)arg1 inTopLevelOfClassItem:(id)arg2 withInsertAfterHint:(id)arg3 andInsertBeforeHint:(id)arg4 ignoreHintItemsConformingToSpecifications:(id)arg5 onlyConsiderItemsConformingToSpecifications:(id)arg6 insertAdditionalNewline:(BOOL)arg7 insertAtEndWhenInsertingWithoutHint:(BOOL)arg8 insertAfterObjCBlockWhenInsertingAtBeginning:(BOOL)arg9;
- (id)_insertObjCSourceCode:(id)arg1 inContainingSourceModelItem:(id)arg2 withInsertAfterHint:(id)arg3 andInsertBeforeHint:(id)arg4 ignoreHintItemsConformingToSpecifications:(id)arg5 onlyConsiderItemsConformingToSpecifications:(id)arg6 insertAdditionalNewline:(BOOL)arg7 fallbackInsertionBlock:(id)arg8;
- (long long)_insertionHintMatchPriorityForObjCSourceModelItem:(id)arg1 givenInsertionHintItemName:(id)arg2 andLanguageSpecification:(id)arg3 ignoreItemsConformingToSpecifications:(id)arg4 onlyConsiderItemsConformingToSpecifications:(id)arg5;
- (id)_insertObjCSourceCode:(id)arg1 inTopLevelOfClassItem:(id)arg2 asCloseAsPossibleToLineNumber:(unsigned long long)arg3 error:(id *)arg4;
- (id)_insertObjCSourceCode:(id)arg1 inContainingSourceModelItem:(id)arg2 asCloseAsPossibleToLineNumber:(unsigned long long)arg3 firstPossibleItemToInsertBefore:(id)arg4 error:(id *)arg5;
- (id)_insertionHintForObjCSourceModelItem:(id)arg1;
- (id)_firstObjCSourceModelItemToInsertBeforeInInstanceVariableBlock:(id)arg1;
- (id)_firstTopLevelObjCInterfaceSourceModelItemToInsertBeforeInClassItem:(id)arg1;
- (id)_insertSourceCode:(id)arg1 atBeginningOfClassSourceModelItem:(id)arg2 insertOnNextLine:(BOOL)arg3 insertAfterObjCBlock:(BOOL)arg4;
- (id)_insertSourceCode:(id)arg1 atEndOfClassSourceModelItem:(id)arg2 insertOnNextLine:(BOOL)arg3;
- (id)_insertSourceCode:(id)arg1 atEndOfContainingSourceModelItem:(id)arg2 insertOnNextLine:(BOOL)arg3 beforeItemMatchingPredicateBlock:(id)arg4;
- (id)_insertSourceCode:(id)arg1 atBeginningOfContainingSourceModelItem:(id)arg2 insertOnNextLine:(BOOL)arg3 afterItemMatchingPredicateBlock:(id)arg4;
- (id)_primitiveInsertSourceCode:(id)arg1 atBeginning:(BOOL)arg2 ofContainingSourceModelItem:(id)arg3 insertOnNextLine:(BOOL)arg4 afterOrBeforeItemMatchingPredicateBlock:(id)arg5;
- (id)textDocumentLocationForInsertingSourceCode:(id)arg1 atLocation:(unsigned long long)arg2;
- (id)_instanceVariableDeclarationBlockItemForClassItem:(id)arg1;
- (id)_objCCategoryImplementationClassModelItemForClassNamed:(id)arg1 categoryName:(id)arg2 error:(id *)arg3;
- (id)_objCCategoryInterfaceClassModelItemForClassNamed:(id)arg1 categoryName:(id)arg2 options:(id)arg3 error:(id *)arg4;
- (id)_objCImplementationClassModelItemForClassNamed:(id)arg1 error:(id *)arg2;
- (id)_objCInterfaceClassModelItemForClassNamed:(id)arg1 error:(id *)arg2;
- (id)_classModelItemForClassNamed:(id)arg1 withConditionBlock:(id)arg2;
- (id)errorForNotFindingClassItemForClassNamed:(id)arg1 humanReadableClassItemType:(id)arg2;
- (id)supportedSourceCodeLanguagesForSourceCodeGeneration;
- (long long)defaultPropertyAccessControl;
- (id)emptyPrivateCopy;
- (id)privateCopy;
- (id)diffDataSource;
- (id)textViewWillReturnPrintJobTitle:(id)arg1;
- (id)printOperationWithSettings:(id)arg1 error:(id *)arg2;
- (void)sourceLanguageServiceAvailabilityNotification:(BOOL)arg1 message:(id)arg2;
- (BOOL)textStorageShouldAllowEditing:(id)arg1;
- (void)textStorageDidUpdateSourceLandmarks:(id)arg1;
- (void)textStorageDidProcessEditing:(id)arg1;
- (void)updateChangeCount:(unsigned long long)arg1;
- (BOOL)replaceTextWithContentsOfURL:(id)arg1 error:(id *)arg2;
- (BOOL)replaceFindResults:(id)arg1 inSelection:(struct _NSRange)arg2 withString:(id)arg3 withError:(id *)arg4;
- (BOOL)replaceFindResults:(id)arg1 withString:(id)arg2 withError:(id *)arg3;
- (BOOL)replaceFindResults:(id)arg1 withString:(id)arg2 inSelection:(struct _NSRange)arg3 withError:(id *)arg4;
- (id)findStringMatchingDescriptor:(id)arg1 backwards:(BOOL)arg2 from:(id)arg3 to:(id)arg4;
- (id)documentLocationFromCharacterRange:(struct _NSRange)arg1;
- (struct _NSRange)characterRangeFromDocumentLocation:(id)arg1;
- (id)updatedLocationFromLocation:(id)arg1 toTimestamp:(double)arg2;
- (id)indexCompatibleLocationFromLocation:(id)arg1;
- (id)editorCompatibleLocationFromLocation:(id)arg1;
- (void)prefetchNodeTypesExtraLines:(unsigned long long)arg1 upDirection:(BOOL)arg2 withContext:(id)arg3;
- (void)initialPrefetchNodeTypesForLineRange:(struct _NSRange)arg1 withContext:(id)arg2;
- (void)_prefetchNodeTypesForLineRange:(struct _NSRange)arg1 withContext:(id)arg2;
- (long long)nodeTypeForItem:(id)arg1 withContext:(id)arg2;
- (void)_adjustNodeTypeForIdentifierItem:(id)arg1 withContext:(id)arg2;
- (void)editorDocumentWillClose;
- (id)dataOfType:(id)arg1 error:(id *)arg2;
- (BOOL)writeToURL:(id)arg1 ofType:(id)arg2 error:(id *)arg3;
- (BOOL)readFromData:(id)arg1 ofType:(id)arg2 error:(id *)arg3;
- (BOOL)readFromURL:(id)arg1 ofType:(id)arg2 error:(id *)arg3;
- (void)_configureDocumentReadFromURL:(id)arg1 orData:(id)arg2 ofType:(id)arg3 usedEncoding:(unsigned long long)arg4 preferredLineEndings:(unsigned long long)arg5 readOutAttributes:(id)arg6;
- (id)_readOptionsDictionaryForURL:(id)arg1 preferredEncoding:(unsigned long long)arg2 inOutData:(id *)arg3;
- (unsigned long long)_lineEndingUsedInString:(id)arg1;
- (BOOL)canSaveAs;
- (BOOL)canSave;
@property(readonly) DVTPerformanceMetric *openingPerformanceMetric;
- (id)editedContents;
@property(readonly, copy) NSString *description;
- (id)displayName;
@property(readonly) NSArray *knownFileReferences;
- (struct _NSRange)lineRangeOfSourceLandmark:(id)arg1;
- (id)sourceLandmarkItemAtLineNumber:(unsigned long long)arg1;
- (id)sourceLandmarkItemAtCharacterIndex:(unsigned long long)arg1;
@property(readonly) NSArray *ideTopLevelStructureObjects;
- (void)invalidateAndDisableDiagnosticController;
- (void)invalidateDiagnosticController;
@property(retain) IDEDiagnosticController *diagnosticController; // @synthesize diagnosticController=_diagnosticController;
- (id)printInfo;
- (void)setTextEncoding:(unsigned long long)arg1 convertContents:(BOOL)arg2;
@property(readonly, nonatomic) NSDictionary *sourceLanguageServiceContext;
@property(readonly) DVTFileDataType *fileDataType;
- (id)init;
- (void)setSdefSupport_text:(id)arg1;
- (id)sdefSupport_text;
- (void)setSdefSupport_selection:(id)arg1;
- (id)sdefSupport_selection;
- (void)setSdefSupport_selectedParagraphRange:(id)arg1;
- (id)sdefSupport_selectedParagraphRange;
- (void)setSdefSupport_selectedCharacterRange:(id)arg1;
- (id)sdefSupport_selectedCharacterRange;
- (void)setSdefSupport_notifiesWhenClosing:(BOOL)arg1;
- (BOOL)sdefSupport_notifiesWhenClosing;
- (void)setSdefSupport_contents:(id)arg1;
- (id)sdefSupport_contents;
- (void)setSdefSupport_editorSettings:(id)arg1;
- (id)sdefSupport_editorSettings;
- (id)objectSpecifier;

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly) NSURL *fileURL;
@property unsigned long long supportedMatchingOptions;

@end

