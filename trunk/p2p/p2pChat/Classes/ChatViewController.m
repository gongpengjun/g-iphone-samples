//
//  InteractViewController.m
//  BLIPClient
//
//  Created by Frank Gong on 5/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ChatViewController.h"

@implementation ChatViewController

@synthesize peer = _peer, tableView = _tableView;

static ChatViewController * _sharedChatViewController = nil;
+ (ChatViewController*)sharedChatViewController
{
	if(!_sharedChatViewController)
		_sharedChatViewController = [[ChatViewController alloc] init];
	return _sharedChatViewController;
}

- (void)dealloc 
{
	[_peer release];
	[_requestTextFiled release];
	[_messages release];
	[_tableView release];
    [super dealloc];
}

- (id)init
{
	if(self = [super init])
	{
	}
	return self;
}

- (void)loadView 
{
	[super loadView];
	
	UIView *contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	[contentView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
	contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
	self.view = contentView;
	[contentView release];
	
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
	_tableView.delegate = self;
	_tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	[_tableView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
	[self.view addSubview:_tableView];
	
	_messages = [[NSMutableArray alloc] initWithCapacity:10];
	
	_requestTextFiled = [[UITextField alloc] initWithFrame:CGRectMake(10,120,300,25)];
	_requestTextFiled.backgroundColor = [UIColor greenColor];
	_requestTextFiled.returnKeyType = UIReturnKeySend;
	_requestTextFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
	_requestTextFiled.placeholder = @"enter text here";
	_requestTextFiled.delegate = self;
	[self.view addSubview:_requestTextFiled];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	F1MessageItem * item = [[F1MessageItem alloc] initWithMessage:textField.text];
	[_peer sendItem:item toPeer:_peer];
	[_messages addObject:item];
	[self.tableView reloadData];
	[item release];
	
	[textField resignFirstResponder];
	return YES;
}

- (void)didReceiveItem:(F1Item*)item fromPeer:(F1Peer*)peer
{
	[_messages addObject:item];
	[self.tableView reloadData];
}

- (void)setPeer:(F1BonjourPeer*)p
{
	//save all messages for the current peer
	
	[p retain];
	[_peer release];
	_peer = p;

	self.title = _peer ? [_peer name] : @"unknown peer";
	
	[_messages removeAllObjects];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return _messages.count ? _messages.count : 1;
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
	if(_messages.count)
	{
		F1MessageItem* item = [_messages objectAtIndex:indexPath.row];
		cell.textLabel.text = [item message];
	}
	else
	{
		cell.textLabel.text = @"no message";
	}
	
    return cell;
}

@end
