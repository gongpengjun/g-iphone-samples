//
//  PasswordKeeper.h
//

#import <UIKit/UIKit.h>

@interface PasswordKeeper : NSObject

+ (PasswordKeeper *) sharedPasswordKeeper;
- (BOOL) setPassword: (NSString *) password;
- (NSString *) fetchPassword;

@end
