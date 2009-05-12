//
//  BookReaderViewController.h
//

#import <UIKit/UIKit.h>

@class Book,MyWebView;

@interface BookReaderViewController : UIViewController <UIWebViewDelegate>
{
	MyWebView	* myWebView;
	Book        * book;
	NSTimer     * naviHideTimer;
}

+ (id)sharedInstance;

@property (nonatomic,retain) Book		* book;
@property (nonatomic,retain) NSTimer	* naviHideTimer;

@end
