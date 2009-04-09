//
//  RootViewController.h
//

#import <UIKit/UIKit.h>
#import "HTTPServer.h"

@interface RootViewController : UITableViewController <HTTPServerDelegate>
{
	UIBarButtonItem *startButton;
	UIBarButtonItem *stopButton;

	HTTPServerStatus status;
	HTTPServer      *httpServer;
}

@end
