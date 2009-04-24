//
//  EditViewController.m
//

#import "File.h"
#import "EditableCell.h"
#import "DisplayCell.h"
#import "EditViewController.h"
#import "DefaultsController.h"

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
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem  = cancelButton;
    self.navigationItem.rightBarButtonItem = saveButton;
	
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
	hiddenCell.nameLabel.text = @"Hidden";
	
#define kSwitchButtonWidth		94.0
#define kSwitchButtonHeight		27.0	
	CGRect frame = CGRectMake(0.0, 0.0, kSwitchButtonWidth, kSwitchButtonHeight);
	switchCtl = [[UISwitch alloc] initWithFrame:frame];
	//[switchCtl addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];	
	// in case the parent view draws with a custom color or gradient, use a transparent color
	switchCtl.backgroundColor = [UIColor clearColor];
	
	hiddenCell.view = switchCtl;
}

- (void)switchAction:(id)sender
{
	NSLog(@"switchAction: value = %d", [sender isOn]);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
	
	[self.tableView reloadData];
}

#define tagErrorNameAlert 999

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(tagErrorNameAlert == alertView.tag)
	{
		if([file isDirectory])
			nameCell.textField.text = file.name;
		else
			nameCell.textField.text = [file.name stringByDeletingPathExtension];
	}
}

- (void)doSave
{
	if((nil == nameCell.textField.text) || (nameCell.textField.text.length == 0))
	{
		NSString* message;
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
		return;
	}
	
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
    return 2;
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
		case 1: sectionTitle = nil; break;
		case 2: sectionTitle = @"Parent Folder"; break;
	}
    return sectionTitle;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {    
    UITableViewCell *cell;
	switch(indexPath.section)
	{
		case 0: cell = nameCell; break;
		case 1: cell = hiddenCell; break;
		case 2: cell = parentCell; break;
	}
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
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

@end

