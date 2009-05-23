
/*
     File: CellTextField.h
 Abstract: A simple UITableViewCell that wraps a UITextField object so that you can edit the text.
*/

// cell identifier for this custom cell
extern NSString *kCellTextField_ID;

@interface TextFieldCell : UITableViewCell
{
    UITextField *textField;
}

@property (nonatomic, retain) UITextField *textField;

@end
