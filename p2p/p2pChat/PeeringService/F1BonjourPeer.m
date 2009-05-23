//
//  F1BonjourPeer.m
//  p2pChat
//
//  Created by Frank Gong on 5/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "F1BonjourPeer.h"

@implementation F1BonjourPeer

@synthesize service = _service;

- (void)dealloc
{
	[_service release];
	[super dealloc];
}

- (id)initWithNetService:(NSNetService*)service
{
	if (self = [super init]) 
	{
		_service = [service retain];
		_itemsBeingSentByConnection = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
	}
	
	return self;
}

- (NSString*)name
{
	return [_service name];
}

- (BOOL)sendItem:(F1Item*)item toPeer:(F1Peer*)peer
{
	if (CFDictionaryContainsValue(_itemsBeingSentByConnection, item))
		return NO;
	
	BLIPConnection* connection = [[BLIPConnection alloc] initToNetService:_service];
	[connection open];
	
	CFDictionarySetValue(_itemsBeingSentByConnection, connection, item);
	
	[peer.delegate willSendItem:item toPeer:peer];
	
	connection.delegate = (F1BonjourPeer*)peer;
	BLIPRequest* request = [item contentsAsBLIPRequest];
	[connection sendRequest:request];
	[connection release];
	
	return YES;
}

- (void)connection:(BLIPConnection*)connection receivedResponse:(BLIPResponse*)response
{
	F1Item* item = (F1Item*) CFDictionaryGetValue(_itemsBeingSentByConnection, connection);
	if (item) [delegate didSendItem:item toPeer:self];
	[connection close];
}

- (void)connectionDidClose:(TCPConnection*)connection
{
	NSLog(@"%@", connection);
	CFDictionaryRemoveValue(_itemsBeingSentByConnection, connection);
}

- (void)connection:(TCPConnection*)connection failedToOpen:(NSError*)error
{
	NSLog(@"%@, %@", connection, error);
	CFDictionaryRemoveValue(_itemsBeingSentByConnection, connection);
}

- (BOOL)connectionReceivedCloseRequest:(BLIPConnection*)connection
{
	NSLog(@"%@", connection);
	return YES;
}

- (void)connection:(BLIPConnection*)connection closeRequestFailedWithError:(NSError*)error
{
	NSLog(@"%@, %@", connection, error);
	[connection close];
}

@end
