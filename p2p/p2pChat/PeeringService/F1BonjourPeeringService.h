//
//  F1BonjourPeeringService.h
//  p2pChat
//
//  Created by Frank Gong on 5/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "F1PeerDiscovery.h"
#import "BLIP.h"

//#define kF1BonjourPeeringServiceName @"_F1BonjourPeeringService._tcp."
#define kF1BonjourPeeringServiceName @"_blipecho._tcp."

@interface F1BonjourPeeringService : NSObject <TCPListenerDelegate, BLIPConnectionDelegate> 
{
	@private
	NSNetServiceBrowser				* browser;
	BLIPListener					* listener;
	NSMutableSet					* peers;
	id <F1PeerDiscoveryDelegate>	  delegate;
	NSMutableSet					* pendingConnections;
}

+ (F1BonjourPeeringService*)sharedService;

- (void) start;
- (void) stop;

@property(nonatomic,assign) id <F1PeerDiscoveryDelegate> delegate;

@end
