//
//  RootViewController.m
//

#import "HTTPServer.h"
#import "FGServerContent.h"
#import "DetailCell.h"
#import "RootViewController.h"

@interface RootViewController (private)
- (void)startServer;
- (void)stopServer;
@end

@implementation RootViewController

- (void)dealloc 
{
	[httpServer release];
	[startButton release];
	[stopButton release];
    [super dealloc];
}

- (id)init
{
	if(self = [super initWithStyle:UITableViewStyleGrouped])
	{
		self.title = @"HTTP Server";
		startButton  = [[UIBarButtonItem alloc] initWithTitle:@"Start"
														style:UIBarButtonItemStyleDone
													   target:self
													   action:@selector(doStart)];
		stopButton   = [[UIBarButtonItem alloc] initWithTitle:@"Stop"
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
}

- (void)doStop
{
	[self stopServer];
	self.navigationItem.rightBarButtonItem = startButton;
}

- (HTTPServer*)httpServer
{
	if(!httpServer)
	{
		httpServer = [[HTTPServer alloc] init];
		[httpServer setPort:8080];
		[httpServer setType:@"_http._tcp."];
		[httpServer setDocumentRoot:[NSURL fileURLWithPath:[FGServerContent rootDirectory]]];
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
- (void)httpServer:(HTTPServer*)server statusChangedTo:(HTTPServerStatus)status
{
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return @"Server Status";
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    DetailCell *cell = (DetailCell *)[tableView dequeueReusableCellWithIdentifier:@"DetailCell"];
    if (cell == nil) {
        cell = [[[DetailCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"DetailCell"] autorelease];
    }
	cell.type.text = @"status";
	cell.name.text = @"Tap \"Start\" to launch";
	cell.promptMode = NO;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
}

@end
