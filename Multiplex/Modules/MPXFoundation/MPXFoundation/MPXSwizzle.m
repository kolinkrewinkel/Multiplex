//
//  MPXSwizzle.c
//  Multiplex
//
//  Created by Kolin Krewinkel on 3/9/14.
//  Copyright (c) 2014 Kolin Krewinkel. All rights reserved.
//

#import "MPXSwizzle.h"

NSInvocation *MPXSwizzle(Class originalClass, SEL originalSelector, Class newClass, SEL newSelector, BOOL classMethod)
{
    Method origMethod;
    Method newMethod;
    NSMethodSignature *originalMethodSignature = nil;

    if (classMethod) {
        origMethod = class_getClassMethod(originalClass, originalSelector);
        newMethod = class_getClassMethod(newClass, newSelector);

        originalClass = object_getClass((id)originalClass);
        newClass = object_getClass((id)newClass);

        originalMethodSignature = [originalClass methodSignatureForSelector:originalSelector];
    } else {
        origMethod = class_getInstanceMethod(originalClass, originalSelector);
        newMethod = class_getInstanceMethod(newClass, newSelector);

        originalMethodSignature = [originalClass instanceMethodSignatureForSelector:originalSelector];
    }

    NSInvocation *originalInvocation = [NSInvocation invocationWithMethodSignature:originalMethodSignature];
    originalInvocation.selector = newSelector;

    if (class_addMethod(originalClass, originalSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(originalClass, newSelector, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
        method_exchangeImplementations(origMethod, newMethod);
    }

    return originalInvocation;
}
