//
//  CMDTextRange.h
//  CommandEdit
//
//  Created by Kolin Krewinkel on 9/25/14.
//  Copyright (c) 2014 Kolin Krewinkel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMDTextRange : NSObject

+ (instancetype)textRange:(NSRange)range;

@property (nonatomic, readonly) NSRange range;

@end
