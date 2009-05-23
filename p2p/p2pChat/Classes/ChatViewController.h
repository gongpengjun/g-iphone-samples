//
//  InteractViewController.h
//  BLIPClient
//
//  Created by Frank Gong on 5/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "F1BonjourPeer.h"
#import "F1MessageItem.h"

@interface ChatViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate> 
{
	F1BonjourPeer		* _peer;
	UITextField			* _requestTextFiled;
	NSMutableArray      * _messages;
	UITableView			* _tableView;
}

@property (nonatomic, retain) F1BonjourPeer	* peer;
@property (nonatomic, retain) UITableView	* tableView;

+ (ChatViewController*)sharedChatViewController;

- (void)didReceiveItem:(F1Item*)item fromPeer:(F1Peer*)peer;

@end
