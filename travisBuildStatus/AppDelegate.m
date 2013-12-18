//
//  AppDelegate.m
//  travis
//
//  Created by Simon Westerlund on 17/12/13.
//  Copyright (c) 2013 Simon Westerlund. All rights reserved.
//

#import "AppDelegate.h"
#import "SWWindow.h"

static NSString *const statusItemTitle = @"travis";
static NSString *const userDefaultsRepositoryName = @"userDefaultsRepositoryName";

@interface AppDelegate () <NSTextFieldDelegate>

@property (nonatomic, strong) NSString *repositoryName;
@property (nonatomic, getter = isActive) BOOL active;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    [self setStatusItem:[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength]];
    [self.statusItem setMenu:[self statusMenu]];
    [self.statusItem setHighlightMode:YES];
    
    [self setupMenu];
    
    [self.keyTextField setDelegate:self];
    [self setRepositoryName:[[NSUserDefaults standardUserDefaults] objectForKey:userDefaultsRepositoryName]];
    
    if ([self.repositoryName length] == 0) {
        [self setRepositoryName:@""];
        [self showKeyChangeWindow];
    } else {
        [self setActive:YES];
        [self runCheckLoop];
    }
}

- (void)setupMenu {
    [self setStatusMenuItem:[NSMenuItem new]];
    [self.statusMenuItem setTitle:@"Status"];
    [self.statusMenu addItem:[self statusMenuItem]];
    
    NSMenuItem *repositoryNameMenuItem = [[NSMenuItem alloc] initWithTitle:@"Key" action:@selector(showKeyChangeWindow) keyEquivalent:@""];
    [self.statusMenu addItem:repositoryNameMenuItem];
    
    NSMenuItem *destroyUserDefaultsMenuItem = [[NSMenuItem alloc] initWithTitle:@"Reset app" action:@selector(destroyUserDefaults:) keyEquivalent:@""];
    [self.statusMenu addItem:destroyUserDefaultsMenuItem];
    
    NSMenuItem *quitAppMenuItem = [[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@""];
    [self.statusMenu addItem:quitAppMenuItem];
}

- (void)destroyUserDefaults:(id)sender {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:userDefaultsRepositoryName];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSApplication sharedApplication] terminate:nil];
}

- (void)controlTextDidEndEditing:(NSNotification *)obj {
    [self saveAndCloseWindow:nil];
}

- (void)showKeyChangeWindow {
    [self setActive:NO];
    [self.keyTextField setStringValue:[self repositoryName]];
    [[NSApplication sharedApplication] runModalForWindow:[self window]];
    [self.window makeKeyWindow];
    [self.keyTextField becomeFirstResponder];
}

- (void)saveAndCloseWindow:(id)sender {
    [self.window close];
    [self setRepositoryName:[self.keyTextField stringValue]];
    [[NSUserDefaults standardUserDefaults] setObject:[self.keyTextField stringValue] forKey:userDefaultsRepositoryName];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self setActive:YES];
    [self runCheckLoop];
}

- (void)runCheckLoop {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSError *error = nil;
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://simonwesterlund.se/travis.php?id=%@", [self repositoryName]]];
        NSData *data = [NSData dataWithContentsOfURL:url];
        if ([data length] != 0) {
            id response = [NSJSONSerialization JSONObjectWithData:data
                                                          options:NSJSONReadingMutableContainers
                                                            error:&error];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([response isKindOfClass:[NSDictionary class]] &&
                    [[response objectForKey:@"result"] isKindOfClass:[NSNumber class]]) {
                    int result = [[response objectForKey:@"result"] intValue];
                    if (result == 0) {
                        [self.statusItem setImage:[NSImage imageNamed:@"icon_grey"]];
                        [self.statusMenuItem setTitle:[NSString stringWithFormat:@"%@: %@", [self repositoryName], [response objectForKey:@"status_message"]]];
                    } else {
                        [self.statusItem setImage:[NSImage imageNamed:@"icon_red"]];
                        [self.statusItem setTitle:@""];
                        [self.statusMenuItem setTitle:[response objectForKey:@"status_message"]];
                    }
                } else {
                    [self.statusItem setImage:[NSImage imageNamed:@"icon_red"]];
                    [self.statusItem setTitle:@""];
                    if ([[response objectForKey:@"status"] isEqualToString:@"not found"]) {
                        [self.statusMenuItem setTitle:@"Repo not found"];
                    } else {
                        [self.statusMenuItem setTitle:@"Invalid response"];
                    }
                }
            });
        } else {
            [self.statusItem setImage:[NSImage imageNamed:@"icon_red"]];
            [self.statusItem setTitle:@""];
            [self.statusMenuItem setTitle:@"Invalid response"];
        }
    });
        
    if ([self isActive]) {
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self runCheckLoop];
        });
    }
}

@end
