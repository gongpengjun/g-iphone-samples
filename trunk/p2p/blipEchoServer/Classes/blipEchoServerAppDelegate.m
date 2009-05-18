//
//  blipEchoServerAppDelegate.m
//  blipEchoServer
//
//  Created by Frank Gong on 5/18/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "blipEchoServerAppDelegate.h"
#import "RootViewController.h"
#import "ServerViewController.h"

@implementation blipEchoServerAppDelegate

@synthesize window;
@synthesize navigationController;


#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
	ServerViewController * myViewController = [[[ServerViewController alloc] init] autorelease];
	[navigationController pushViewController:myViewController animated:NO];
	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}


@end

