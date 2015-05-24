//
//  WTFItem.h
//  WhatToFixPlugin
//
//  Created by Aaron Daub on 2015-05-20.
//  Copyright (c) 2015 Eugene Kolpakov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WTFItem : NSObject

@property (strong, nonatomic, readonly) id documentLocation;
@property (nonatomic, readonly, copy) NSString* text;
@property (strong, nonatomic, readonly) NSURL* documentURL;
@property (nonatomic, readonly, copy) NSString* itemDescription;

- (instancetype)initWithDocumentLocation:(id)documentLocation text:(NSString*)text;

- (void)loadDocumentDataAndThen:(void(^)(NSData* data))closure;
- (void)loadTextAndThen:(void(^)(NSString*))closure;
- (NSString*)projectNameGuess;

- (NSDictionary*)dictionaryRepresentation;

@end
