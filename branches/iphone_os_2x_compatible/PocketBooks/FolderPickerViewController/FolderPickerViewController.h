//
//  FolderPickerViewController.h
//

#import <UIKit/UIKit.h>
#import "Folder.h"

@protocol FolderPickerViewControllerDelegate;

@interface FolderPickerViewController : UITableViewController {
@private
	NSString		* rootFolder;
	NSString		* pickedFolder;
	NSInteger         pickedIndex;
	NSMutableArray	* folders;
	id <FolderPickerViewControllerDelegate> delegate;
}

@property (nonatomic,retain) NSString		* rootFolder;
@property (nonatomic,retain) NSString		* pickedFolder;
@property (nonatomic,retain) NSMutableArray	* folders;
@property (nonatomic,assign) id <FolderPickerViewControllerDelegate> delegate;

+ (id)sharedPicker;

@end

@protocol FolderPickerViewControllerDelegate <NSObject>
@optional
- (BOOL)folderPicker:(FolderPickerViewController*)picker shouldShowFolder:(NSString*)folderPath;
- (BOOL)folderPicker:(FolderPickerViewController*)picker canPickFolder:(NSString*)folderPath;
- (void)folderPicker:(FolderPickerViewController*)picker pickedFolder:(NSString*)pickedFolder;
@end
