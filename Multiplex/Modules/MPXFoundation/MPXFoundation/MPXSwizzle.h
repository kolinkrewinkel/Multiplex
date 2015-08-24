//
//  MPXSwizzle.h
//  Multiplex
//
//  Created by Kolin Krewinkel on 3/9/14.
//  Copyright (c) 2014 Kolin Krewinkel. All rights reserved.
//

#import <objc/runtime.h>

@import Foundation;

/**
 * Replaces the method provided and returns the invocation for clients to call back to the original implementaiton.
 *
 * @warning Asserts that the original class exists.
 * @return The invocation for the the original implementation.
 */
NSInvocation *MPXSwizzle(Class originalClass, SEL originalSelector, Class newClass, SEL newSelector, BOOL classMethod);

