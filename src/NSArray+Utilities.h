//
//  NSArray+Utilities.h
//  WhatToFixPlugin
//
//  Created by Aaron Daub on 2015-05-20.
//  Copyright (c) 2015 Eugene Kolpakov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Utilities)

- (NSArray*)arrayByMapping:(id(^)(id input))closure;
- (NSArray*)arrayByFiltering:(BOOL(^)(id input))closure;

@end
