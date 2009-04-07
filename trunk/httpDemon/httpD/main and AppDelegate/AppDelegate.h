//
//  AppDelegate.h
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow				*window;
	RootViewController		*rootViewController;
	UINavigationController	*navigationController;
}

@property (nonatomic, retain) UIWindow					*window;
@property (nonatomic, retain) UINavigationController	*navigationController;
@property (nonatomic, retain) RootViewController		*rootViewController;

@end

