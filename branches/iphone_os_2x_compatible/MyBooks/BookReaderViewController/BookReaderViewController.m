//
//  BookReaderViewController.m
//

#import "Book.h"
#import "MyWebView.h"
#import "BookReaderViewController.h"
#import "FGFileManager.h"
#import "AppDelegate.h"

static BookReaderViewController *s_sharedBookReaderViewController = nil;

@interface BookReaderViewController (Private)
- (void)correctNavigationBarPosition;
@end

@implementation BookReaderViewController

@synthesize book,naviHideTimer;

+ (id)sharedInstance
{
	if(!s_sharedBookReaderViewController)
	{
		s_sharedBookReaderViewController = [[BookReaderViewController alloc] init];
	}
	return s_sharedBookReaderViewController;
}

- (id)init
{
	if(self = [super init])
	{
		self.title = NSLocalizedString(@"Book", @"");
	}
	return self;
}

- (void)dealloc
{
	[myWebView release];
	[book release];
	[naviHideTimer release];
	[super dealloc];
}

- (void)loadView
{
	#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30000
	/*iPhone OS 3.0*/
	self.wantsFullScreenLayout = YES;
	#endif
	
	// the base view for this view controller
	UIView *contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
	
	// important for view orientation rotation
	contentView.autoresizesSubviews = YES;
	contentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);	
	
	self.view = contentView;
	
	[contentView release];

	CGRect webFrame = [[UIScreen mainScreen] bounds];
	#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30000
	/*iPhone OS 3.0*/
	myWebView = [[MyWebView alloc] initWithFrame:webFrame];
	#else
	myWebView = [[UIWebView alloc] initWithFrame:webFrame];
	#endif
	myWebView.backgroundColor = [UIColor whiteColor];
	myWebView.scalesPageToFit = YES;
	myWebView.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	myWebView.delegate = self;
	[self.view addSubview: myWebView];
}

- (void)viewWillAppear:(BOOL)animated
{	
	if(book)
	{
		self.title          = book.title;
		if([[[book.name pathExtension] lowercaseString] isEqualToString:@"txt"])
		{
			NSString * bookPath = [book.basePath stringByAppendingPathComponent:book.name];
			NSData * bookData = [NSData dataWithContentsOfFile:bookPath];
			bookPath = [bookPath stringByReplacingOccurrencesOfString:@"/" withString:@"//"];
			bookPath = [bookPath stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
			NSURL *baseUrl = [NSURL URLWithString: [NSString stringWithFormat:@"file:/%@//",bookPath]];
			[myWebView loadData:bookData MIMEType:@"text/plain" textEncodingName:@"UTF-8" baseURL:baseUrl];
		}
		else
		{
			NSString * bookPath = [book.basePath stringByAppendingPathComponent:book.name];
			NSURL *bookUrl = [NSURL fileURLWithPath:bookPath isDirectory:NO];
			[myWebView loadRequest:[NSURLRequest requestWithURL:bookUrl]];
		}
	}	
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30000
/*iPhone OS 3.0*/
- (void)viewDidAppear:(BOOL)animated
{
	self.naviHideTimer = [NSTimer scheduledTimerWithTimeInterval: 5.0 /*second*/ 
														  target: self
														selector: @selector(hideNaviBar)
														userInfo: nil
														 repeats: NO];
}
#endif

- (void)viewDidDisappear:(BOOL)animated
{
	if(naviHideTimer && [naviHideTimer isValid])
		[naviHideTimer invalidate];
	self.book = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// we support rotation in this view controller
	return YES;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30000
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	if(naviHideTimer && [naviHideTimer isValid])
		[naviHideTimer invalidate];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	self.naviHideTimer = [NSTimer scheduledTimerWithTimeInterval: 5.0 /*second*/ 
														  target: self
														selector: @selector(hideNaviBar)
														userInfo: nil
														 repeats: NO];
	[self correctNavigationBarPosition];
}
#endif

#pragma mark UIWebView delegate methods

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	// starting the load, show the activity indicator in the status bar
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	// finished loading, hide the activity indicator in the status bar
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	// load error, hide the activity indicator in the status bar
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	// report the error inside the webview
	NSString* errorString = [NSString stringWithFormat:
							 @"<html><center><font size=+5 color='red'>An error occurred:<br>%@</font></center></html>",
							 error.localizedDescription];
	[myWebView loadHTMLString:errorString baseURL:nil];
}

#pragma mark MyWebViewDelegate
- (void)touchesEnded:(NSSet*)touches inWebView:(UIWebView*)sender withEvent:(UIEvent*)event;
{
	/*ignore multi-touch gesture*/
	if([event allTouches].count >= 2)
		return;
	
	UITouch * touch = [touches anyObject];
	if(touch.tapCount == 1)
	{
		[self performSelector:@selector(switchNaviBar) withObject:nil afterDelay:0.2];
	}
	else if(touch.tapCount >= 2)
	{
		[NSObject cancelPreviousPerformRequestsWithTarget:self];
	}
}

#pragma mark Navigation bar management
- (void)switchNaviBar
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30000
	AppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
	if(![appDelegate.navigationController.topViewController isEqual:self])
		return;
	if([[UIApplication sharedApplication] isStatusBarHidden])
	{
		[[UIApplication sharedApplication] setStatusBarHidden:NO animated:NO];
		appDelegate.navigationController.navigationBar.hidden = NO;
		if(naviHideTimer && [naviHideTimer isValid])
			[naviHideTimer invalidate];
		self.naviHideTimer = [NSTimer scheduledTimerWithTimeInterval: 5.0 /*second*/ 
															  target: self
															selector: @selector(hideNaviBar)
															userInfo: nil
															 repeats: NO];
	}
	else
	{
		[[UIApplication sharedApplication] setStatusBarHidden:YES animated:NO];
		appDelegate.navigationController.navigationBar.hidden = YES;
	}
	[self correctNavigationBarPosition];
#endif
}

- (void)hideNaviBar
{
	AppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
	if(![appDelegate.navigationController.topViewController isEqual:self])
		return;
	if(![[UIApplication sharedApplication] isStatusBarHidden])
	{
		[[UIApplication sharedApplication] setStatusBarHidden:YES animated:NO];
		appDelegate.navigationController.navigationBar.hidden = YES;
	}
	[self correctNavigationBarPosition];
}

- (void)correctNavigationBarPosition
{
	AppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
	UINavigationBar * navigationBar = appDelegate.navigationController.navigationBar;
	
	NSLog(@"before correct navigation bar %@: frame (x=%f,y=%f),(w=%f,h=%f)", (navigationBar.hidden ? @"hide" : @"show"),
		  navigationBar.frame.origin.x,navigationBar.frame.origin.y,navigationBar.frame.size.width,navigationBar.frame.size.height);
	
	CGRect frame = navigationBar.frame;
	frame.origin.y = 20.0;
	navigationBar.frame = frame;
	
	[[UIApplication sharedApplication] setStatusBarHidden:navigationBar.hidden animated:NO];
	
	NSLog(@"after  correct navigation bar %@: frame (x=%f,y=%f),(w=%f,h=%f)", (navigationBar.hidden ? @"hide" : @"show"),
		  navigationBar.frame.origin.x,navigationBar.frame.origin.y,navigationBar.frame.size.width,navigationBar.frame.size.height);
}

@end
