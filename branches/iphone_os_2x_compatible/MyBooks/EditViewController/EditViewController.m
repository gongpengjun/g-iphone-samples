//
//  EditViewController.m
//

#import "EditViewController.h"
#import "DefaultsController.h"
#import "FolderPickerViewController.h"
#import "FGFileManager.h"

#define tagErrorNameAlert 999
#define tagErrorPathAlert 998

@implementation EditViewController

@synthesize file;

static EditViewController * s_sharedEditViewController = nil;

+ (EditViewController*)sharedEditViewController
{
	if(!s_sharedEditViewController)
	{
		s_sharedEditViewController = [[EditViewController alloc] init];
	}
	return s_sharedEditViewController;
}

- (void)dealloc
{
	[saveButton release];
	[cancelButton release];
	[nameCell release];
	[parentCell release];
	[hiddenCell release];
	[switchCtl release];
	[file release];
	[super dealloc];
}

- (id)init
{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) 
	{
		self.title  = NSLocalizedString(@"Edit File", @"");
		saveButton  = [[UIBarButtonItem alloc] initWithTitle:@"Save"
													   style:UIBarButtonItemStyleBordered
													  target:self
													  action:@selector(doSave)];
		cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
														style:UIBarButtonItemStyleBordered
													   target:self
													   action:@selector(doCancel)];
		
		nameCell = [[EditableCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"NameCell"];
		
		#if __IPHONE_OS_VERSION_MAX_ALLOWED < 30000
		/*iPhone OS 2.2.1*/
		parentCell = [[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"ParentCell"];
		#else
		/*iPhone OS 3.0*/
		parentCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ParentCell"];
		#endif
		parentCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		hiddenCell = [[DisplayCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"HiddenCell"];
		hiddenCell.nameLabel.text = @"Hide";
		
		#define kSwitchButtonWidth		94.0
		#define kSwitchButtonHeight		27.0	
		CGRect frame = CGRectMake(0.0, 0.0, kSwitchButtonWidth, kSwitchButtonHeight);
		switchCtl = [[UISwitch alloc] initWithFrame:frame];
		//[switchCtl addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];	
		// in case the parent view draws with a custom color or gradient, use a transparent color
		switchCtl.backgroundColor = [UIColor clearColor];
		
		hiddenCell.view = switchCtl;
	}
	return self;
}

- (void)setFile:(File*)newFile
{
	[newFile retain];
	[file release];
	file = newFile;
	
	if([file isDirectory])
	{
		self.title = @"Edit Folder";
		nameCell.textField.placeholder = @"New Folder Name";	
		nameCell.textField.text = file.name;
	}
	else
	{
		self.title = @"Edit File";
		nameCell.textField.placeholder = @"New File Name";	
		nameCell.textField.text = [file.name stringByDeletingPathExtension];
	}
	
    // Starts editing in the name field and shows the keyboard
    //[nameCell.textField becomeFirstResponder];
	
	#if __IPHONE_OS_VERSION_MAX_ALLOWED < 30000
	/*iPhone OS 2.2.1*/
	parentCell.text = [file.parentDirectory lastPathComponent];
	#else
	/*iPhone OS 3.0*/
	parentCell.textLabel.text = [file.parentDirectory lastPathComponent];
	#endif
	
	NSString * fullpath = [file.parentDirectory stringByAppendingPathComponent:file.name];
	switchCtl.on = [[DefaultsController sharedDefaultsController] isHiddenOfFile:fullpath];
	
	tmpParentDirectory = file.parentDirectory;
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem  = cancelButton;
    self.navigationItem.rightBarButtonItem = saveButton;
}

- (void)switchAction:(id)sender
{
	NSLog(@"switchAction: value = %d", [sender isOn]);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];	
	[self.tableView reloadData];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(tagErrorNameAlert == alertView.tag)
	{
		if([file isDirectory])
			nameCell.textField.text = file.name;
		else
			nameCell.textField.text = [file.name stringByDeletingPathExtension];
	}
	else if(tagErrorPathAlert == alertView.tag)
	{
		if([file isDirectory])
			nameCell.textField.text = file.name;
		else
			nameCell.textField.text = [file.name stringByDeletingPathExtension];

		#if __IPHONE_OS_VERSION_MAX_ALLOWED < 30000
		/*iPhone OS 2.2.1*/
		parentCell.text = [file.parentDirectory lastPathComponent];
		#else
		/*iPhone OS 3.0*/
		parentCell.textLabel.text = [file.parentDirectory lastPathComponent];
		#endif
	}
}

