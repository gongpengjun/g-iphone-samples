//
//  ChatContentView.h
//  p2pChat
//
//  Created by Frank Gong on 5/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatViewController.h"

@interface ChatContentView : UIView 
{
	ChatViewController * _chatViewController;
}

@property (nonatomic,assign) ChatViewController * chatViewController;

@end
