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
    
    NSMenuItem * editMenuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
    
    if (editMenuItem != nil)
    {
        [[editMenuItem submenu] addItem:[NSMenuItem separatorItem]];
        
        NSArray * browsers = [self installedBrowsers];
        NSMenuItem * newMenuItem = nil;
        
        if ([browsers count] < 2)
        {
            newMenuItem = [[NSMenuItem alloc] initWithTitle:kMenuItemTitle action:NULL keyEquivalent:@""];
            [newMenuItem setTarget:self];
            [newMenuItem setRepresentedObject:[browsers lastObject]];
        }
        else
        {
            newMenuItem = [[NSMenuItem alloc] initWithTitle:kMenuItemTitle action:NULL keyEquivalent:@""];
            NSMenu * browsersMenu = [[NSMenu alloc] initWithTitle:kMenuItemTitle];
            
            for (NSString *browserID in browsers)
            {
                NSString *itemTitle = [NSString stringWithFormat:@"Post using %@", [[[browserID componentsSeparatedByString:@"."] lastObject] capitalizedString]];
                NSMenuItem * browserMenuItem = [[NSMenuItem alloc] initWithTitle:itemTitle action:@selector(postToInstacodes:) keyEquivalent:@""];
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
    }
    else
    {
        BOOL webGLEnabled = YES;
        
        if ([browserID isEqualToString:kBrowserBundleIDSafari])
        {
            // Check if Safari supports WebGL
            BOOL supportsWebGL = [[[NSUserDefaults standardUserDefaults] persistentDomainForName:kBrowserBundleIDSafari][kSafariPrefsWebGLSupportKey] boolValue];
            
            if (!supportsWebGL)
            {
                [[NSAlert alertWithMessageText:@"WebGL support is disabled in Safari by default"
                    defaultButton:@"OK" alternateButton:nil otherButton:nil
                    informativeTextWithFormat:@"Instacod.es requires browser that supports WebGL to work properly. To enable WebGL in Safari, "
                    "go to Safari Preferences -> Advanced tab, check 'Show Develop menu in menu bar'. "
                    "Then open Develop menu and check Enable WebGL menu item."] runModal];
                webGLEnabled = NO;
            }
        }
        
        if (webGLEnabled)
        {
            NSString * postCode = [self.currentSelection URLEncodedString];
            NSString * URLString = [NSString stringWithFormat:@"http://instacod.es/?post_code=%@&post_lang=%@", postCode, @"ObjC"];
            
            [[NSWorkspace sharedWorkspace] openURLs:@[[NSURL URLWithString:URLString]] withAppBundleIdentifier:browserID
                options:NSWorkspaceLaunchDefault additionalEventParamDescriptor:nil launchIdentifiers:NULL];
        }
    }
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
