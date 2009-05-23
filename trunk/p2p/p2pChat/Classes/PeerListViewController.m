//
//  RootViewController.m
//  BLIPClient
//
//  Created by Frank Gong on 5/17/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "PeerListViewController.h"
#import "ChatViewController.h"
#import "AppDelegate.h"

#define peers (((AppDelegate*)([UIApplication sharedApplication].delegate)).peers)

@implementation PeerListViewController

@synthesize tableView	= _tableView;

- (void)dealloc 
{
	[_tableView release];
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
	
	UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] init];
	backButtonItem.title = @"Devices";
	self.navigationItem.backBarButtonItem = backButtonItem;
	[backButtonItem release];
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
	self.title = @"Searching Devices...";
}

- (void)refreshTitle
{
	if(peers.count)
		self.title = [NSString stringWithFormat:@"Devices(%d)",peers.count];
	else
		self.title = @"Searching Devices...";
}

- (void)addPeer:(F1Peer*)peer
{
	[peers addObject:peer];
	[_tableView reloadData];
	[self refreshTitle];
}

- (void)removePeer:(F1Peer*)peer
{
	[peers removeObject:peer];
	[_tableView reloadData];
	[self refreshTitle];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return peers.count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// Configure the cell.
	if(peers.count)
	{
		F1BonjourPeer* peer = [peers objectAtIndex:indexPath.row];
		NSNetService * aNetService = peer.service;
		cell.textLabel.text = [aNetService name];
	}
	else
	{
		cell.textLabel.text = @"Searching blip Echo Servers";
	}
    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if(indexPath.row >= peers.count)
		return;
	
	ChatViewController *chatViewController = [ChatViewController sharedChatViewController];
	chatViewController.peer = [peers objectAtIndex:indexPath.row];
	[self.navigationController pushViewController:chatViewController animated:YES];
}

@end

