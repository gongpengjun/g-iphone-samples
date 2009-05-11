//
//  AppDelegate.h
//

#import <UIKit/UIKit.h>

@class FileBrowserViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	@private
    UIWindow				*window;
	UIViewController		*rootViewController;
	UINavigationController	*navigationController;

	UIWindow                *progressIndicatorWindow;
	UIActivityIndicatorView *progressIndicatorView;
}

@property (nonatomic, retain) UIWindow					*window;
@property (nonatomic, retain) UINavigationController	*navigationController;
@property (nonatomic, retain) UIViewController			*rootViewController;

@end

