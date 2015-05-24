//
//  WTFItem.m
//  WhatToFixPlugin
//
//  Created by Aaron Daub on 2015-05-20.
//  Copyright (c) 2015 Eugene Kolpakov. All rights reserved.
//

#import "WTFItem.h"
#import "NSArray+Utilities.h"

@interface WTFItem ()

@property (strong, nonatomic, readwrite) id documentLocation;
@property (nonatomic, readwrite, copy) NSString* text;

@end

@implementation WTFItem

- (instancetype)initWithDocumentLocation:(id)documentLocation text:(NSString *)text{
  if(self = [super init]){
    self.documentLocation = documentLocation;
    self.text = text;
  }
  
  return self;
}

- (NSString*)text {
  if(_text){
    return _text;
  }
  
  @synchronized(self) {
    [self loadDocumentDataAndThen:^(NSData *data) {
      NSString* contentsOfFile = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
      NSUInteger startingLineNumber = [[self.documentLocation valueForKey:@"startingLineNumber"] unsignedIntegerValue];
      NSUInteger endingLineNumber = [[self.documentLocation valueForKey:@"endingLineNumber"] unsignedIntegerValue];
      NSRange range = [[self.documentLocation valueForKey:@"characterRange"] rangeValue];
      NSArray* lines = [contentsOfFile componentsSeparatedByString:@"\n"];
      NSString* text = [[lines subarrayWithRange:NSMakeRange(startingLineNumber, (endingLineNumber - startingLineNumber + 1))] componentsJoinedByString:@"\n"];
      NSString* substring = [contentsOfFile substringWithRange:range];
      NSLog(@"%@", substring);
    }];
  }
  
  return _text;
}

#pragma mark - Private

- (NSURL*)documentURL {
  return [self.documentLocation performSelector:@selector(documentURL)];
}

- (NSString*)projectNameGuess {
  NSURL* initialURL = self.documentURL;
  NSString* extension = @".xcodeproj";
  NSString* projectName;
  while((initialURL = [initialURL URLByDeletingLastPathComponent])){
    @autoreleasepool {
      NSArray* relevantURLs = [self URLsInDirectoryAtURL:initialURL thatContainURLWithExtension:extension];
      if (relevantURLs.count > 0){
        projectName = [[[relevantURLs.firstObject absoluteString] lastPathComponent] stringByReplacingOccurrencesOfString:extension withString:@""];
        break;
      }
    }
  };
  
  return projectName;
}

- (NSArray*)URLsInDirectoryAtURL:(NSURL*)URL thatContainURLWithExtension:(NSString*)extension {
  NSError* searchError = nil;
  NSArray* URLs = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:URL includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsSubdirectoryDescendants error:&searchError];
  if(searchError){
    NSLog(@"");
  }
  
  return [URLs arrayByFiltering:^BOOL(NSURL* URL) {
    return [[[URL lastPathComponent] lowercaseString] hasSuffix:[extension lowercaseString]];
  }];
}

- (void)loadDocumentDataAndThen:(void(^)(NSData* data))closure{
  NSParameterAssert(closure);
  static NSOperationQueue* backgroundQueue = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    backgroundQueue = [NSOperationQueue new];
  });
  
  [backgroundQueue addOperationWithBlock:^{
    NSData* data = [NSData dataWithContentsOfURL:self.documentURL];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
      closure(data);
    }];
    
  }];
}

- (void)loadTextAndThen:(void (^)(NSString *))closure {
  NSParameterAssert(closure);
  if(self.text){
    closure(self.text);
    return;
  }
  
  [self loadDocumentDataAndThen:^(NSData *data) {
    NSString* contentsOfFile = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSUInteger startingLineNumber = [[self.documentLocation valueForKey:@"startingLineNumber"] unsignedIntegerValue];
    NSUInteger endingLineNumber = [[self.documentLocation valueForKey:@"endingLineNumber"] unsignedIntegerValue];
    NSArray* lines = [contentsOfFile componentsSeparatedByString:@"\n"];
    NSString* text = [[lines subarrayWithRange:NSMakeRange(startingLineNumber, (endingLineNumber - startingLineNumber + 1))] componentsJoinedByString:@"\n"];
    self.text = text;
    closure(text);
  }];
}

- (NSDictionary*)dictionaryRepresentation {
    return @{
             @"code": self.text ?: @"",
             @"description": self.itemDescription ?: @"",
             @"url_string": self.documentURL.absoluteString ?: @"",
             @"startingLineNumber": @([self startingLineNumber]),
             @"endingLineNumber": @([self endingLineNumber])
            };
}

- (NSInteger)startingLineNumber {
  return 0; // TODO:
}

- (NSInteger)endingLineNumber {
  return 0; // TODO:
}


@end
