//
//  NSArray+Utilities.m
//  WhatToFixPlugin
//
//  Created by Aaron Daub on 2015-05-20.
//  Copyright (c) 2015 Eugene Kolpakov. All rights reserved.
//

#import "NSArray+Utilities.h"

@implementation NSArray (Utilities)

- (NSArray*)arrayByMapping:(id (^)(id))closure {
  NSParameterAssert(closure);
  
  NSMutableArray* results = [NSMutableArray array];
  
  for (id obj in self){
    id mappedObj = closure(obj);
    if(mappedObj){
      [results addObject:mappedObj];
    }
  }
  
  return results.copy;
}

- (NSArray*)arrayByFiltering:(BOOL (^)(id))closure{
  NSParameterAssert(closure);
  
  return [self arrayByMapping:^id(id input) {
    BOOL passed = closure(input);
    
    return passed ? input : nil;
  }];
}

@end
