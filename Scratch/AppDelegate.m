//
//  AppDelegate.m
//  Scratch
//
//  Created by hanks on 2/12/15.
//  Copyright (c) 2015 com.hanks. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    // add lumberjack log instance globally
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    // set color enable to log
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
