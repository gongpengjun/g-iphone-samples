//
//  F1BonjourPeer.h
//  p2pChat
//
//  Created by Frank Gong on 5/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "F1Peer.h"
#import "F1Item.h"
#import "BLIP.h"

@interface F1BonjourPeer : F1Peer <BLIPConnectionDelegate>
{
	NSNetService		 * _service;
	CFMutableDictionaryRef _itemsBeingSentByConnection;	
}

- (id)initWithNetService:(NSNetService*)service;

@property(nonatomic,readonly) NSNetService* service;

@end
