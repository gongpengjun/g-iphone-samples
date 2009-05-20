//
//  RootViewController.m
//  BLIPClient
//
//  Created by Frank Gong on 5/17/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "UserListViewController.h"
#import "ChatViewController.h"
#import "BLIP.h"
#import "Target.h"

#import "IPAddress.h"
#import <netinet/in.h>
#import <sys/types.h>
#import <sys/socket.h>
#import <ifaddrs.h>

@implementation UserListViewController

@synthesize label = _label;
@synthesize tableView = _tableView;

- (void)dealloc 
{
	[_tableView release];
	
	[_label release];
	[_listener close];
	[_listener release];
	
	[_serviceBrowser release];
	[_serviceList release];
    [super dealloc];
}

- (void)loadView
{
	[super loadView];
	
	CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
	UIView *contentView = [[UIView alloc] initWithFrame:appFrame];
	[contentView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
	self.view = contentView;
	[contentView release];
	
	appFrame.origin.y = 0;
    _tableView = [[UITableView alloc] initWithFrame:appFrame style:UITableViewStylePlain];
	_tableView.delegate = self;
	_tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	[_tableView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
	[self.view addSubview:_tableView];
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
	self.title = @"p2pChat";
	
	_label = [[UITextView alloc] initWithFrame:CGRectMake(0,0,300,40)];
	_label.backgroundColor = [UIColor lightGrayColor];
	_label.textAlignment = UITextAlignmentCenter;
	_label.font = [UIFont systemFontOfSize:18];
	_label.editable = NO;
	//[self.view addSubview:_label];
	UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithCustomView:_label];
	self.toolbarItems = [NSArray arrayWithObject:item];

    self.label.text = @"Opening listener socket...";
	
    _listener = [[BLIPListener alloc] initWithPort: 12345];
    _listener.delegate = self;
    _listener.pickAvailablePort = YES;
    _listener.bonjourServiceType = @"_blipecho._tcp";
	//_listener.bonjourServiceName = [UIDevice currentDevice].name;
    [_listener open];

    _serviceBrowser = [[NSNetServiceBrowser alloc] init];
    _serviceList	= [[NSMutableArray alloc] init];
    [_serviceBrowser setDelegate:self];
    
    [_serviceBrowser searchForServicesOfType:@"_blipecho._tcp." inDomain:@""];
}


- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];	
}

#pragma mark -
#pragma mark NSNetServiceBrowser delegate methods

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing 
{
	if ([_serviceList containsObject:aNetService]) 
	{
		[_serviceList removeObject:aNetService];
		[self.tableView reloadData];
	}
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing 
{
	[aNetService retain];
	[aNetService setDelegate:self];
	[aNetService resolve];
}

- (void)netServiceDidResolveAddress:(NSNetService *)aNetService;
{
	[aNetService autorelease];
	
	BOOL isSelf = NO;
	struct ifaddrs* interface;
	
	if (getifaddrs(&interface) == 0) 
	{
		struct ifaddrs* allInterfaces = interface;
		while (interface != NULL) 
		{
			const struct sockaddr_in* address = (const struct sockaddr_in*) interface->ifa_addr;
			if (address->sin_family != AF_INET) 
			{
				interface = interface->ifa_next;
				continue;
			}
			
			for (NSData* serviceAddressData in [aNetService addresses]) 
			{
				const struct sockaddr_in* serviceAddress = [serviceAddressData bytes];
				if (!serviceAddress->sin_family == AF_INET) continue;
				
				if (serviceAddress->sin_addr.s_addr == address->sin_addr.s_addr) 
				{
					isSelf = YES;
					break;
				}
			}
			
			if (isSelf) break;
			interface = interface->ifa_next;
		}
		
		freeifaddrs(allInterfaces);
	}
	
	if (isSelf) return;
	
	if (![_serviceList containsObject:aNetService]) 
	{
		[_serviceList addObject:aNetService];
		[self.tableView reloadData];
	}
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return _serviceList.count ? _serviceList.count : 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
	{
		#if __IPHONE_OS_VERSION_MAX_ALLOWED < 30000
		/*iPhone OS 2.2.1*/
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
		#else
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		#endif
    }
    
	// Configure the cell.
	if(_serviceList.count)
	{
		NSNetService * aNetService = [_serviceList objectAtIndex:indexPath.row];
		#if __IPHONE_OS_VERSION_MAX_ALLOWED < 30000
		cell.text = [aNetService name];
		#else
		cell.textLabel.text = [aNetService name];
		#endif
	}
	else
	{
		#if __IPHONE_OS_VERSION_MAX_ALLOWED < 30000
		cell.text = @"Searching blip Echo Servers";
		#else
		cell.textLabel.text = @"Searching blip Echo Servers";
		#endif
		
	}
    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if(indexPath.row >= _serviceList.count)
		return;
	
	ChatViewController *interactViewController = [ChatViewController sharedInteractViewController];
	interactViewController.netService = [_serviceList objectAtIndex:indexPath.row];
	[self.navigationController pushViewController:interactViewController animated:YES];
}

#pragma mark BLIP Listener Delegate:

- (void) listenerDidOpen: (TCPListener*)listener
{
    self.label.text = [NSString stringWithFormat: @"Listening on port %i",listener.port];
}

- (void) listener: (TCPListener*)listener failedToOpen: (NSError*)error
{
    self.label.text = [NSString stringWithFormat: @"Failed to open listener on port %i: %@",
                  listener.port,error];
}

- (void) listener: (TCPListener*)listener didAcceptConnection: (TCPConnection*)connection
{
    self.label.text = [NSString stringWithFormat: @"Accepted connection from %@",
                  connection.address];
    connection.delegate = self;
}

- (void) connection: (TCPConnection*)connection failedToOpen: (NSError*)error
{
    self.label.text = [NSString stringWithFormat: @"Failed to open connection from %@: %@",
                  connection.address,error];
}

- (void) connection: (BLIPConnection*)connection receivedRequest: (BLIPRequest*)request
{
    NSString *message = [[NSString alloc] initWithData: request.body encoding: NSUTF8StringEncoding];
    self.label.text = [NSString stringWithFormat: @"Received:\n“%@”",message];
    [request respondWithData:request.body contentType: request.contentType];
}

- (void) connection: (BLIPConnection*)connection receivedResponse: (BLIPResponse*)response;
{
	[connection close];
}

- (void) connectionDidClose: (TCPConnection*)connection;
{
    self.label.text = [NSString stringWithFormat: @"Connection closed from %@",
                  connection.address];
}

@end

