//
//  FileTableViewController.m
//

#import "FileBrowserViewController.h"
#import "File.h"
#import "BookReaderViewController.h"
#import "Book.h"
#import "BookShareViewController.h"
#import "DefaultsController.h"
#import "AppDelegate.h"
#import "EditViewController.h"
#import "NewViewController.h"
#import "UIAlertView+textField.h"
#import "PasswordKeeper.h"

#import "Configuration.h"

@interface FileBrowserViewController (Private)
- (void)doShare;
- (void)doNewFolder;
- (void)doLockUnlockFileAtIndexPath:(NSIndexPath *)indexPath;
- (void)doOpenFileAtIndexPath:(NSIndexPath*)indexPath;
- (void)doDeleteFileAtIndexPath:(NSIndexPath*)indexPath;

- (void)reloadFiles;
- (void)openFileAtIndexPath:(NSIndexPath*)indexPath;
- (void)deleteFileAtIndexPath:(NSIndexPath*)indexPath;
- (void)lockFileAtIndexPath:(NSIndexPath *)indexPath;
- (void)unlockFileAtIndexPath:(NSIndexPath *)indexPath;
@end


@implementation FileBrowserViewController

@synthesize curPath,visibleExtensions,files,curIndexPath;

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 30000
@synthesize toolbarItems,tableView;
//CGRectMake( 0.0, 372.0,  320.0,  44.0 )
//CGRectMake( 0.0, 236.0,  480.0,  32.0 )
static CGRect s_footerBarFrame = { 0.0, 372.0,  320.0,  44.0 };
#endif

- (void)dealloc 
{
	[visibleExtensions release];
	[curPath release];
	[files release];
	[shareButton release];
	[newFolderButton release];
	[pwdAlertTitle release];
	[pwdAlertMessage release];
	[curIndexPath release];
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 30000
	[toolbarItems release];
	[toolbar release];
	[tableView release];
#endif
    [super dealloc];
}

- (id)init
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 30000
    if (self = [super init]) 
#else
    if (self = [super initWithStyle:UITableViewStylePlain]) 
#endif
	{
		self.title = @"File Browser";
		visibleExtensions = [[NSArray arrayWithObjects:@"txt", @"htm", @"html", @"webarchive", @"pdb", @"pdf", @"jpg", @"png", @"gif", nil] retain];
		files = [[NSMutableArray alloc] init];
		
		shareButton		= [[UIBarButtonItem alloc] initWithTitle:@"Share"
														style:UIBarButtonItemStyleBordered
													   target:self
													   action:@selector(doShare)];
		newFolderButton = [[UIBarButtonItem alloc] initWithTitle:@"New Folder"
														  style:UIBarButtonItemStyleBordered
														 target:self
														 action:@selector(doNewFolder)];
		self.toolbarItems = [NSArray arrayWithObject:newFolderButton];
    }
    return self;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 30000
