//
//  F1MessageItem.m
//  p2pChat
//
//  Created by Frank Gong on 5/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "F1MessageItem.h"
#import <MobileCoreServices/MobileCoreServices.h>

@implementation F1MessageItem

@synthesize message,direction;

- (void) dealloc
{
	[message release];
	[super dealloc];
}

- (id)initWithMessage:(NSString*)msg
{
	if (self = [super init])
	{
		self.message = msg;
		self.title = @"dummytitle";
		self.type = (NSString*)kUTTypeMessage;
	}
	return self;
}

+ (NSArray*) supportedTypes
{
	return [NSArray arrayWithObject:(NSString*)kUTTypeMessage];
}

- (NSData*)externalRepresentation
{
	return [self.message dataUsingEncoding:NSUTF8StringEncoding];
}

- (id)initWithExternalRepresentation:(NSData*)payload type:(NSString*)type title:(NSString*)title
{
	NSString* msg = [[[NSString alloc] initWithData:payload encoding:NSUTF8StringEncoding] autorelease];
	return [self initWithMessage:msg];
}

- (void) store;
{
}

@end
