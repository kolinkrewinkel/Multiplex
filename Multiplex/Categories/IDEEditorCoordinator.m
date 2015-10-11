//
//  IDEEditorCoordinator.m
//  Multiplex
//
//  Created by Kolin Krewinkel on 10/10/15.
//  Copyright © 2015 Kolin Krewinkel. All rights reserved.
//

@import JRSwizzle;

#import "IDEEditorCoordinator.h"

@implementation IDEEditorCoordinator (MPXJumpSwizzle)

- (void)mpx_openEditorOpenSpecifier:(id)arg1 forEditor:(id)arg2 eventBehavior:(id)arg3
{
    
}

+ (void)load
{
    NSError *error;
    [self jr_swizzleMethod:NSSelectorFromString(@"_openEditorOpenSpecifier:forEditor:eventBehavior:")
                withMethod:@selector(mpx_openEditorOpenSpecifier:forEditor:eventBehavior:)
                     error:&error];
    
    NSLog(@"%@", error);
}

@end
