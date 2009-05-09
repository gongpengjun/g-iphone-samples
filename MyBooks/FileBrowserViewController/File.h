//
//  File.h
//

#import <Foundation/Foundation.h>


@interface File : NSObject 
{
	NSString * name;
	NSString * parentDirectory;
	BOOL       isDirectory;
	BOOL       locked;
}

@property (nonatomic,retain) NSString * name;
@property (nonatomic,retain) NSString * parentDirectory;
@property (nonatomic,assign) BOOL       isDirectory;
@property (nonatomic,assign) BOOL       locked;

- (id)initWithParentDirectory:(NSString*)parentDir name:(NSString*)fileName;

+ (UIImage*)genericFolderImage;
+ (UIImage*)genericFileImage;

- (UIImage*)fileImage;

- (BOOL)create;
- (BOOL)delete;
- (BOOL)renameTo:(NSString*)newName;
- (BOOL)moveToDirectory:(NSString*)newParentDirectory;

@end
