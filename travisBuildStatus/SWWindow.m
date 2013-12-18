//
//  SWWindow.m
//  travis
//
//  Created by Simon Westerlund on 18/12/13.
//  Copyright (c) 2013 Simon Westerlund. All rights reserved.
//

#import "SWWindow.h"

@implementation SWWindow

// Close window when pressing ESC key
- (void)cancelOperation:(id)sender {
    [super cancelOperation:sender];
    [self close];
}

- (void)close {
    [super close];
    
    // Hack to enable app again when closing window
    [[NSApplication sharedApplication] stopModal];
}

@end
