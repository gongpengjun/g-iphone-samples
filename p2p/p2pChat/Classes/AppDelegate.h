//
//  p2pChatAppDelegate.h
//  p2pChat
//
//  Created by Frank Gong on 5/18/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "F1PeerDiscovery.h"
#import "PeerListViewController.h"
#import "ChatViewController.h"

@interface AppDelegate : NSObject <UIApplicationDelegate,F1PeerDiscoveryDelegate,F1PeerDelegate> 
{
	@private
    UIWindow			   * _window;
	
	UITabBarController     * _tabBarController;
	
    UINavigationController * _navigationController;
	PeerListViewController * _peerListViewController;
	ChatViewController	   * _chatViewController;
    NSMutableArray		   * _peers;
}

@property (nonatomic, retain) UIWindow				 * window;
@property (nonatomic, retain) UITabBarController     * tabBarController;
@property (nonatomic, retain) UINavigationController * navigationController;
@property (nonatomic, retain) PeerListViewController * peerListViewController;
@property (nonatomic, retain) NSMutableArray		 * peers;

@end

