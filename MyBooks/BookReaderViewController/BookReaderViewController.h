//
//  BookReaderViewController.h
//

#import <UIKit/UIKit.h>

@class Book;

@interface BookReaderViewController : UIViewController <UIWebViewDelegate>
{
	UIWebView	*myWebView;
	Book        *book;
}

+ (id)sharedInstance;

@property (nonatomic,retain) Book *book;

@end
