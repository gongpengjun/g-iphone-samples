//
//  FGFileManager.h
//

#import <UIKit/UIKit.h>

@interface FGFileManager : NSObject

+ (void)establishBooksDirectory;
+ (NSString*)booksDirectory;
+ (NSString*)fullPathOfFile:(NSString*)file;

@end
