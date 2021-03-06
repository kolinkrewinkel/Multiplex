//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "CDStructures.h"
#import <IDEFoundation/IDELocalizationWorkContext.h>

#import "IDELocalizationWorkProvider-Protocol.h"

@class DVTFilePath, DVTLocale, IDEContainer<IDELocalizedContainer>, IDEGroup<IDELocalizedGroup>, NSDictionary;

@interface IDELocalizationWorkWriteStrings : IDELocalizationWorkContext <IDELocalizationWorkProvider>
{
    BOOL _createdNewSubitem;
    NSDictionary *_strings;
    NSDictionary *_comments;
    IDEContainer *_container;
    IDEGroup *_group;
    DVTLocale *_language;
    DVTFilePath *_path;
}

@property(retain) DVTFilePath *path; // @synthesize path=_path;
@property BOOL createdNewSubitem; // @synthesize createdNewSubitem=_createdNewSubitem;
@property(retain) DVTLocale *language; // @synthesize language=_language;
@property(retain) IDEGroup *group; // @synthesize group=_group;
@property(retain) IDEContainer *container; // @synthesize container=_container;
@property(retain) NSDictionary *comments; // @synthesize comments=_comments;
@property(retain) NSDictionary *strings; // @synthesize strings=_strings;
- (id)work;

@end

