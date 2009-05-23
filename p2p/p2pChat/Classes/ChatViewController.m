//
//  InteractViewController.m
//  BLIPClient
//
//  Created by Frank Gong on 5/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ChatViewController.h"
#import "TextFieldCell.h"

#define kStdButtonWidth			60.0
#define kStdButtonHeight		30.0
@interface F1TextField : UITextField
@end

@implementation F1TextField
- (CGRect)textRectForBounds:(CGRect)bounds
{
	CGRect rect = bounds;
	rect.size.width -= kStdButtonWidth;
	return rect;
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds
{
	CGRect rect = bounds;
	rect.origin.x = rect.size.width - kStdButtonWidth;
	rect.size = CGSizeMake(kStdButtonWidth,kStdButtonHeight);
	return rect;
}
@end

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
		self.title = @"unknown peer";
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
	
	_requestTextFiled = [[F1TextField alloc] initWithFrame:CGRectZero];
	_requestTextFiled.font = [UIFont systemFontOfSize:22];
	_requestTextFiled.borderStyle = UITextBorderStyleRoundedRect;
	_requestTextFiled.returnKeyType = UIReturnKeySend;
	_requestTextFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
	_requestTextFiled.placeholder = @"enter text here";
	_requestTextFiled.delegate = self;
	
	UIButton *sendButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
	sendButton.frame = CGRectMake(0.0, 0.0, kStdButtonWidth, kStdButtonHeight);
	[sendButton setTitle:@"Send" forState:UIControlStateNormal];
	sendButton.backgroundColor = [UIColor clearColor];
	[sendButton addTarget:self action:@selector(sendAction) forControlEvents:UIControlEventTouchUpInside];
	
	_requestTextFiled.rightView = sendButton;
	_requestTextFiled.rightViewMode = UITextFieldViewModeAlways;
}

- (void)sendText:(NSString*)msg
{
	if(msg.length == 0) return;
	F1MessageItem * msgItem = [[F1MessageItem alloc] initWithMessage:msg];
	msgItem.direction = F1MessageItemDirectionSent;
	[_peer sendItem:msgItem toPeer:_peer];
	[_messages addObject:msgItem];
	[self.tableView reloadData];
	[msgItem release];
}

- (void)sendAction
{
	[self sendText:_requestTextFiled.text];
	[_requestTextFiled resignFirstResponder];
	_requestTextFiled.text = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[self sendText:textField.text];
	[textField resignFirstResponder];
	textField.text = nil;
	return YES;
}

- (void)didReceiveItem:(F1Item*)item fromPeer:(F1Peer*)peer
{
	F1MessageItem * msgItem = (F1MessageItem *)item;
	msgItem.direction = F1MessageItemDirectionReceived;
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
    return _messages.count + 1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	UITableViewCell *cell = nil;
	NSInteger row = [indexPath row];
	
	if (row == _messages.count) 
	{
		cell = [self.tableView dequeueReusableCellWithIdentifier:kCellTextField_ID];
		if (cell == nil) 
			cell = [[[TextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellTextField_ID] autorelease];
	}
	else 
	{
		static NSString *kGenericCell_ID = @"GenericCell";
		cell = [self.tableView dequeueReusableCellWithIdentifier:kGenericCell_ID];
		if (cell == nil) 
		{
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kGenericCell_ID] autorelease];			
			// turn off selection use
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
	}

	// Configure the cell.		
	if(row == _messages.count)
	{
		((TextFieldCell *)cell).textField = _requestTextFiled;
	}
	else
	{
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
	}
	
    return cell;
}

@end
