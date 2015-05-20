//
//  WTFNotificationReceiver.m
//  WhatToFixApplication
//
//  Created by Joachim Kurz on 20.05.15.
//  Copyright (c) 2015 What To Fix. All rights reserved.
//

#import "WTFNotificationReceiver.h"
#import "WTFSharedConstants.h"

@interface WTFNotificationReceiver ()

@property NSOperationQueue *operationQueue;

@end

@implementation WTFNotificationReceiver

- (void)awakeFromNib
{
    self.operationQueue = [NSOperationQueue mainQueue];
    [[NSDistributedNotificationCenter defaultCenter] addObserverForName:WTFNewNotificationKey object:nil queue:self.operationQueue usingBlock:^(NSNotification *note) {
        NSLog(@"received notification: %@", note);
    }];
}

@end
