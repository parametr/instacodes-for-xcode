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

@interface ICPMainController ()

@property (strong) NSString *currentSelection;

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
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidFinishLaunching:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(selectionDidChange:)
                                                 name:NSTextViewDidChangeSelectionNotification
                                               object:nil];
    
    NSMenuItem* editMenuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
    
    if (editMenuItem)
    {
        [[editMenuItem submenu] addItem:[NSMenuItem separatorItem]];
        
        NSMenuItem* newMenuItem = [[NSMenuItem alloc] initWithTitle:@"Post to Instacodes"
                                                             action:@selector(postToInstacodes:)
                                                      keyEquivalent:@"m"];
        [newMenuItem setTarget:self];
        [newMenuItem setKeyEquivalentModifierMask:NSAlternateKeyMask];
        [[editMenuItem submenu] addItem:newMenuItem];
        [newMenuItem release];
    }
}

- (void)selectionDidChange:(NSNotification*)notification
{
    if ([[notification object] isKindOfClass:[NSTextView class]])
    {
        NSTextView* textView = (NSTextView *)[notification object];
        
        NSArray* selectedRanges = [textView selectedRanges];
        
        if (selectedRanges.count >= 1)
        {
            NSRange selectedRange = [[selectedRanges objectAtIndex:0] rangeValue];
            NSString *text = textView.textStorage.string;
            NSRange lineRange = [text lineRangeForRange:selectedRange];
            NSString *line = [text substringWithRange:lineRange];
            
            self.currentSelection = line;
            
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"alertEverySelection"])
            {
                NSAlert *alert = [[[NSAlert alloc] init] autorelease];
                [alert setMessageText:line];
                [alert runModal];
            }
        }
    }
}

- (void)postToInstacodes:(id)sender
{
    NSLog(@"[InstaCodesPlugin] Posting to Instacod.es:\n%@", self.currentSelection);
    
    NSString *postCode = [self.currentSelection URLEncodedString];
    NSString *URLString = [NSString stringWithFormat:@"http://instacod.es/?post_code=%@&post_lang=%@", postCode, @"ObjC"];
    
    NSLog(@"URL is %@", URLString);
    
    [[NSWorkspace sharedWorkspace] openURLs:@[[NSURL URLWithString:URLString]] withAppBundleIdentifier:@"com.google.Chrome"
        options:NSWorkspaceLaunchDefault additionalEventParamDescriptor:nil launchIdentifiers:NULL];
}

@end
