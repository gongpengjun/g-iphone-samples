//
//  RootViewController.h
//  BLIPClient
//
//  Created by Frank Gong on 5/17/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "F1BonjourPeer.h"

@interface PeerListViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>
{
	UITableView			* _tableView;
}

@property (nonatomic, retain) UITableView	* tableView;

- (void)addPeer:(F1Peer*)peer;
- (void)removePeer:(F1Peer*)peer;

@end
