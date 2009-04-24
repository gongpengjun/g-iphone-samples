//
//  EditViewController.h
//

#import <UIKit/UIKit.h>

@class EditableCell,DisplayCell,File;

@interface EditViewController : UITableViewController <UIAlertViewDelegate>
{
@private
	File            * file;
	UIBarButtonItem * saveButton;
	UIBarButtonItem * cancelButton;
    EditableCell    * nameCell;
    UITableViewCell * parentCell;
    DisplayCell     * hiddenCell;
	UISwitch        * switchCtl;
}

+ (EditViewController*)sharedEditViewController;

@property (nonatomic,retain) File *file;

@end
