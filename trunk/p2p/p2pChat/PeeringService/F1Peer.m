//
//  F1Peer.m
//  p2pChat
//
//  Created by Frank Gong on 5/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "F1Peer.h"

@implementation F1Peer

@synthesize delegate;
@dynamic	name;

- (BOOL)sendItem:(F1Item*)item toPeer:(F1Peer*)peer
{
	NSAssert(NO, @"Abstract method. Subclasses must override it.");
	return NO;
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"%@ { %@ }", [super description], self.name];
}

@end
