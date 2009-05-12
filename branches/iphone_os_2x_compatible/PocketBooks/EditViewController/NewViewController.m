//
//  NewViewController.m
//

#import "NewViewController.h"

#define tagNameDuplicatedAlert 997

@implementation NewViewController

static NewViewController * s_sharedNewViewController = nil;

+ (NewViewController*)sharedNewViewController
{	
	if(!s_sharedNewViewController)
	{
		s_sharedNewViewController = [[NewViewController alloc] init];
	}
	return s_sharedNewViewController;
}

- (void)dealloc
{
	[super dealloc];
}

- (id)init
{
    if (self = [super init]) 
	{
		self.title  = @"New Folder";
	}
	return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 2;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	[super alertView:alertView clickedButtonAtIndex:buttonIndex];
	
	if(tagNameDuplicatedAlert == alertView.tag)
	{
		nameCell.textField.text = @"untitled folder";
	}
}

- (BOOL)nameValidate
{
	if(NO == [super nameValidate])
		return NO;
	
	NSString *fullpath = [tmpParentDirectory stringByAppendingPathComponent:nameCell.textField.text];
	BOOL isDir = NO;
	if([[NSFileManager defaultManager] fileExistsAtPath:fullpath isDirectory:&isDir] && (YES == isDir))
	{
		NSString *message = [NSString stringWithFormat:@"The folder name \"%@\" is already taken. Please choose a different name.",
							 nameCell.textField.text];
		UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error"
															 message:message
															delegate:self
												   cancelButtonTitle:@"OK"
												   otherButtonTitles:nil];
		alertView.tag = tagNameDuplicatedAlert;
		[alertView show];
		return NO;
	}
	return YES;
}

- (void)doSave
{
	if(NO == [self nameValidate])
		return;
	
	file.name = nameCell.textField.text;
	file.parentDirectory = tmpParentDirectory;
	[file create];
	
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark FolderPickerViewControllerDelegate
- (BOOL)folderPicker:(FolderPickerViewController*)picker canPickFolder:(NSString*)folderPath
{
	return YES;
}

@end
