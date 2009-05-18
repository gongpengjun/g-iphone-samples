//
//  blipClientAppDelegate.h
//  blipClient
//
//  Created by Frank Gong on 5/18/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

@interface blipClientAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end

