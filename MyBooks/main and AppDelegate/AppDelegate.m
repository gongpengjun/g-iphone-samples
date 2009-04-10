//
//  AppDelegate.m
//

#import "AppDelegate.h"
#import "BookListViewController.h"
#import "FGDirectoryService.h"

@implementation AppDelegate

@synthesize window,rootViewController,navigationController;

- (void)dealloc 
{
	[rootViewController release];
	[navigationController release];
    [window release];
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{
	[FGDirectoryService establishRootDirectory];
	
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	window.backgroundColor = [UIColor groupTableViewBackgroundColor];
	
    rootViewController   = [[BookListViewController alloc] init];
	navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
	[window addSubview:[navigationController view]];
	
    [window makeKeyAndVisible];
}


@end
