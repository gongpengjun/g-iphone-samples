//
//  FileTableViewController.h
//

#import <UIKit/UIKit.h>


@interface FileBrowserViewController : UITableViewController 
{
	NSString		*path;
	NSArray			*visibleExtensions;
	NSMutableArray	*files;
}

@property (nonatomic,retain) NSString		*path;
@property (nonatomic,retain) NSArray		*visibleExtensions;
@property (nonatomic,retain) NSMutableArray	*files;

@end
