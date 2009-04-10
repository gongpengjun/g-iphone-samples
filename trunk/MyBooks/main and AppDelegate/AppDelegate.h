//
//  AppDelegate.h
//

#import <UIKit/UIKit.h>

@class BookListViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow				*window;
	BookListViewController  *rootViewController;
	UINavigationController	*navigationController;
}

@property (nonatomic, retain) UIWindow					*window;
@property (nonatomic, retain) UINavigationController	*navigationController;
@property (nonatomic, retain) BookListViewController    *rootViewController;

@end

