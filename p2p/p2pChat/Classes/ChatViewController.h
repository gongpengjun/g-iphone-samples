//
//  InteractViewController.h
//  BLIPClient
//
//  Created by Frank Gong on 5/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

@class BLIPConnection;

@interface ChatViewController : UIViewController <UITextFieldDelegate> 
{	
	NSNetService		* netService;
    BLIPConnection		* _connection;
	
	UITextField			* _requestTextFiled;
	UILabel				* _reponseLabel;
}

@property (nonatomic, retain) NSNetService *netService;

+ (ChatViewController*)sharedChatViewController;

@end
