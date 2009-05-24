//
//  InteractViewController.h
//  BLIPClient
//
//  Created by Frank Gong on 5/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "F1BonjourPeer.h"
#import "F1MessageItem.h"
#import "MessageEntryView.h"

@interface ChatViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate> 
{
	F1BonjourPeer		* _peer;
	MessageEntryView	* _msgEntryView;
	NSMutableArray      * _messages;
	UITableView			* _tableView;
}

@property (nonatomic, retain) F1BonjourPeer		* peer;
@property (nonatomic, retain) UITableView		* tableView;
@property (nonatomic, retain) MessageEntryView	* msgEntryView;

+ (ChatViewController*)sharedChatViewController;

- (void)didReceiveItem:(F1Item*)item fromPeer:(F1Peer*)peer;

@end
