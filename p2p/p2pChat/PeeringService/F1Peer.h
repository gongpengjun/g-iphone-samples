//
//  F1Peer.h
//  p2pChat
//
//  Created by Frank Gong on 5/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "F1Item.h"

@protocol F1PeerDelegate;

@interface F1Peer : NSObject 
{
	id <F1PeerDelegate>	delegate;
}

@property(nonatomic,readonly)	NSString			* name;
@property(nonatomic,assign)		id <F1PeerDelegate>	  delegate;

- (BOOL)sendItem:(F1Item*)item toPeer:(F1Peer*)peer;

@end

@protocol F1PeerDelegate <NSObject>

- (void) willSendItem:(F1Item*)item toPeer:(F1Peer*)peer;
- (void) didSendItem:(F1Item*)item toPeer:(F1Peer*)peer;

- (void) willReceiveItemFromPeer:(F1Peer*)peer;
- (void) didReceiveItem:(F1Item*)item fromPeer:(F1Peer*)peer;
- (void) cancelledReceiveItemFromPeer:(F1Peer*)peer;

@end
