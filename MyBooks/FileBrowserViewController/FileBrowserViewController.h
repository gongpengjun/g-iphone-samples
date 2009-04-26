//
//  FileTableViewController.h
//

#import <UIKit/UIKit.h>

@class BookShareViewController,File;

@interface FileBrowserViewController : UITableViewController {
@private
	NSString		*curPath;
	NSArray			*visibleExtensions;
	NSMutableArray	*files;

	UIBarButtonItem *shareButton;
	UIBarButtonItem *newFolderButton;
	BookShareViewController * shareViewController;
	
	File            *newFile;
}

@property (nonatomic,retain) NSString		*curPath;
@property (nonatomic,retain) NSArray		*visibleExtensions;
@property (nonatomic,retain) NSMutableArray	*files;

- (void)reloadFiles;

@end