- (void)loadView
{
	//[super loadView];
	CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
	UIView *contentView = [[UIView alloc] initWithFrame:appFrame];
	[contentView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
	self.view = contentView;
	[contentView release];
	
	appFrame.origin.y = 0;
    UITableView *aTableView = [[UITableView alloc] initWithFrame:appFrame style:UITableViewStylePlain];
	aTableView.delegate = self;
	aTableView.dataSource = self;
    aTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	[aTableView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
	self.tableView = aTableView;
	[self.view addSubview:aTableView];
	[aTableView release];
}
#endif

- (void)viewDidLoad 
{
    [super viewDidLoad];
	self.tableView.allowsSelectionDuringEditing = YES;
#if !GENERATE_SPLASH_SCREEN	
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	if([self isEqual:appDelegate.rootViewController])
	{
		self.navigationItem.leftBarButtonItem = shareButton;
		self.navigationItem.rightBarButtonItem = self.editButtonItem;
	}
	else
	{
		self.navigationItem.rightBarButtonItem = self.editButtonItem;		
	}
#endif
}

- (void)viewWillAppear:(BOOL)animated 
{
	[super viewWillAppear:animated];
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 30000
	if(!toolbar)
	{
		toolbar = [[UIToolbar alloc] initWithFrame:s_footerBarFrame];
		toolbar.barStyle = UIBarStyleBlackOpaque;
		[self.view addSubview:toolbar];
		[toolbar setItems:toolbarItems animated:animated];
	}
	
	if(self.editing)
	{
		toolbar.hidden = NO;
	}
	else
	{
		toolbar.hidden = YES;
	}
#else
	if(self.editing)
	{
		self.navigationController.toolbarHidden = NO;
		self.navigationController.toolbar.barStyle = UIBarStyleBlack;
	}
#endif
	
#if !GENERATE_SPLASH_SCREEN
	[self reloadFiles];
#endif
	[self.tableView reloadData];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/

- (void)viewWillDisappear:(BOOL)animated 
{
	[super viewWillDisappear:animated];
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 30000
	if(toolbar) toolbar.hidden = YES;
#else
	self.navigationController.toolbarHidden = YES;
#endif
}

/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 30000
	if(UIInterfaceOrientationIsPortrait(interfaceOrientation))
		s_footerBarFrame = CGRectMake( 0.0, 372.0,  320.0,  44.0 );
	else
		s_footerBarFrame = CGRectMake( 0.0, 236.0,  480.0,  32.0 );
#endif
    // Return YES for supported orientations
    return YES;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 30000
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	if(toolbar) toolbar.frame = s_footerBarFrame;
}
#endif

- (void)didReceiveMemoryWarning 
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload 
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return files.count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    static NSString *CellIdentifier = @"Cell";
	
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
	{
		#if __IPHONE_OS_VERSION_MAX_ALLOWED < 30000
		/*iPhone OS 2.2.1*/
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.hidesAccessoryWhenEditing = NO;
		#else
		/*iPhone OS 3.0*/
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
		#endif
    }
    
	File *aFile = [files objectAtIndex:[indexPath row]];
	
	#if __IPHONE_OS_VERSION_MAX_ALLOWED < 30000
	cell.text = aFile.name;
	cell.image = [aFile fileImage];
	#else
	/*iPhone OS 3.0*/
	cell.textLabel.text = aFile.name;
	cell.imageView.image = [aFile fileImage];
	#endif
	
	UIImage *image = (aFile.locked) ? [UIImage imageNamed:@"locked.png"] : [UIImage imageNamed:@"unlocked.png"];
	
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	CGRect frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
	button.frame = frame;	// match the button's size with the image size
	
	[button setBackgroundImage:image forState:UIControlStateNormal];
	
	// set the button's target to this table view controller so we can interpret touch events and map that to a NSIndexSet
	[button addTarget:self action:@selector(checkButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
	button.backgroundColor = [UIColor clearColor];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30000
	cell.editingAccessoryView = button;
	
	if(aFile.locked)
		cell.accessoryView = button;
	else
		cell.accessoryView = nil;
#else
	if(self.editing)
	{
		cell.accessoryView = button;
	}
	else
	{
		if(aFile.locked)
			cell.accessoryView = button;
		else
			cell.accessoryView = nil;
	}
#endif
		
    return cell;
}

- (void)checkButtonTapped:(id)sender event:(id)event 
{
	NSSet *touches = [event allTouches];
	UITouch *touch = [touches anyObject];
	CGPoint currentTouchPosition = [touch locationInView:self.tableView];
	NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:currentTouchPosition];
	if (indexPath != nil) 
	{
		[self tableView: self.tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
	}
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath 
{
	[self doLockUnlockFileAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[self.tableView deselectRowAtIndexPath:indexPath animated:NO];
	File *aFile = [files objectAtIndex:indexPath.row];
	if(self.editing)
	{
		EditViewController *editViewController = [EditViewController sharedEditViewController];
		editViewController.file = aFile;
		[self.navigationController pushViewController:editViewController animated:YES];
	}
	else
	{
		[self doOpenFileAtIndexPath:indexPath];
	}
}

#pragma mark Editing (delete)
- (void)setEditing:(BOOL)editing animated:(BOOL)animated 
{
    [super setEditing:editing animated:animated];

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 30000
	if(!toolbar)
	{
		toolbar = [[UIToolbar alloc] initWithFrame:s_footerBarFrame];
		toolbar.barStyle = UIBarStyleBlackOpaque;
		[self.view addSubview:toolbar];
		[toolbar setItems:toolbarItems animated:animated];
	}
	
	if(editing)
	{
		toolbar.hidden = NO;
		toolbar.frame = s_footerBarFrame;
		CGRect tableViewFrame = self.view.bounds;
		tableViewFrame.size.height -= s_footerBarFrame.size.height;
		self.tableView.frame = tableViewFrame;
	}
	else
	{
		toolbar.hidden = YES;
		self.tableView.frame = self.view.bounds;
	}
	[self.tableView reloadData];
#else
	if(editing)
	{
		self.navigationController.toolbarHidden = NO;
		self.navigationController.toolbar.barStyle = UIBarStyleBlack;
	}
	else
	{
		self.navigationController.toolbarHidden = YES;
	}
#endif
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath 
{
	return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		[self doDeleteFileAtIndexPath:indexPath];
    }   
}

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
#pragma mark Password lock

#define TAG_PASSWORD_ALERT       1234
#define TAG_PASSWORD_ERROR_ALERT 1235

- (void)showPasswordErrorDialog
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Your password was incorrect. Please try again."
														message:nil
													   delegate:self 
											  cancelButtonTitle:@"Cancel"
											  otherButtonTitles:@"Retry",nil];
	alertView.tag = TAG_PASSWORD_ERROR_ALERT;
	[alertView show];
	[alertView release];
}

- (void)showPasswordDialog
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:pwdAlertTitle
														message:pwdAlertMessage
													   delegate:self 
											  cancelButtonTitle:@"Cancel"
											  otherButtonTitles:nil];
	[alertView addTextFieldWithValue:nil label:nil];
	[alertView textField].keyboardType = UIKeyboardTypeASCIICapable;
	[alertView textField].placeholder = @"Password";
	[alertView textField].autocapitalizationType = UITextAutocapitalizationTypeNone;
	[alertView textField].autocorrectionType = UITextAutocorrectionTypeNo;
	[alertView textField].returnKeyType = UIReturnKeyDone;
	[alertView textField].secureTextEntry = YES;	// make the text entry secure (bullets)
	[alertView textField].delegate = self;	// textFieldShouldReturn
	
	switch(pwdTarget)
	{
		case FGPasswordTargetLock:
			[alertView addButtonWithTitle:@"Set"];
			break;
		case FGPasswordTargetLockConfirm:
			[alertView addButtonWithTitle:@"Confirm"];
			break;
		case FGPasswordTargetUnlock:
			[alertView addButtonWithTitle:@"Unlock"];
			break;
		case FGPasswordTargetOpen:
			[alertView addButtonWithTitle:@"Open"];
			break;
		case FGPasswordTargetDelete:
			[alertView addButtonWithTitle:@"Delete"];
			break;
		case FGPasswordTargetNone:
		default:
			[alertView addButtonWithTitle:@"OK"];
			break;
	}
	alertView.tag = TAG_PASSWORD_ALERT;
	[alertView show];
	[alertView release];
}

- (void)doPasswordVerify:(NSString*)inputPassword
{
	if(FGPasswordTargetLock == pwdTarget)
	{
		if(inputPassword.length < PASSWORD_LEN_MIN || inputPassword.length > PASSWORD_LEN_MAX)
			goto ERROR;
	}
	else if(FGPasswordTargetNone == pwdTarget)
	{
		self.curIndexPath = nil;
		return;
	}
	else
	{	
		if(NO == [inputPassword isEqualToString:[[PasswordKeeper sharedPasswordKeeper] fetchPassword]])
			goto ERROR;
	}
	
	DefaultsController *defaultController = [DefaultsController sharedDefaultsController];
	switch(pwdTarget)
	{
		case FGPasswordTargetLock:
			[[PasswordKeeper sharedPasswordKeeper] setPassword:inputPassword];
			pwdTarget = FGPasswordTargetLockConfirm;
			pwdAlertMessage = @"Re-enter your password";
			[self showPasswordDialog];
			return;
		case FGPasswordTargetLockConfirm:
			[defaultController autoPasswordDisable];
			[[PasswordKeeper sharedPasswordKeeper] setPassword:inputPassword];
			[self lockFileAtIndexPath:self.curIndexPath];
			break;
		case FGPasswordTargetUnlock:
			[defaultController autoPasswordEnable];
			[self lockFileAtIndexPath:self.curIndexPath];
			break;
		case FGPasswordTargetOpen:
			[defaultController autoPasswordEnable];
			[self openFileAtIndexPath:self.curIndexPath];
			break;
		case FGPasswordTargetDelete:
			[defaultController autoPasswordEnable];
			[self deleteFileAtIndexPath:self.curIndexPath];
			break;
		case FGPasswordTargetNone:
		default:
			break;
	}
	
	self.curIndexPath = nil;
	return;
	
ERROR:
	[self showPasswordErrorDialog];
	return;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(TAG_PASSWORD_ALERT == alertView.tag)
	{	
		NSLog(@"password alertView, clickedButtonAtIndex:%d",buttonIndex);
		
		switch (buttonIndex)
		{
			default:
			case 0: /*Cancel*/
				[self.tableView deselectRowAtIndexPath:curIndexPath animated:YES];
				pwdTarget = FGPasswordTargetNone;
				pwdAlertTitle = nil;
				pwdAlertMessage = nil;
				self.curIndexPath = nil;
				break;
			case 1: /*Action*/
				[self doPasswordVerify:alertView.textField.text];
				break;
		}
	}
	else if(TAG_PASSWORD_ERROR_ALERT == alertView.tag)
	{
		NSLog(@"password error alertView, clickedButtonAtIndex:%d",buttonIndex);
		
		switch (buttonIndex)
		{
			default:
			case 0: /*Cancel*/
				pwdTarget = FGPasswordTargetNone;
				pwdAlertTitle = nil;
				pwdAlertMessage = nil;
				self.curIndexPath = nil;
				break;
			case 1: /*Retry*/
				[self showPasswordDialog];
				break;
		}
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	[(UIAlertView *)textField.superview dismissWithClickedButtonIndex:1 animated:NO];
	[self doPasswordVerify:textField.text];
	return YES;
}

#pragma mark Actions
- (void)doShare
{
    if(!shareViewController)
    {
        shareViewController = [[BookShareViewController alloc] init];
    }
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:1.0];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft
						   forView:self.navigationController.view cache:YES];	
	[self.navigationController pushViewController:shareViewController animated:YES];
	[UIView commitAnimations];	
}

