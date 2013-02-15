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

NSString * const kBrowserBundleIDFirefox = @"org.mozilla.firefox";
NSString * const kBrowserBundleIDChrome = @"com.google.Chrome";
NSString * const kBrowserBundleIDSafari = @"com.apple.Safari";

//==============================================================================================================================================================

@interface ICPMainController ()

@property (strong) NSString *currentSelection;

- (NSArray *)installedBrowsers;

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

- (void)applicationDidFinishLaunching:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectionDidChange:)
        name:NSTextViewDidChangeSelectionNotification object:nil];
    
    NSMenuItem * editMenuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
    
    if (editMenuItem != nil)
    {
        [[editMenuItem submenu] addItem:[NSMenuItem separatorItem]];
        
        NSArray * browsers = [self installedBrowsers];
        NSMenuItem * newMenuItem = nil;
        
        if ([browsers count] < 2)
        {
            newMenuItem = [[NSMenuItem alloc] initWithTitle:@"Post to Instacodes" action:@selector(postToInstacodes:) keyEquivalent:nil];
            [newMenuItem setTarget:self];
            [newMenuItem setRepresentedObject:[browsers lastObject]];
        }
        else
        {
            newMenuItem = [[NSMenuItem alloc] initWithTitle:@"Post to Instacodes" action:NULL keyEquivalent:nil];
            NSMenu * browsersMenu = [[NSMenu alloc] initWithTitle:@"Post to Instacodes"];
            
            for (NSString *browserID in browsers)
            {
                NSString *itemTitle = [NSString stringWithFormat:@"Post using %@", [[[browserID componentsSeparatedByString:@"."] lastObject] capitalizedString]];
                NSMenuItem * browserMenuItem = [[NSMenuItem alloc] initWithTitle:itemTitle action:@selector(postToInstacodes:) keyEquivalent:nil];
                [browserMenuItem setTarget:self];
                [browserMenuItem setRepresentedObject:browserID];
                [browsersMenu addItem:browserMenuItem];
            }
            
            [newMenuItem setSubmenu:browsersMenu];
            
        }
        
        [[editMenuItem submenu] addItem:newMenuItem];
        [newMenuItem release];
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

- (void)postToInstacodes:(id)sender
{
    NSLog(@"[InstaCodesPlugin] Posting to Instacod.es:\n%@", self.currentSelection);
    
    NSString * browserID = [sender representedObject];
    
    if (browserID == nil)
    {
        [[NSAlert alertWithMessageText:@"No browsers" defaultButton:@"OK" alternateButton:nil otherButton:nil
            informativeTextWithFormat:@"No WebGL supporting browsers installed on your system"] runModal];
        return;
    }
    
    NSString * postCode = [self.currentSelection URLEncodedString];
    NSString * URLString = [NSString stringWithFormat:@"http://instacod.es/?post_code=%@&post_lang=%@", postCode, @"ObjC"];
    
    [[NSWorkspace sharedWorkspace] openURLs:@[[NSURL URLWithString:URLString]] withAppBundleIdentifier:browserID
        options:NSWorkspaceLaunchDefault additionalEventParamDescriptor:nil launchIdentifiers:NULL];
}

#pragma mark

- (NSArray *)installedBrowsers
{
    NSMutableArray * browsers = [NSMutableArray arrayWithObjects:kBrowserBundleIDSafari, kBrowserBundleIDChrome, kBrowserBundleIDFirefox, nil];
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

@end
