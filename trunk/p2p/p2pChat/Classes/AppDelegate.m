//
//  p2pChatAppDelegate.m
//  p2pChat
//
//  Created by Frank Gong on 5/18/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "AppDelegate.h"
#import "UserListViewController.h"


@implementation AppDelegate

@synthesize window;
@synthesize navigationController;


#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	window.backgroundColor = [UIColor groupTableViewBackgroundColor];
	
	navigationController = [[UINavigationController alloc] 
							initWithRootViewController:[[[UserListViewController alloc] init] autorelease]];
	navigationController.toolbarHidden = NO;
	
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

