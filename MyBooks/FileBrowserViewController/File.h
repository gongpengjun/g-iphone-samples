//
//  File.h
//

#import <Foundation/Foundation.h>


@interface File : NSObject 
{
	BOOL       isDirectory;
	NSString * name;
	NSString * parentDirectory;
}

@property (assign)           BOOL       isDirectory;
@property (nonatomic,retain) NSString * name;
@property (nonatomic,retain) NSString * parentDirectory;

+ (UIImage*)folderImage;
+ (UIImage*)fileImage;

@end
