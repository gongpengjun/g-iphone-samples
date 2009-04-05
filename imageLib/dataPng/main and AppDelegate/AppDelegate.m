//
//  AppDelegate.m
//

#import "AppDelegate.h"
#import "RootViewController.h"

@implementation AppDelegate

@synthesize window,rootViewController,navigationController;

- (void)dealloc {
	[rootViewController release];
	[navigationController release];
    [window release];
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	window.backgroundColor = [UIColor groupTableViewBackgroundColor];
	
    rootViewController   = [[RootViewController alloc] init];
	navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
	[window addSubview:[navigationController view]];
	
    [window makeKeyAndVisible];
}


@end
