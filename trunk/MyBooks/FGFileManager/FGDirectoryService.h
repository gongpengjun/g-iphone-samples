//
//  FGDirectoryService.h
//

#import <UIKit/UIKit.h>

@interface FGDirectoryService : NSObject

+ (void)establishRootDirectory;
+ (NSString*)rootDirectory;
+ (NSString*)fullPathOfFile:(NSString*)file;

@end
