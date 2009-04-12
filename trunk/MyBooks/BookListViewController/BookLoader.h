//
//  BookLoader.h
//

#import <UIKit/UIKit.h>


@interface BookLoader : NSObject 
{
	NSArray *books;
}

+ (id)sharedInstance;

@property (nonatomic,retain) NSArray *books;

@end
