//
//  RootViewController.m
//

#import "BookReaderViewController.h"
#import "FGDirectoryService.h"

@implementation BookReaderViewController

- (id)init
{
	if(self = [super init])
	{
		self.title = NSLocalizedString(@"My Books", @"");
	}
	return self;
}

- (void)dealloc
{
	[myWebView release];
	[super dealloc];
}

- (void)loadView
{
	// the base view for this view controller
	UIView *contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
	
	// important for view orientation rotation
	contentView.autoresizesSubviews = YES;
	contentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);	
	
	self.view = contentView;
	
	[contentView release];

	CGRect webFrame = [[UIScreen mainScreen] bounds];
	myWebView = [[UIWebView alloc] initWithFrame:webFrame];
	myWebView.backgroundColor = [UIColor whiteColor];
	myWebView.scalesPageToFit = YES;
	myWebView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	myWebView.delegate = self;
	[self.view addSubview: myWebView];
	
	NSString *pdfPath = [FGDirectoryService fullPathOfFile:@"pdf/Persuasive Writing.pdf"];
	NSURL *pdfUrl = [NSURL fileURLWithPath:pdfPath isDirectory:YES];
	[myWebView loadRequest:[NSURLRequest requestWithURL:pdfUrl]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// we support rotation in this view controller
	return YES;
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

@end
