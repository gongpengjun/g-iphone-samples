//
//  ChatContentView.m
//  p2pChat
//
//  Created by Frank Gong on 5/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ChatContentView.h"

@implementation ChatContentView

@synthesize chatViewController = _chatViewController;

- (void)layoutSubviews
{
	[super layoutSubviews];

	CGRect msgBounds = _chatViewController.msgEntryView.bounds;
	CGRect frame = self.bounds;
	
	frame.size.height -= msgBounds.size.height; 
	_chatViewController.tableView.frame = frame;
	
	frame = _chatViewController.msgEntryView.bounds;
	frame.origin.y = self.bounds.size.height - msgBounds.size.height;
	_chatViewController.msgEntryView.frame = frame;
}

@end
