//
//  MessageEntryView.h
//  p2pChat
//
//  Created by Frank Gong on 5/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MessageEntryView : UIView 
{
	UIImage		* _bgImage;
	UITextField * _textField;
	UIButton	* _sendButton;
}

@property (nonatomic,retain) UITextField * textField;
@property (nonatomic,retain) UIButton	 * sendButton;

@end
