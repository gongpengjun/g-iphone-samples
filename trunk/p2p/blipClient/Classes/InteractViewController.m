//
//  InteractViewController.m
//  BLIPClient
//
//  Created by Frank Gong on 5/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "InteractViewController.h"
#import "BLIP.h"
#import "Target.h"

@implementation InteractViewController

@synthesize netService;

InteractViewController * _sharedInteractViewController = nil;
+ (InteractViewController*)sharedInteractViewController
{
	if(!_sharedInteractViewController)
		_sharedInteractViewController = [[InteractViewController alloc] init];
	return _sharedInteractViewController;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];
	
	UIView *contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	[contentView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
	self.view = contentView;
	[contentView release];
	
	_reponseLabel                   = [[UILabel alloc] initWithFrame:CGRectMake(10,0,300,30)];
	_reponseLabel.textAlignment		= UITextAlignmentCenter;
	_reponseLabel.opaque            = NO;
	_reponseLabel.backgroundColor   = nil;
	[self.view addSubview:_reponseLabel];
	
	_requestTextFiled = [[UITextField alloc] initWithFrame:CGRectMake(10,35,300,25)];
	_requestTextFiled.backgroundColor = [UIColor whiteColor];
	_requestTextFiled.returnKeyType = UIReturnKeySend;
	_requestTextFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
	_requestTextFiled.placeholder = @"enter BLIP request here";
	_requestTextFiled.delegate = self;
	[self.view addSubview:_requestTextFiled];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = [NSString stringWithFormat:@"Interact with %@",[netService name]];
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
}

/* Opens a BLIP connection to the given address. */
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _connection = [[BLIPConnection alloc] initToNetService: netService];
    if( _connection )
        [_connection open];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	/* Send a BLIP request containing the string in the textfield */
    BLIPRequest *r = [_connection request];
    r.bodyString = textField.text;
    BLIPResponse *response = [r send];
    response.onComplete = $target(self,gotResponse:);
	
	[textField resignFirstResponder];
	return YES;
}

/* Receive the response to the BLIP request, and put its contents into the response field */
- (void) gotResponse: (BLIPResponse*)response
{
	_reponseLabel.text = response.bodyString;
}    

- (void)viewWillDisappear:(BOOL)animated {
	 [super viewWillDisappear:animated];
	 
	 /* Closes the currently open BLIP connection. */
	 [_connection close];
	 [_connection release];
	 _connection = nil;
}

- (void)dealloc {
	[netService release]; 
	[_connection release];
	[_requestTextFiled release];
	[_reponseLabel release];
    [super dealloc];
}


@end
