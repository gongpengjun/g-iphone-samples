
#import "ServerViewController.h"
#import "BLIP.h"


@implementation ServerViewController

@synthesize label;

- (void)loadView
{
	[super loadView];

	UIView *contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	[contentView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
	self.view = contentView;
	[contentView release];
	
	label = [[UITextView alloc] initWithFrame:CGRectMake(10,20,300,60)];
	label.backgroundColor = [UIColor lightGrayColor];
	label.textAlignment = UITextAlignmentCenter;
	label.font = [UIFont systemFontOfSize:18];
	label.editable = NO;
	[self.view addSubview:label];
}

- (void)viewDidLoad 
{
	self.title = @"BLIP Echo Server";
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];	
    
    label.text = @"Opening listener socket...";

    _listener = [[BLIPListener alloc] initWithPort: 12345];
    _listener.delegate = self;
    _listener.pickAvailablePort = YES;
    _listener.bonjourServiceType = @"_blipecho._tcp";
    [_listener open];
}

- (void)dealloc 
{
	[label release];
    
    [_listener close];
    [_listener release];
	[super dealloc];
}


#pragma mark BLIP Listener Delegate:

- (void) listenerDidOpen: (TCPListener*)listener
{
    label.text = [NSString stringWithFormat: @"Listening on port %i",listener.port];
}

- (void) listener: (TCPListener*)listener failedToOpen: (NSError*)error
{
    label.text = [NSString stringWithFormat: @"Failed to open listener on port %i: %@",
                  listener.port,error];
}

- (void) listener: (TCPListener*)listener didAcceptConnection: (TCPConnection*)connection
{
    label.text = [NSString stringWithFormat: @"Accepted connection from %@",
                  connection.address];
    connection.delegate = self;
}

- (void) connection: (TCPConnection*)connection failedToOpen: (NSError*)error
{
    label.text = [NSString stringWithFormat: @"Failed to open connection from %@: %@",
                  connection.address,error];
}

- (void) connection: (BLIPConnection*)connection receivedRequest: (BLIPRequest*)request
{
    NSString *message = [[NSString alloc] initWithData: request.body encoding: NSUTF8StringEncoding];
    label.text = [NSString stringWithFormat: @"Echoed:\n“%@”",message];
    [request respondWithData: request.body contentType: request.contentType];
}

- (void) connectionDidClose: (TCPConnection*)connection;
{
    label.text = [NSString stringWithFormat: @"Connection closed from %@",
                  connection.address];
}


@end
