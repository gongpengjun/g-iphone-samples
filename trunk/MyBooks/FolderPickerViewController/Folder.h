//
//  Folder.h
//

#import <Foundation/Foundation.h>


@interface Folder : NSObject {
@private
	NSUInteger level;
	NSString * name;
	NSString * parentFolder;
}

@property (nonatomic,assign) NSUInteger level;			// rootFolder's level == 0
@property (nonatomic,retain) NSString * name;			// folder name
@property (nonatomic,retain) NSString * parentFolder;	// absolute path

- (NSString *)description;

@end
