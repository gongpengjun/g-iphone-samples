//
//  FileTableViewController.h
//

#import <UIKit/UIKit.h>

@class BookShareViewController;

@interface FileBrowserViewController : UITableViewController 
{
	NSString		*path;
	NSArray			*visibleExtensions;
	NSMutableArray	*files;

	UIBarButtonItem *shareButton;
	BookShareViewController * shareViewController;
}

@property (nonatomic,retain) NSString		*path;
@property (nonatomic,retain) NSArray		*visibleExtensions;
@property (nonatomic,retain) NSMutableArray	*files;

- (void)reloadFiles;

@end
