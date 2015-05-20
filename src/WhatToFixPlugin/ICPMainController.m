//
//  ICPMainController.m
//  InstaCodesPlugin
//
//  Created by Eugene Kolpakov on 13. 2. 15..
//  Copyright (c) 2013년 Eugene Kolpakov. All rights reserved.
//
//==============================================================================================================================================================

#import "ICPMainController.h"
#import "NSString+WebExtensions.h"
#import "WTFItem.h"
#import "WTFSharedConstants.h"

//==============================================================================================================================================================

NSString * const kBrowserBundleIDSafari = @"com.apple.Safari";
NSString * const kBrowserBundleIDChrome = @"com.google.Chrome";
NSString * const kBrowserBundleIDFirefox = @"org.mozilla.firefox";
NSString * const kBrowserBundleIDOpera = @"com.operasoftware.Opera";

NSString * const kSafariPrefsWebGLSupportKey = @"WebKitWebGLEnabled";

NSString * const kMenuItemTitle = @"Post Selection to Instacode";

//==============================================================================================================================================================

@interface ICPMainController ()

@property (strong) NSString *currentSelection;

- (NSArray *)installedBrowsers;
- (void)debugAlertWithMessage:(NSString *)message;

@property (strong, nonatomic) id lastEditor;

@end

//==============================================================================================================================================================

@implementation ICPMainController

+ (void) pluginDidLoad: (NSBundle*) plugin
{
    static id sharedPlugin = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedPlugin = [[self alloc] init];
    });
}

- (id)init
{
    if (self = [super init])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidFinishLaunching:)
            name:NSApplicationDidFinishLaunchingNotification object:nil];
    }
    
    return self;
}

#pragma mark - Action and notification handlers -

- (void)applicationDidFinishLaunching:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectionDidChange:)
        name:NSTextViewDidChangeSelectionNotification object:nil];
  __weak typeof (self) weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:@"DVTSourceExpressionSelectedExpressionDidChangeNotification" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
      weakSelf.lastEditor = note.object;
    }];
    
    NSMenuItem * editMenuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
    
    if (editMenuItem != nil)
    {
        [[editMenuItem submenu] addItem:[NSMenuItem separatorItem]];
        
        NSString *itemTitle = @"Create new WhatToFix";
        NSMenuItem *newMenuItem = [[NSMenuItem alloc] initWithTitle:itemTitle action:@selector(postWTF:) keyEquivalent:@""];
        
        [newMenuItem setTarget:self];
    
        [[editMenuItem submenu] addItem:newMenuItem];
    }
}

- (void)selectionDidChange:(NSNotification*)notification
{
    if ([[notification object] isKindOfClass:[NSTextView class]])
    {
        NSTextView * textView = (NSTextView *)[notification object];
        
        NSArray * selectedRanges = [textView selectedRanges];
        
        if (selectedRanges.count >= 1)
        {
            NSRange selectedRange = [[selectedRanges objectAtIndex:0] rangeValue];
            NSString *text = textView.textStorage.string;
            NSRange lineRange = [text lineRangeForRange:selectedRange];
            NSString *line = [text substringWithRange:lineRange];
            
            self.currentSelection = line;
        }
    }
}

- (void)postWTF:(id)sender
{
  WTFItem* item = [[WTFItem alloc] initWithDocumentLocation:[self.lastEditor valueForKey:@"_documentLocationUnderMouse"] text:[self.lastEditor valueForKey:@"selectedText"]];
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:WTFNewNotificationKey object:@"WTFPlugin" userInfo:@{@"start:" : [item.documentLocation valueForKey:@"startingColumnNumber"]}];
  NSLog(@"item");
}

#pragma mark - Private methods -

- (NSArray *)installedBrowsers
{
    NSMutableArray * browsers = [NSMutableArray arrayWithObjects:kBrowserBundleIDSafari, kBrowserBundleIDChrome,
        kBrowserBundleIDFirefox,/* kBrowserBundleIDOpera ,*/ nil];
    NSWorkspace * workspace = [NSWorkspace sharedWorkspace];
    
    for (NSString * browserID in browsers)
    {
        if (nil == [workspace absolutePathForAppBundleWithIdentifier:browserID])
        {
            [browsers removeObject:browserID];
        }
    }
    
    return browsers;
}

- (void)debugAlertWithMessage:(NSString *)message
{
#ifdef DEBUG
    [[NSAlert alertWithMessageText:@"Debug alert" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@", message] runModal];
#endif
}

@end
