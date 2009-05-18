//
//  RootViewController.h
//  BLIPClient
//
//  Created by Frank Gong on 5/17/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

@interface RootViewController : UITableViewController {
    NSNetServiceBrowser * _serviceBrowser;
    NSMutableArray		* _serviceList;
}

@end
