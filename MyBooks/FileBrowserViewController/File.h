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

- (BOOL)create;
- (BOOL)delete;
- (BOOL)renameTo:(NSString*)newName;
- (BOOL)moveToDirectory:(NSString*)newParentDirectory;

@end
