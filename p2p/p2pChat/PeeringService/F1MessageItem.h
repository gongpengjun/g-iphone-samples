//
//  F1MessageItem.h
//  p2pChat
//
//  Created by Frank Gong on 5/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "F1Item.h"

enum {
    F1MessageItemDirectionSent		= 0,
    F1MessageItemDirectionReceived	= 1 << 0
};
typedef NSUInteger F1MessageItemDirection;

@interface F1MessageItem : F1Item
{
	@private
	NSString *message;
	F1MessageItemDirection direction;
}

@property (nonatomic,copy) NSString *message;
@property (nonatomic,assign) F1MessageItemDirection direction;

- (id) initWithMessage:(NSString*)msg;

@end
