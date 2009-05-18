//
//  RootViewController.m
//  BLIPClient
//
//  Created by Frank Gong on 5/17/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "RootViewController.h"
#import "InteractViewController.h"
#import "BLIP.h"
#import "Target.h"

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"BLIP Client";
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    _serviceBrowser = [[NSNetServiceBrowser alloc] init];
    _serviceList	= [[NSMutableArray alloc] init];
    [_serviceBrowser setDelegate:self];
    
    [_serviceBrowser searchForServicesOfType:@"_blipecho._tcp." inDomain:@""];
}

#pragma mark -
#pragma mark NSNetServiceBrowser delegate methods

// We broadcast the willChangeValueForKey: and didChangeValueForKey: for the NSTableView binding to work.
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    if (![_serviceList containsObject:aNetService]) {
        [_serviceList addObject:aNetService];
		[self.tableView reloadData];
    }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    if ([_serviceList containsObject:aNetService]) {
        [_serviceList removeObject:aNetService];
		[self.tableView reloadData];
    }
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _serviceList.count ? _serviceList.count : 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.row >= _serviceList.count)
		return;
	
	InteractViewController *interactViewController = [InteractViewController sharedInteractViewController];
	interactViewController.netService = [_serviceList objectAtIndex:indexPath.row];
	[self.navigationController pushViewController:interactViewController animated:YES];
}

- (void)dealloc {
	[_serviceBrowser release];
	[_serviceList release];
    [super dealloc];
}


@end

