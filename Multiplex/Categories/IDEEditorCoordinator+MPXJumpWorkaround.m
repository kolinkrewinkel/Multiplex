//
//  IDEEditorCoordinator+MPXJumpWorkaround.m
//  Multiplex
//
//  Created by Kolin Krewinkel on 10/10/15.
//  Copyright © 2015 Kolin Krewinkel. All rights reserved.
//

@import JRSwizzle;

#import "IDEEditorCoordinator+MPXJumpWorkaround.h"

@implementation IDEEditorCoordinator (MPXJumpWorkaround)

+ (void)load
{
    [self jr_swizzleClassMethod:@selector(_openEditorOpenSpecifier:forEditor:eventBehavior:)
                withClassMethod:@selector(mpx_openEditorOpenSpecifier:forEditor:eventBehavior:)
                          error:nil];
}

+ (void)mpx_openEditorOpenSpecifier:(id)arg1 forEditor:(id)arg2 eventBehavior:(int)arg3
{
    [self mpx_openEditorOpenSpecifier:arg1 forEditor:arg2 eventBehavior:2];
}

@end
