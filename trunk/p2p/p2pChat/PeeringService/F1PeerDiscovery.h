/*
 *  F1PeerDiscovery.h
 *  p2pChat
 *
 *  Created by Frank Gong on 5/21/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>
#import "F1Peer.h"

@protocol F1PeerDiscoveryDelegate <NSObject>

- (void) peerFound:(F1Peer*) peer;
- (void) peerLeft:(F1Peer*) peer;

@end