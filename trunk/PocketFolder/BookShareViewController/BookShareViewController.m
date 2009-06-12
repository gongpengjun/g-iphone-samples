//
//  BookShareViewController.m
//

#import "BookShareViewController.h"
#import "FGFileManager.h"
#import "HTTPConnection.h"
#import "FileBrowserViewController.h"
#import "AppDelegate.h"

@interface BookShareViewController (private)
- (void)startServer;
- (void)stopServer;
- (void)reloadFiles;
- (void)back;
@end

@implementation BookShareViewController

- (void)dealloc 
{
	[httpServer release];
	[startButton release];
	[stopButton release];
    [super dealloc];
}

- (id)init
{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) 
	{
		self.title = @"Files Share";
		startButton  = [[UIBarButtonItem alloc] initWithTitle:@"Start"
														style:UIBarButtonItemStyleDone
													   target:self
													   action:@selector(doStart)];
		stopButton   = [[UIBarButtonItem alloc] initWithTitle:@"Stop & Back"
														style:UIBarButtonItemStyleBordered
													   target:self
													   action:@selector(doStop)];
		self.navigationItem.rightBarButtonItem = startButton;
    }
    return self;
}


- (void)doStart
{
	[self startServer];
	self.navigationItem.rightBarButtonItem = stopButton;
	self.navigationItem.hidesBackButton = YES;
}

- (void)doStop
{
	[self stopServer];
	self.navigationItem.rightBarButtonItem = startButton;
	self.navigationItem.hidesBackButton = NO;
	[self reloadFiles];
	[self back];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self doStart];
}

- (void)reloadFiles
{
	AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
	NSArray * viewControllers = [[appDelegate navigationController] viewControllers];
	for(UIViewController * aViewController in viewControllers)
	{
		if([aViewController isKindOfClass:[FileBrowserViewController class]])
			[(FileBrowserViewController*)aViewController reloadFiles];
	}
}

- (void)back
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:1.0];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft
						   forView:self.navigationController.view cache:YES];	
	[self.navigationController popViewControllerAnimated:NO];
	[UIView commitAnimations];	
}

- (HTTPServer*)httpServer
{
	if(!httpServer)
	{
		httpServer = [[HTTPServer alloc] init];
		[httpServer setPort:8080];
		[httpServer setType:@"_http._tcp."];
		[httpServer setDocumentRoot:[NSURL fileURLWithPath:[FGFileManager booksDirectory]]];
		
		httpServer.delegate = self;
	}
	return httpServer;
}

- (void)startServer
{
	NSError *error;
	[self.httpServer start:&error];
}

- (void)stopServer
{
	[httpServer stop];
}

#pragma mark HTTPServer delegate methods
- (void)httpServer:(HTTPServer*)server changeToStatus:(HTTPServerStatus)newStatus
{
	status = newStatus;
	[self.tableView reloadData];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	NSInteger section = 1;
	switch(status)
	{
		case HTTPServerStatusStopped:             section = 0; break;
		case HTTPServerStatusStarted:             section = 3; break;
		case HTTPServerStatusNetServicePublished: section = 3; break;
		case HTTPServerStatusConnected:           section = 3; break;
	}
    return section;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSString *sectionTitle;
	switch(section)
	{
		case 0: sectionTitle = @"Launch your favorite web browser (Safari,FireFox,Internet Explorer etc) on your desktop computer or laptop.\n\nEnter the following address to upload and download books."; break;
		case 1: sectionTitle = @"OR"; break;
		case 2: sectionTitle = @"Note:\nYour desktop coumputer or laptop must join the same Wi-Fi network with your iPhone/iPod touch."; break;
	}
    return sectionTitle;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	NSInteger rows = 1;
	switch(section)
	{
		case 0: rows = 1; break;
		case 1: rows = 1; break;
		case 2: rows = 0; break;
	}
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailCell"];
    if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DetailCell"] autorelease];
		cell.textLabel.adjustsFontSizeToFitWidth = YES;
    }
	
	NSInteger section = [indexPath section];
	switch(section)
	{
		case 0:
			cell.textLabel.text = [NSString stringWithFormat:@"http://%@:%d",[httpServer localIPAddress],httpServer.port];
			break;
		case 1:
			{
			NSString * bonjourServer = [httpServer.name stringByReplacingOccurrencesOfString:@" " withString:@"-"];
			cell.textLabel.text = [NSString stringWithFormat:@"http://%@.local:%d",bonjourServer,httpServer.port];
			}
			break;
		default:
			cell = nil;
			break;
	}
    return cell;
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
	[httpServer release];
	httpServer = nil;
}

@end