- (void)doNewFolder
{
	newFile = [[File alloc] initWithParentDirectory:curPath name:nil];
	newFile.isDirectory = YES;
	NewViewController *newViewController = [NewViewController sharedNewViewController];
	newViewController.file = newFile;
	[self.navigationController pushViewController:newViewController animated:YES];
}

- (void)doLockUnlockFileAtIndexPath:(NSIndexPath *)indexPath
{
	File *aFile = [files objectAtIndex:indexPath.row];
	if(aFile.locked)
	{
		if([[DefaultsController sharedDefaultsController] autoPasswordValid])
		{
			[self unlockFileAtIndexPath:indexPath];
		}
		else
		{		
			pwdTarget = FGPasswordTargetUnlock;
			pwdAlertTitle = @"PocketFolder Password";
			pwdAlertMessage = nil;
			self.curIndexPath = indexPath;
			[self showPasswordDialog];
		}
	}
	else
	{
		if([[DefaultsController sharedDefaultsController] lockedFileCount])
		{
			[self lockFileAtIndexPath:indexPath];
		}
		else //ask user for pasword only once when there is not file locked before.
		{
			pwdTarget = FGPasswordTargetLock;
			pwdAlertTitle = @"Set Password";
			pwdAlertMessage = @"must be longer than 4 characters";
			self.curIndexPath = indexPath;
			[self showPasswordDialog];
		}
	}
}	

