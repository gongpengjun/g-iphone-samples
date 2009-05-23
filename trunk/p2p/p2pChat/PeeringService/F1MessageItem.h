//
//  F1MessageItem.h
//  p2pChat
//
//  Created by Frank Gong on 5/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "F1Item.h"

@interface F1MessageItem : F1Item
{
	@private
	NSString *message;
}

@property (nonatomic,copy) NSString *message;

- (id) initWithMessage:(NSString*)msg;

@end
