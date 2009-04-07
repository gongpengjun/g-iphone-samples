//
//  RootViewController.m
//

#import "RootViewController.h"
#import "HTTPServer.h"
#import "FGServerContent.h"

@implementation RootViewController

- (void)dealloc {
	[txtView release];
    [super dealloc];
}

- (void)startServer
{
	HTTPServer * httpServer = [[HTTPServer alloc] init];
	[httpServer setPort:8080];
	[httpServer setType:@"_http._tcp."];
	[httpServer setDocumentRoot:[NSURL fileURLWithPath:[FGServerContent rootDirectory]]];
	NSError *error;
	[httpServer start:&error];
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	
	self.title = @"HTTP Server";
	
	UIView * contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.view = contentView;
	[contentView release];
	
	[self startServer];
	
	txtView	= [[UITextView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	txtView.textAlignment = UITextAlignmentCenter;
	txtView.font = [UIFont systemFontOfSize:20];
	txtView.editable = NO;
	[self.view addSubview:txtView];
}

@end
