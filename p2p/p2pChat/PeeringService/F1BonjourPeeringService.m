//
//  F1BonjourPeeringService.m
//  p2pChat
//
//  Created by Frank Gong on 5/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "F1BonjourPeeringService.h"
#import "F1BonjourPeer.h"

#import "BLIP.h"
#import "IPAddress.h"
#import <netinet/in.h>
#import <sys/types.h>
#import <sys/socket.h>
#import <ifaddrs.h>

@interface IPAddress (F1BonjourPeeringService)
- (BOOL) _f1_comesFromAddressOfService:(NSNetService*)s;
@end

@implementation IPAddress (F1BonjourPeerFinder_NetServicesMatching)

- (BOOL) _f1_comesFromAddressOfService:(NSNetService*)service
{
	for(NSData* addressData in [service addresses])
	{
		const struct sockaddr* s = [addressData bytes];
		if (s->sa_family == AF_INET) 
		{
			const struct sockaddr_in* sIPv4 = (const struct sockaddr_in*)s;
			if (self.ipv4 == sIPv4->sin_addr.s_addr)
				return YES;
		}
	}
	return NO;
}

@end

@implementation F1BonjourPeeringService

@synthesize delegate;

+ (F1BonjourPeeringService*)sharedService
{
	static F1BonjourPeeringService *s_sharedF1BonjourPeeringService = nil;
	if(!s_sharedF1BonjourPeeringService)
	{
		s_sharedF1BonjourPeeringService = [[F1BonjourPeeringService alloc] init];
	}
	return s_sharedF1BonjourPeeringService;
}

- (void) start
{
	if (browser)
		return;
	
	peers = [[NSMutableSet alloc] initWithCapacity:1];
	
	browser = [[NSNetServiceBrowser alloc] init];
	[browser setDelegate:self];
	[browser searchForServicesOfType:kF1BonjourPeeringServiceName inDomain:@""];
	
	listener = [[BLIPListener alloc] initWithPort:0];//let kernel select a port for us
	listener.delegate = self;
	listener.pickAvailablePort = YES;
	listener.bonjourServiceType = kF1BonjourPeeringServiceName;
	listener.bonjourServiceName = [UIDevice currentDevice].name;
	[listener open];
}

- (void) stop
{	
	[browser stop];
	[browser release]; browser = nil;
	
	for (F1BonjourPeer* peer in peers)
		[delegate peerLeft:peer];
	
	[peers release]; peers = nil;
	
	[listener close];
	[listener release]; listener = nil;	
}

- (void) dealloc
{
	[self stop];
	[super dealloc];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
	F1BonjourPeer* leavingPeer = nil;
	for (F1BonjourPeer* peer in peers)
	{
		if ([peer.service isEqual:aNetService]) 
		{
			leavingPeer = peer;
			break;
		}
	}
	
	if (leavingPeer) 
	{
		[[leavingPeer retain] autorelease];
		[peers removeObject:leavingPeer];
		[delegate peerLeft:leavingPeer];
	}
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
	[aNetService retain];
	[aNetService setDelegate:self];
	[aNetService resolve];
}

- (void)netServiceDidResolveAddress:(NSNetService *)aNetService
{
	[aNetService autorelease];
	
	BOOL isSelf = NO;
	struct ifaddrs* interface;
	
	if (getifaddrs(&interface) == 0) 
	{
		struct ifaddrs* allInterfaces = interface;
		while (interface != NULL) 
		{
			const struct sockaddr_in* address = (const struct sockaddr_in*) interface->ifa_addr;
			if (address->sin_family != AF_INET)
			{
				interface = interface->ifa_next;
				continue;
			}
			
			for (NSData* serviceAddressData in [aNetService addresses]) 
			{
				const struct sockaddr_in* serviceAddress = [serviceAddressData bytes];
				if (!serviceAddress->sin_family == AF_INET) continue;
				
				if (serviceAddress->sin_addr.s_addr == address->sin_addr.s_addr) 
				{
					isSelf = YES;
					break;
				}
			}
			
			if (isSelf) break;
			interface = interface->ifa_next;
		}
		
		freeifaddrs(allInterfaces);
	}
	
	if (isSelf) return;
	
	F1BonjourPeer* peer = [[F1BonjourPeer alloc] initWithNetService:aNetService];
	[peers addObject:peer];
	[delegate peerFound:peer];
	[peer release];
}

- (F1BonjourPeer*)peerForAddress:(IPAddress*)a
{
	for (F1BonjourPeer* peer in peers) 
	{
		if ([a _f1_comesFromAddressOfService:peer.service])
			return peer;
	}
	return nil;
}

- (void)listener:(TCPListener*)listener didAcceptConnection:(TCPConnection*)connection
{
	F1BonjourPeer* peer = [self peerForAddress:connection.address];
	if (!peer) 
	{
		NSLog(@"Connection comes from unknown peer.");
		[connection close];
		return;
	}
	
	[peer.delegate willReceiveItemFromPeer:peer];
	[connection setDelegate:self];
}

- (void)connection:(BLIPConnection*)connection receivedRequest:(BLIPRequest*)request
{
	F1BonjourPeer* peer = [self peerForAddress:connection.address];
	if (!peer)
	{
		NSLog(@"Connection comes from unknown peer.");
		[connection close];
		return;
	}
	
	F1Item* item = [F1Item itemWithContentsOfBLIPRequest:request];
	if (!item) 
	{
		NSLog(@"request is invalid, consider it as canceling.");
		[connection close];
		[peer.delegate cancelledReceiveItemFromPeer:peer];
		return;
	}
	
	[connection close];
	[request respondWithString:@"OK"];
	[peer.delegate didReceiveItem:item fromPeer:peer];
}

@end
