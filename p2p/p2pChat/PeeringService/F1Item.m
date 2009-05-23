//
//  F1Item.m
//  p2pChat
//
//  Created by Frank Gong on 5/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "F1Item.h"

@implementation F1Item

@synthesize title,type;

static NSMutableDictionary* s_registeredClasses = nil;

+ (void)registerClass
{
	for (NSString* type in [self supportedTypes])
		[self registerClass:self forType:type];
}

+ (void)registerClass:(Class)c forType:(NSString*)type
{
	if (!s_registeredClasses)
		s_registeredClasses = [[NSMutableDictionary alloc] initWithCapacity:1];
	
	[s_registeredClasses setObject:c forKey:type];
}

+ (Class)classForType:(NSString*)c
{
	return [s_registeredClasses objectForKey:c];
}

+ (NSArray*)supportedTypes
{
	NSAssert(NO, @"Subclasses of F1Item must implement this method.");
	return nil;
}

- (id)initWithExternalRepresentation:(NSData*)payload type:(NSString*)type title:(NSString*)title
{
	NSAssert(NO, @"Subclasses of F1Item must implement this method.");
	return nil;
}

- (NSData*) externalRepresentation
{
	NSAssert(NO, @"Subclasses of F1Item must implement this method.");
	return nil;
}

- (void)store
{
	// Overridden, optionally, by subclasses.
}

@end

@implementation F1Item (BLIPSupport)

- (BLIPRequest*)contentsAsBLIPRequest
{
	NSDictionary* properties = [NSDictionary dictionaryWithObjectsAndKeys:
								self.title, @"F1ItemTitle",
								self.type, @"F1ItemType",
								@"1", @"F1ItemWireProtocolVersion",
								nil];
	
	return [BLIPRequest requestWithBody:[self externalRepresentation] properties:properties];
}

+ (id)itemWithContentsOfBLIPRequest:(BLIPRequest*)request
{
	NSString* version = [request valueOfProperty:@"F1ItemWireProtocolVersion"];
	if (![version isEqualToString:@"1"]) return nil;
	
	NSString* type = [request valueOfProperty:@"F1ItemType"];
	if (!type) return nil;
	
	NSString* title = [request valueOfProperty:@"F1ItemTitle"];
	if (!title) return nil;
	
	Class c = [self classForType:type];
	if (!c) return nil;
	
	return [[[c alloc] initWithExternalRepresentation:request.body type:type title:title] autorelease];
}

@end
