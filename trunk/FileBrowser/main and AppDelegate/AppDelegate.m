//
//  AppDelegate.m
//

#import "AppDelegate.h"
#import "FileBrowserViewController.h"

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
	
    rootViewController   = [[FileBrowserViewController alloc] init];
	rootViewController.path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Files"];
	navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
	[window addSubview:[navigationController view]];
	
    [window makeKeyAndVisible];
}


@end
