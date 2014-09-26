//
//  CMDTextEditor.h
//  CommandEdit
//
//  Created by Kolin Krewinkel on 9/25/14.
//  Copyright (c) 2014 Kolin Krewinkel. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "DVTInterfaces.h"

@interface CMDTextEditor : NSView

- (CGSize)sizeThatFits:(CGSize)size;
- (instancetype)initWithTextStorage:(DVTTextStorage *)textStorage;

@property (nonatomic) DVTTextStorage *textStorage;

@end
