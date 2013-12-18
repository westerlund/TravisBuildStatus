//
//  AppDelegate.h
//  travis
//
//  Created by Simon Westerlund on 17/12/13.
//  Copyright (c) 2013 Simon Westerlund. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSMenu *statusMenu;
@property (nonatomic, strong) IBOutlet NSMenuItem *statusMenuItem;
@property (nonatomic, strong) NSStatusItem *statusItem;
@property (nonatomic, strong) IBOutlet NSTextField *keyTextField;

- (IBAction)saveAndCloseWindow:(id)sender;
- (IBAction)destroyUserDefaults:(id)sender;

@end
