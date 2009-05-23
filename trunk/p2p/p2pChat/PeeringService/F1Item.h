//
//  F1Item.h
//  p2pChat
//
//  Created by Frank Gong on 5/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <stdint.h>
#import "BLIP.h"

@interface F1Item : NSObject 
{
	NSString* title;
	NSString* type;
}

@property(nonatomic,copy) NSString* title;
@property(nonatomic,copy) NSString* type;

+ (void)registerClass;
+ (void)registerClass:(Class)c forType:(NSString*)type;
+ (Class)classForType:(NSString*)c;

// Funnels
+ (NSArray*)supportedTypes;
- (NSData*)externalRepresentation;
- (id)initWithExternalRepresentation:(NSData*)payload type:(NSString*)type title:(NSString*)title;

- (void) store;

@end


@interface F1Item (BLIPTransportSupport)

- (BLIPRequest*)contentsAsBLIPRequest;
+ (id)itemWithContentsOfBLIPRequest:(BLIPRequest*)req;

@end
