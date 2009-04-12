//
//  AppDelegate.h
//

#import <UIKit/UIKit.h>

@class FileBrowserViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow					*window;
	FileBrowserViewController	*rootViewController;
	UINavigationController		*navigationController;
}

@property (nonatomic, retain) UIWindow					*window;
@property (nonatomic, retain) UINavigationController	*navigationController;
@property (nonatomic, retain) FileBrowserViewController *rootViewController;

@end

