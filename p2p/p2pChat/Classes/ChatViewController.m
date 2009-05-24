//
//  InteractViewController.m
//  BLIPClient
//
//  Created by Frank Gong on 5/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ChatViewController.h"
#import "ChatContentView.h"

@implementation ChatViewController

@synthesize peer = _peer, tableView = _tableView, msgEntryView = _msgEntryView;

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
	[_msgEntryView release];
	[_messages release];
	[_tableView release];
    [super dealloc];
}

- (id)init
{
	if(self = [super init])
	{
		self.title = @"unknown peer";
		_messages = [[NSMutableArray alloc] initWithCapacity:10];
	}
	return self;
}

- (void)loadView 
{
	[super loadView];
	
	CGRect frame = [[UIScreen mainScreen] applicationFrame];
	
	ChatContentView *contentView = [[ChatContentView alloc] initWithFrame:frame];
	[contentView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
	contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
	contentView.chatViewController = self;
	self.view = contentView;
	[contentView release];
	
	frame = self.view.bounds;
	frame.size.height = 416;
    _tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.backgroundColor = [UIColor lightGrayColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[_tableView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
	[self.view addSubview:_tableView];
	
	_msgEntryView = [[MessageEntryView alloc] init];
	frame = _msgEntryView.frame;
	//frame.origin.y = self.view.bounds.size.height - _msgEntryView.bounds.size.height;
	frame.origin.y = 375;
	_msgEntryView.frame = frame;
	_msgEntryView.textField.delegate = self;
	[_msgEntryView.sendButton addTarget:self action:@selector(sendAction) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_msgEntryView];
}

- (void)sendText:(NSString*)msg
{
	if(msg.length == 0) return;
	F1MessageItem * msgItem = [[F1MessageItem alloc] initWithMessage:msg];
	msgItem.direction = F1MessageItemDirectionSent;
	[_peer sendItem:msgItem toPeer:_peer];
	[_messages addObject:msgItem];
	[self.tableView reloadData];
	[_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_messages.count-1 inSection:0]
					  atScrollPosition:UITableViewScrollPositionBottom animated:NO];
	[msgItem release];
}

- (void)sendAction
{
	[self sendText:_msgEntryView.textField.text];
	//[_msgEntryView.textField resignFirstResponder];
	_msgEntryView.textField.text = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[self sendText:textField.text];
	//[textField resignFirstResponder];
	textField.text = nil;
	return YES;
}

- (void)didReceiveItem:(F1Item*)item fromPeer:(F1Peer*)peer
{
	F1MessageItem * msgItem = (F1MessageItem *)item;
	msgItem.direction = F1MessageItemDirectionReceived;
	[_messages addObject:item];
	[self.tableView reloadData];
	[_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_messages.count-1 inSection:0]
					  atScrollPosition:UITableViewScrollPositionBottom animated:NO];
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
    return _messages.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	static NSString *kGenericCell_ID = @"GenericCell";
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kGenericCell_ID];
	if (cell == nil) 
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kGenericCell_ID] autorelease];			
		// turn off selection use
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}

	F1MessageItem* msgItem = [_messages objectAtIndex:indexPath.row];
	cell.textLabel.text = [msgItem message];
	if(msgItem.direction == F1MessageItemDirectionReceived)
	{
		cell.textLabel.textAlignment = UITextAlignmentLeft;
		cell.textLabel.textColor = [UIColor redColor];
	}
	else
	{
		cell.textLabel.textAlignment = UITextAlignmentRight;
		cell.textLabel.textColor = [UIColor blueColor];
	}
	
    return cell;
}

#pragma mark Adjust view when keyboard show/hide

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification object:self.view.window];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)setViewWhileKeyboardMoveUp:(BOOL)up withKeyboardInfo:(NSDictionary *)kbInfo
{
	NSTimeInterval kbDuration = 1.0;
	[[kbInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&kbDuration];
	
	CGRect kbBounds = CGRectZero;
	[[kbInfo valueForKey:UIKeyboardBoundsUserInfoKey] getValue:&kbBounds];
	
	UIViewAnimationCurve kbCurve = UIViewAnimationCurveEaseIn;
	[[kbInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&kbCurve];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:kbDuration];
	[UIView setAnimationCurve:kbCurve];
	[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.view.window cache:YES];
	CGRect rect = self.view.frame;
	if(up)
		rect.size.height -= kbBounds.size.height;
	else
		rect.size.height += kbBounds.size.height;
	self.view.frame = rect;
	if(_messages.count)
		[_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_messages.count-1 inSection:0]
						  atScrollPosition:UITableViewScrollPositionBottom animated:NO];
	[UIView commitAnimations];
}

- (void)keyboardWillShow:(NSNotification *)notif
{
	NSDictionary * kbInfo = notif.userInfo;
	[self setViewWhileKeyboardMoveUp:YES withKeyboardInfo:kbInfo];
}

- (void)keyboardWillHide:(NSNotification *)notif
{
	NSDictionary * kbInfo = notif.userInfo;
	[self setViewWhileKeyboardMoveUp:NO withKeyboardInfo:kbInfo];
}

@end
