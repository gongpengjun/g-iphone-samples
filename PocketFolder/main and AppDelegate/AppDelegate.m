//
//  AppDelegate.m
//

#import "AppDelegate.h"
#import "DefaultsController.h"
#import "FGFileManager.h"
#import "FileBrowserViewController.h"
#import "FolderPickerViewController.h"

@implementation AppDelegate

@synthesize window,rootViewController,navigationController;

- (void)dealloc 
{
	[rootViewController release];
	[navigationController release];
    [window release];
	
	[progressIndicatorWindow release];
	[progressIndicatorView release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	progressIndicatorWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	CGRect frame = CGRectMake(140,220,40,40);
	progressIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:frame];
	[progressIndicatorView startAnimating];
	progressIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
	[progressIndicatorView sizeToFit];
	progressIndicatorView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
											  UIViewAutoresizingFlexibleRightMargin |
											  UIViewAutoresizingFlexibleTopMargin |
											  UIViewAutoresizingFlexibleBottomMargin);
	UIImageView *splashImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default.png"]] autorelease];
	[progressIndicatorWindow addSubview:splashImageView];
	[splashImageView addSubview:progressIndicatorView];
	[progressIndicatorWindow makeKeyAndVisible];
	
	[self performSelectorOnMainThread:@selector(doApplicationLoad:) withObject:application waitUntilDone:NO];
	
	return YES;
}

- (void)doApplicationLoad:(UIApplication *)application
{
	[FGFileManager establishBooksDirectory];
	
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	window.backgroundColor = [UIColor groupTableViewBackgroundColor];
		
	#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30000
	/*iPhone OS 3.0*/
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
	#endif
	
    FileBrowserViewController *aFileBrowser  = [[FileBrowserViewController alloc] init];
	aFileBrowser.curPath		= [FGFileManager booksDirectory];
	self.rootViewController = aFileBrowser;
	[aFileBrowser release];
	
	navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
	
	#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30000
	/*iPhone OS 3.0*/
	navigationController.navigationBar.barStyle = UIBarStyleBlack;
	navigationController.navigationBar.translucent = YES;
	#endif
	
	[window addSubview:[navigationController view]];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.1];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:progressIndicatorWindow cache:YES];
	
	[progressIndicatorView stopAnimating];
	[progressIndicatorView removeFromSuperview];
	progressIndicatorWindow.frame = CGRectZero;
	progressIndicatorWindow.hidden = YES;
	[window makeKeyAndVisible];
	
	[UIView commitAnimations];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	[[DefaultsController sharedDefaultsController] synchronize];
}

@end
