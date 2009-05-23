//
//  p2pChatAppDelegate.m
//  p2pChat
//
//  Created by Frank Gong on 5/18/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "AppDelegate.h"
#import "PeerListViewController.h"

#import "F1MessageItem.h"
#import "F1BonjourPeeringService.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;
@synthesize navigationController = _navigationController;
@synthesize peerListViewController = _peerListViewController;
@synthesize peers = _peers;

#pragma mark -
#pragma mark Application lifecycle

- (void)dealloc 
{
	[_peers release];
	[_peerListViewController release];
	[_navigationController release];
	[_tabBarController release];
	[_window release];
	[super dealloc];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{
	[F1MessageItem registerClass];
	_peers = [[NSMutableArray alloc] initWithCapacity:1];
	F1BonjourPeeringService * peerFinder = [F1BonjourPeeringService sharedService];
	peerFinder.delegate = self;
	[peerFinder start];
	
	_window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	_window.backgroundColor = [UIColor groupTableViewBackgroundColor];
	
	_peerListViewController = [[PeerListViewController alloc] init];
	_navigationController = [[UINavigationController alloc] initWithRootViewController:_peerListViewController];
	
	_chatViewController = [ChatViewController sharedChatViewController];
	
	[_window addSubview:[_navigationController view]];
    [_window makeKeyAndVisible];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
}

#pragma mark -
#pragma mark F1PeerDiscoveryDelegate method

- (void) peerFound:(F1Peer*)peer
{
	peer.delegate = self;
	[_peerListViewController addPeer:peer];
}

- (void) peerLeft:(F1Peer*)peer
{
	[_peerListViewController removePeer:peer];
}

#pragma mark -
#pragma mark F1PeerDelegate method

- (void)willSendItem:(F1Item*)item toPeer:(F1Peer*)peer
{
	NSLog(@"%s%@",__FUNCTION__,peer);
}

- (void)didSendItem:(F1Item*)item toPeer:(F1Peer*)peer
{
	NSLog(@"%s%@",__FUNCTION__,peer);
}

- (void)willReceiveItemFromPeer:(F1Peer*)peer
{
	NSLog(@"%s%@",__FUNCTION__,peer);
}

- (void)didReceiveItem:(F1Item*)item fromPeer:(F1Peer*)peer
{
	NSLog(@"%s%@",__FUNCTION__,peer);
	if([_chatViewController isEqual:_navigationController.topViewController])
	{
		if([peer isEqual:_chatViewController.peer])
		{
			//It is fine. goto END;
		}
		else
		{
			_chatViewController.peer = (F1BonjourPeer*)peer;
		}
	}
	else
	{
		_chatViewController.peer = (F1BonjourPeer*)peer;
		[_navigationController pushViewController:_chatViewController animated:YES];
	}
END:	
	[_chatViewController didReceiveItem:item fromPeer:peer];
}

- (void)cancelledReceiveItemFromPeer:(F1Peer*)peer
{
	NSLog(@"%s%@",__FILE__,__FUNCTION__,peer);
}

@end

