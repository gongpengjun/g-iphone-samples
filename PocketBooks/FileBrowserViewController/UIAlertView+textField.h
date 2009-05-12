//
//  UIAlertView+textField.h
//

#import <UIKit/UIKit.h>

@interface UIAlertView (textField)

- (UITextField*)addTextFieldWithValue:(NSString*)value label:(NSString*)label;
- (UITextField*)textFieldAtIndex:(NSUInteger)index;
- (NSUInteger)textFieldCount;
- (UITextField*)textField;

@end