- (BOOL)nameValidate
{
	NSString* message;
	if((nil == nameCell.textField.text) || (nameCell.textField.text.length == 0))
	{
		if([file isDirectory])
			message = @"Folder name must NOT be empty!";
		else
			message = @"File name must NOT be empty!";
		
		UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error"
															 message:message
															delegate:self
												   cancelButtonTitle:@"OK"
												   otherButtonTitles:nil];
		alertView.tag = tagErrorNameAlert;
		[alertView show];
		return NO;
	}
	
	if(NO == [file.parentDirectory isEqualToString:tmpParentDirectory])
	{
		NSString *fullpath = [tmpParentDirectory stringByAppendingPathComponent:nameCell.textField.text];
		BOOL isDir = NO;
		if([[NSFileManager defaultManager] fileExistsAtPath:fullpath isDirectory:&isDir] && (file.isDirectory == isDir))
		{
			NSString *message = [NSString stringWithFormat:@"The %@ name '%@' is already taken in '%@'. Please choose a different name.",
								 file.isDirectory?@"folder":@"file",nameCell.textField.text,[tmpParentDirectory lastPathComponent]];
			UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error"
																 message:message
																delegate:self
													   cancelButtonTitle:@"OK"
													   otherButtonTitles:nil];
			alertView.tag = tagErrorPathAlert;
			[alertView show];
			return NO;
		}
	}
		
	return YES;
}

- (void)doSave
{
	if(NO == [self nameValidate])
		return;
	
	// rename
	if([file isDirectory])
	{
		if(NO == [file.name isEqualToString:nameCell.textField.text])
			[file renameTo:nameCell.textField.text];
	}
	else
	{
		if(NO == [[file.name stringByDeletingPathExtension] isEqualToString:nameCell.textField.text])
		{
			NSString* newName = [nameCell.textField.text stringByAppendingPathExtension:[file.name pathExtension]];
			[file renameTo:newName];
		}
	}

	//move
	if(![file.parentDirectory isEqualToString:tmpParentDirectory])
	{
		[file moveToDirectory:tmpParentDirectory];
	}
	
	//property set
	NSString * fullpath = [file.parentDirectory stringByAppendingPathComponent:file.name];
	if([switchCtl isOn] != [[DefaultsController sharedDefaultsController] isHiddenOfFile:fullpath])
		[[DefaultsController sharedDefaultsController] setHidden:[switchCtl isOn] forFile:fullpath];

	[self.navigationController popViewControllerAnimated:YES];
}

- (void)doCancel
{
	[self.navigationController popViewControllerAnimated:YES];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
    //[nameCell.textField resignFirstResponder];
}

/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSString *sectionTitle;
	switch(section)
	{
		case 0: sectionTitle = ([file isDirectory]) ? @"Folder Name" : @"File Name"; break;
		case 1: sectionTitle = @"Parent Folder"; break;
		case 2: sectionTitle = nil; break;
	}
    return sectionTitle;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {    
    UITableViewCell *cell;
	switch(indexPath.section)
	{
		case 0: cell = nameCell; break;
		case 1: cell = parentCell; break;
		case 2: cell = hiddenCell; break;
	}
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    FolderPickerViewController *folderPicker = [FolderPickerViewController sharedPicker];
	folderPicker.rootFolder		= [FGFileManager booksDirectory];
	folderPicker.pickedFolder	= tmpParentDirectory;
	folderPicker.delegate       = self;
	[self.navigationController pushViewController:folderPicker animated:YES];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark FolderPickerViewControllerDelegate
- (BOOL)folderPicker:(FolderPickerViewController*)picker shouldShowFolder:(NSString*)folderPath
{
	return YES;
}

- (BOOL)folderPicker:(FolderPickerViewController*)picker canPickFolder:(NSString*)folderPath
{
	BOOL canPick = YES;
	if(file.isDirectory)
	{
		if([file.parentDirectory isEqualToString:folderPath])
			canPick = YES;
		else
			canPick = ![folderPath hasPrefix:[file.parentDirectory stringByAppendingPathComponent:file.name]];
	}
	return canPick;
}

- (void)folderPicker:(FolderPickerViewController*)picker pickedFolder:(NSString*)pickedFolder
{
	tmpParentDirectory = pickedFolder;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30000	
	parentCell.textLabel.text = [tmpParentDirectory lastPathComponent];
#else
	parentCell.text = [tmpParentDirectory lastPathComponent];
#endif
}

@end

