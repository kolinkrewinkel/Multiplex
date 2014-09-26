//
//  CMDEditorController.h
//  CommandEdit
//
//  Created by Kolin Krewinkel on 9/25/14.
//  Copyright (c) 2014 Kolin Krewinkel. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class IDESourceCodeDocument;
@interface CMDEditorController : NSView

- (instancetype)initWithFrame:(NSRect)frameRect document:(IDESourceCodeDocument *)document;

@end
