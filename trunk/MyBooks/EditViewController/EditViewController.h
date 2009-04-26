//
//  EditViewController.h
//

#import <UIKit/UIKit.h>
#import "FolderPickerViewController.h"

@class EditableCell,DisplayCell,File;

@interface EditViewController : UITableViewController <	UIAlertViewDelegate,
														FolderPickerViewControllerDelegate >
{
@private
	File            * file;
	UIBarButtonItem * saveButton;
	UIBarButtonItem * cancelButton;
    EditableCell    * nameCell;
    UITableViewCell * parentCell;
    DisplayCell     * hiddenCell;
	UISwitch        * switchCtl;

	NSString        * tmpParentDirectory;
}

+ (EditViewController*)sharedEditViewController;

@property (nonatomic,retain) File *file;

@end
