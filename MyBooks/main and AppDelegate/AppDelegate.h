//
//  AppDelegate.h
//

#import <UIKit/UIKit.h>

@class BookReaderViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow				*window;
	BookReaderViewController		*rootViewController;
	UINavigationController	*navigationController;
}

@property (nonatomic, retain) UIWindow					*window;
@property (nonatomic, retain) UINavigationController	*navigationController;
@property (nonatomic, retain) BookReaderViewController		*rootViewController;

@end

