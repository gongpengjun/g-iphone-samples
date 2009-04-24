//
//  AppDelegate.m
//

#import "FileBrowserViewController.h"
#import "AppDelegate.h"
#import "DefaultsController.h"
#import "FGFileManager.h"

@implementation AppDelegate

@synthesize window,rootViewController,navigationController;

- (void)dealloc 
{
	[rootViewController release];
	[navigationController release];
    [window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[FGFileManager establishBooksDirectory];
	
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	window.backgroundColor = [UIColor groupTableViewBackgroundColor];
		
	#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30000
	/*iPhone OS 3.0*/
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
	#endif
	
    rootViewController         = [[FileBrowserViewController alloc] init];
	rootViewController.curPath = [FGFileManager booksDirectory];
	
	navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
	
	#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30000
	/*iPhone OS 3.0*/
	navigationController.navigationBar.barStyle = UIBarStyleBlack;
	navigationController.navigationBar.translucent = YES;
	#endif
	
	[window addSubview:[navigationController view]];
	
    [window makeKeyAndVisible];
	
	return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	[[DefaultsController sharedDefaultsController] synchronize];
}

@end
