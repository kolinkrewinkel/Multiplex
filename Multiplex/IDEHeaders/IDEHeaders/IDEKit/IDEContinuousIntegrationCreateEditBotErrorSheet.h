//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "CDStructures.h"
#import "DVTViewController-Protocol.h"

@class NSArray, NSTextView;

@interface IDEContinuousIntegrationCreateEditBotErrorSheet : DVTViewController
{
    NSArray *_validationErrors;
    NSTextView *_textView;
}

@property NSTextView *textView; // @synthesize textView=_textView;
@property(copy, nonatomic) NSArray *validationErrors; // @synthesize validationErrors=_validationErrors;
- (void)viewDidLoad;

@end

