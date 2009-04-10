//
//  BookReaderViewController.h
//

#import <UIKit/UIKit.h>

@interface BookReaderViewController : UIViewController <UIWebViewDelegate>
{
	UIWebView	*myWebView;
	NSString    *bookPath;
}

+ (id)sharedInstance;

@property (nonatomic,retain) NSString *bookPath;

@end
