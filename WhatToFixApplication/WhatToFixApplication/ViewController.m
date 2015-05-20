//
//  ViewController.m
//  WhatToFixApplication
//
//  Created by Joachim Kurz on 20.05.15.
//  Copyright (c) 2015 Joachim Kurz. All rights reserved.
//

#import "ViewController.h"
#import <ParseOSX/ParseOSX.h>

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
    PFObject* wtfItem = [PFObject objectWithClassName:@"WTF"];
    [wtfItem setObject:@"projectName" forKey:@"projectName"]; //FIXME: get the dynamic value
    [wtfItem setObject:@"fileName" forKey:@"fileName"];       //FIXME: get the dynamic value
    [wtfItem setObject:@"filePath" forKey:@"fileName"];       //FIXME: get the dynamic value
    [wtfItem setObject:@"a=b;" forKey:@"code"];               //FIXME: get the dynamic value
    [wtfItem setObject:@"0" forKey:@"startLineNumber"];       //FIXME: get the dynamic value
    [wtfItem setObject:@"3" forKey:@"endLineNumber"];         //FIXME: get the dynamic value
    [wtfItem setObject:@"0" forKey:@"startColumnNumber"];     //FIXME: get the dynamic value
    [wtfItem setObject:@"50" forKey:@"endColumnNumber"];      //FIXME: get the dynamic value
    [wtfItem saveInBackground];
}

@end
