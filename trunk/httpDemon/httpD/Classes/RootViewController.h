//
//  RootViewController.h
//

#import <UIKit/UIKit.h>

@class HTTPServer;
@protocol HTTPServerDelegate;

@interface RootViewController : UITableViewController <HTTPServerDelegate>
{
	HTTPServer *httpServer;
	
	UIBarButtonItem *startButton;
	UIBarButtonItem *stopButton;
}

@end