- (void)doOpenFileAtIndexPath:(NSIndexPath*)indexPath
{
	File *aFile = [files objectAtIndex:indexPath.row];
	if(aFile.locked)
	{
		if([[DefaultsController sharedDefaultsController] autoPasswordValid])
		{
			[self openFileAtIndexPath:indexPath];
		}
		else
		{		
			pwdTarget = FGPasswordTargetOpen;
			pwdAlertTitle = @"PocketFolder Password";
			pwdAlertMessage = nil;
			self.curIndexPath = indexPath;
			[self showPasswordDialog];
		}
	}
	else
	{
		[self openFileAtIndexPath:indexPath];
	}
}

- (void)doDeleteFileAtIndexPath:(NSIndexPath*)indexPath
{
	File *aFile = [files objectAtIndex:indexPath.row];
	if(aFile.locked)
	{
		pwdTarget = FGPasswordTargetDelete;
		pwdAlertTitle = @"PocketFolder Password";
		pwdAlertMessage = nil;
		self.curIndexPath = indexPath;
		[self showPasswordDialog];
	}
	else
	{
		[self deleteFileAtIndexPath:indexPath];
	}	
}

#pragma mark Utility
- (void)setCurPath:(NSString*)newPath
{
	[newPath retain];
	[curPath release];
	curPath = newPath;
	self.title = [curPath lastPathComponent];
#if !GENERATE_SPLASH_SCREEN
	[self reloadFiles];
#endif
}

