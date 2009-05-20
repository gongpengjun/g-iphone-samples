//
//  RootViewController.h
//  BLIPClient
//
//  Created by Frank Gong on 5/17/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//
#import "BLIPConnection.h"

@interface UserListViewController : UIViewController <	UITextFieldDelegate,
														UITableViewDelegate, UITableViewDataSource,
														TCPListenerDelegate,BLIPConnectionDelegate >
{
	UITableView			* _tableView;
	
	UITextView			* _label;
    BLIPListener		* _listener;

    NSNetServiceBrowser * _serviceBrowser;
    NSMutableArray		* _serviceList;
}

@property (nonatomic, retain) UITextView  * label;
@property (nonatomic, retain) UITableView * tableView;

@end
