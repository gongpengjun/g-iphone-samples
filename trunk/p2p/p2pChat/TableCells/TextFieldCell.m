
/*
     File: CellTextField.m
 Abstract: A simple UITableViewCell that wraps a UITextField object so that you can edit the text.
 
*/

#import "TextFieldCell.h"

// cell identifier for this custom cell
NSString *kCellTextField_ID = @"CellTextField_ID";

@implementation TextFieldCell

@synthesize textField;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
	{
		// turn off selection use
		self.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	return self;
}

- (void)setTextField:(UITextField *)inView
{
	[inView retain];
	[textField release];
	textField = inView;
	
	[self.contentView addSubview:textField];
	[self layoutSubviews];
}

#define kCellLeftOffset			10.0
#define kCellTopOffset			5.0

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	CGRect contentRect = [self.contentView bounds];
	
	// In this example we will never be editing, but this illustrates the appropriate pattern
	CGRect frame = CGRectMake(	contentRect.origin.x + kCellLeftOffset,
								contentRect.origin.y + kCellTopOffset,
								contentRect.size.width - (kCellLeftOffset*2.0),
								contentRect.size.height - (kCellTopOffset*2.0));
	self.textField.frame  = frame;
}

- (void)dealloc
{
    [textField release];
    [super dealloc];
}

@end