- (void)reloadFiles
{
	DefaultsController *defaultsController = [DefaultsController sharedDefaultsController];
	[files removeAllObjects];
	NSFileManager * fileManager = [NSFileManager defaultManager];
	NSArray * fileArray = [fileManager contentsOfDirectoryAtPath:curPath error:nil];
	NSString *fullpath;
	for(NSString *file in fileArray)
	{
		if(NO == [defaultsController showUnreadableFiles])
			if ([file characterAtIndex:0] == (unichar)'.') // Skip invisibles, like .DS_Store
				continue;
		
		fullpath = [curPath stringByAppendingPathComponent:file];
		if( (NO == [defaultsController showHiddenFiles]) && [defaultsController isHiddenOfFile:fullpath] )
			continue;
		
		BOOL isDir = NO;
		[fileManager fileExistsAtPath:fullpath isDirectory:&isDir];
		if(!isDir && ![defaultsController showUnreadableFiles] &&
		   ![visibleExtensions containsObject:[[file pathExtension] lowercaseString]])
			continue;
		
		File *aFile;
		aFile = [[File alloc] initWithParentDirectory:curPath name:file];
		[files addObject:aFile];
		[aFile release];
	}
}

- (void)openFileAtIndexPath:(NSIndexPath*)indexPath
{			
	File *aFile = [files objectAtIndex:indexPath.row];
	if(aFile.isDirectory)
	{
		FileBrowserViewController *anotherViewController = [[FileBrowserViewController alloc] init];
		anotherViewController.curPath = [curPath stringByAppendingPathComponent:aFile.name];
		[self.navigationController pushViewController:anotherViewController animated:YES];
		[anotherViewController release];
	}
	else
	{
		NSString *extension = [[aFile.name pathExtension] lowercaseString];
		if ([visibleExtensions containsObject:extension])
		{	
			Book *aBook = [[Book alloc] init];
			aBook.basePath = curPath;
			aBook.name = aFile.name;
			aBook.title = [aFile.name stringByDeletingPathExtension];
			NSString *fullpath = [curPath stringByAppendingPathComponent:aFile.name];
			aBook.hidden = [[DefaultsController sharedDefaultsController] isHiddenOfFile:fullpath];
			BookReaderViewController *bookReaderViewController = [BookReaderViewController sharedInstance];
			bookReaderViewController.book = aBook;
			[self.navigationController pushViewController:bookReaderViewController animated:YES];
			[aBook release];
		}
		else
		{
			UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error"
																 message:@"This type of file can not be open by this Application."
																delegate:nil
													   cancelButtonTitle:@"OK"
													   otherButtonTitles:nil];
			[alertView show];				
		}
	}
}

- (void)deleteFileAtIndexPath:(NSIndexPath*)indexPath
{
	File *aFile = [files objectAtIndex:indexPath.row];
	
	if([aFile delete])
	{
		// delete the file from data source
		[files removeObject:aFile];
		
		// delete the file from table view
		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
	}
}

- (void)switchLockOfFileAtIndexPath:(NSIndexPath *)indexPath
{
	File *aFile = [files objectAtIndex:[indexPath row]];
	
	aFile.locked ^= YES;
	
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30000	
	UIButton *button = (UIButton *) (self.editing ? cell.editingAccessoryView : cell.accessoryView);
#else
	UIButton *button = (UIButton *) (cell.accessoryView);
#endif
	UIImage *newImage = (aFile.locked) ? [UIImage imageNamed:@"locked.png"] : [UIImage imageNamed:@"unlocked.png"];
	[button setBackgroundImage:newImage forState:UIControlStateNormal];
	if(aFile.locked)
		cell.accessoryView = button;
	else
		cell.accessoryView = nil;
}

- (void)lockFileAtIndexPath:(NSIndexPath *)indexPath
{
	[self switchLockOfFileAtIndexPath:indexPath];
}

- (void)unlockFileAtIndexPath:(NSIndexPath *)indexPath
{
	[self switchLockOfFileAtIndexPath:indexPath];
}

@end
