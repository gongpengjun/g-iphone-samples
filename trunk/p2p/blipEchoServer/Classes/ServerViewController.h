
#import <UIKit/UIKit.h>
#import "BLIPConnection.h"

@interface ServerViewController : UIViewController <UITextFieldDelegate, 
                                                TCPListenerDelegate,
                                                BLIPConnectionDelegate> 
{
	UITextView *label;

    BLIPListener *_listener;
}

@property (nonatomic, retain) UITextView *label;

@end

