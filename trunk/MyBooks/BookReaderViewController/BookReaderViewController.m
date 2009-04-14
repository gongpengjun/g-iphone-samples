//
//  BookReaderViewController.m
//

#import "Book.h"
#import "MyWebView.h"
#import "BookReaderViewController.h"
#import "FGFileManager.h"
#import "AppDelegate.h"

static BookReaderViewController *s_sharedBookReaderViewController = nil;

@implementation BookReaderViewController

@synthesize book;

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
	[super dealloc];
}

- (void)loadView
{
	self.wantsFullScreenLayout = YES;
	
	// the base view for this view controller
	UIView *contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
	
	// important for view orientation rotation
	contentView.autoresizesSubviews = YES;
	contentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);	
	
	self.view = contentView;
	
	[contentView release];

	CGRect webFrame = [[UIScreen mainScreen] bounds];
	myWebView = [[MyWebView alloc] initWithFrame:webFrame];
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
		NSString * bookPath = [book.basePath stringByAppendingPathComponent:book.name];
		NSURL *bookUrl = [NSURL fileURLWithPath:bookPath isDirectory:NO];
		[myWebView loadRequest:[NSURLRequest requestWithURL:bookUrl]];
	}	
}

- (void)viewDidAppear:(BOOL)animated
{
	[NSTimer scheduledTimerWithTimeInterval: 5.0 /*second*/ 
									 target: self
								   selector: @selector(hideNaviBar)
								   userInfo: nil
									repeats: NO];	
}

- (void)viewDidDisappear:(BOOL)animated
{
	self.book = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// we support rotation in this view controller
	return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	AppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
	naviBarHidden = appDelegate.navigationController.navigationBar.hidden;
	[UIApplication sharedApplication].statusBarHidden     = NO;
	appDelegate.navigationController.navigationBar.hidden = NO;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	if(naviBarHidden)
	{
		AppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
		[UIApplication sharedApplication].statusBarHidden     = YES;
		appDelegate.navigationController.navigationBar.hidden = YES;
	}		
}

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

- (void)switchNaviBar
{
	AppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
	if([[UIApplication sharedApplication] isStatusBarHidden])
	{
		[[UIApplication sharedApplication] setStatusBarHidden:NO animated:NO];
		appDelegate.navigationController.navigationBar.hidden = NO;
	}
	else
	{
		[[UIApplication sharedApplication] setStatusBarHidden:YES animated:NO];
		appDelegate.navigationController.navigationBar.hidden = YES;
		[NSTimer scheduledTimerWithTimeInterval: 5.0 /*second*/ 
										 target: self
									   selector: @selector(hideNaviBar)
									   userInfo: nil
										repeats: NO];		
	}
	[self.view setNeedsLayout];
}

- (void)hideNaviBar
{
	AppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
	if(![[UIApplication sharedApplication] isStatusBarHidden])
	{
		[[UIApplication sharedApplication] setStatusBarHidden:YES animated:NO];
		appDelegate.navigationController.navigationBar.hidden = YES;
	}
	[self.view setNeedsLayout];	
}

@end
