//
//  Book.h
//

#import <UIKit/UIKit.h>


@interface Book : NSObject 
{
	NSString *title;
	NSString *name;
	NSString *basePath;
}

@property (nonatomic,retain) NSString *title;
@property (nonatomic,retain) NSString *name;
@property (nonatomic,retain) NSString *basePath;

@end
