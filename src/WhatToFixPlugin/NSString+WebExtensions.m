//
//  NSString+WebExtensions.m
//  InstaCodesPlugin
//
//  Created by Eugene Kolpakov on 13. 2. 15..
//  Copyright (c) 2013년 Eugene Kolpakov. All rights reserved.
//
//==============================================================================================================================================================

#import "NSString+WebExtensions.h"

//==============================================================================================================================================================

@implementation NSString (WebExtensions)

- (NSString *)URLEncodedString
{
    CFStringRef originalString = (CFStringRef)self;
    CFStringRef charactersToBeEscaped = CFSTR("!#$%&'()*+,/:;=?@[]^{}<>` ");

    CFStringRef URLEncodedString = CFURLCreateStringByAddingPercentEscapes(NULL, originalString, NULL, charactersToBeEscaped, kCFStringEncodingUTF8);

    return [(NSString *)URLEncodedString autorelease];
}

@end
