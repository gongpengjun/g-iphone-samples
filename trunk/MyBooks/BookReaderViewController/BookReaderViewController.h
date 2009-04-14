//
//  BookReaderViewController.h
//

#import <UIKit/UIKit.h>

@class Book,MyWebView;

@interface BookReaderViewController : UIViewController <UIWebViewDelegate>
{
	MyWebView	*myWebView;
	Book        *book;
}

+ (id)sharedInstance;

@property (nonatomic,retain) Book *book;

@end
