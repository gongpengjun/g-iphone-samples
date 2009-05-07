//
//  BookShareViewController.m
//

#import "BookShareViewController.h"
#import "FGFileManager.h"
#import "HTTPConnection.h"
#import "DetailCell.h"
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
		self.title = @"Books Share";
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
		case HTTPServerStatusStopped:             section = 1; break;
		case HTTPServerStatusStarted:             section = 2; break;
		case HTTPServerStatusNetServicePublished: section = 4; break;
		case HTTPServerStatusConnected:           section = 4; break;
	}
    return section;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSString *sectionTitle;
	switch(section)
	{
		case 0: sectionTitle = @"Server Status"; break;
		case 1: sectionTitle = @"Server Address"; break;
		case 2: sectionTitle = @"Remote Addresses"; break;
		case 3: sectionTitle = @"Bonjour Service"; break;
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
		case 2: rows = [httpServer numberOfHTTPConnections]; break;
		case 3: rows = 3; break;
	}
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    DetailCell *cell = (DetailCell *)[tableView dequeueReusableCellWithIdentifier:@"DetailCell"];
    if (cell == nil) {
        cell = [[[DetailCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"DetailCell"] autorelease];
		cell.promptMode = NO;
    }
	
	NSInteger section = [indexPath section];
	NSInteger row     = [indexPath row];
	switch(section)
	{
		case 0:
			cell.type.text = @"status";
			if(status == HTTPServerStatusStopped)
				cell.name.text = @"Tap \"Start\" to launch server";
			else
				cell.name.text = @"Tap \"Stop\" to stop server";
			break;
		case 1:
		{
			cell.type.text = @"IP:Port";
			cell.name.text = [NSString stringWithFormat:@"%@:%d",[httpServer localIPAddress],httpServer.port];
		}
			break;
		case 2:
		{
			cell.type.text = @"IP:Port";
			HTTPConnection * connection = [httpServer.connections objectAtIndex:row];
			cell.name.text = [NSString stringWithFormat:@"%@:%d",connection.connectedHost,connection.connectedPort];
		}
			break;
		case 3:
			switch(row)
		{
			case 0: 
				cell.type.text = @"domain";
				cell.name.text = httpServer.domain;
				break;
			case 1: 
				cell.type.text = @"type";
				cell.name.text = httpServer.type;
				break;
			case 2: 
				cell.type.text = @"name";
				cell.name.text = httpServer.name;
				break;
		}
			break;
	}
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if([indexPath section] == 0)
	{
		if([indexPath row] == 0)
		{
			if(status == HTTPServerStatusStopped)
				[self doStart];
			else
				[self doStop];
			[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
		}
	}
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
	[httpServer release];
	httpServer = nil;
}

- (void)viewDidUnload 
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

@end
