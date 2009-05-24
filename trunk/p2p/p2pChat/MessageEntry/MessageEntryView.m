//
//  MessageEntryView.m
//  p2pChat
//
//  Created by Frank Gong on 5/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MessageEntryView.h"

@implementation MessageEntryView

@synthesize textField = _textField;
@synthesize sendButton = _sendButton;

- (void)dealloc
{
	[_bgImage release];
	[_textField release];
	[_sendButton release];
	[super dealloc];
}

- (id)init
{
	if(self = [super initWithFrame:CGRectZero])
	{
		_bgImage = [[UIImage imageNamed:@"MessageEntryBG.png"] retain];
		
		CGRect frame = CGRectMake(0,0,_bgImage.size.width,_bgImage.size.height);
		self.frame = frame;
		
		frame = CGRectMake(15,9,260,25);
		_textField = [[UITextField alloc] initWithFrame:frame];
		_textField.font = [UIFont systemFontOfSize:18];
		_textField.returnKeyType = UIReturnKeySend;
		_textField.clearButtonMode = UITextFieldViewModeWhileEditing;
		_textField.placeholder = @"enter text here";
		[self addSubview:_textField];
		
		_sendButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
		_sendButton.frame = CGRectMake(274, 8, 45, 25);
		[_sendButton setTitle:@"Send" forState:UIControlStateNormal];
		_sendButton.backgroundColor = [UIColor clearColor];
		[self addSubview:_sendButton];
	}
	return self;
}

- (void)drawRect:(CGRect)frame
{
	[_bgImage drawInRect:frame];
}

- (CGRect)bounds
{
	return CGRectMake(0,0,_bgImage.size.width,_bgImage.size.height);
}

@end
