//
//  EditViewController.h
//

#import <UIKit/UIKit.h>
#import "FolderPickerViewController.h"
#import "File.h"
#import "EditableCell.h"
#import "DisplayCell.h"

@class EditableCell,DisplayCell,File;

@interface EditViewController : UITableViewController <	UIAlertViewDelegate,
														FolderPickerViewControllerDelegate >
{
@protected
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

- (BOOL)nameValidate;

@property (nonatomic,retain) File *file;

@end
