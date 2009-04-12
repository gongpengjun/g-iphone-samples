//
//  BookShareViewController.h
//

#import <UIKit/UIKit.h>
#import "HTTPServer.h"

@interface BookShareViewController : UITableViewController <HTTPServerDelegate>
{
	UIBarButtonItem *startButton;
	UIBarButtonItem *stopButton;
	
	HTTPServerStatus status;
	HTTPServer      *httpServer;
}

@end
