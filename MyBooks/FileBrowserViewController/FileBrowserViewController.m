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

@implementation FileBrowserViewController

@synthesize curPath,visibleExtensions,files;

- (void)dealloc 
{
	[visibleExtensions release];
	[curPath release];
	[files release];
	[shareButton release];
	[newFolderButton release];
    [super dealloc];
}

- (id)init
{
    if (self = [super initWithStyle:UITableViewStylePlain]) 
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
    }
    return self;
}

- (void)setCurPath:(NSString*)newPath
{
	[newPath retain];
	[curPath release];
	curPath = newPath;
	self.title = [curPath lastPathComponent];
	[self reloadFiles];
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
		if([fileManager fileExistsAtPath:fullpath isDirectory:&isDir]) 
		{
			File *aFile;
			if(isDir) 
			{
				aFile = [[File alloc] init];
				aFile.name = file;
				aFile.isDirectory = isDir;
				aFile.parentDirectory = curPath;
				[files addObject:aFile];
				[aFile release];
			} 
			else
			{
				NSAssert(visibleExtensions,@"Please set visibleExtensions before setPath.");
				NSString *extension = [[file pathExtension] lowercaseString];
				if ([defaultsController showUnreadableFiles] || [visibleExtensions containsObject:extension]) 
				{
					aFile = [[File alloc] init];
					aFile.name = file;
					aFile.isDirectory = isDir;
					aFile.parentDirectory = curPath;
					[files addObject:aFile];
					[aFile release];
				}
			} 
		}
	}
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
	self.tableView.allowsSelectionDuringEditing = YES;
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
	
	self.toolbarItems = [NSArray arrayWithObject:newFolderButton];
}

- (void)viewWillAppear:(BOOL)animated 
{
	[super viewWillAppear:animated];
	if(self.editing)
	{
		self.navigationController.toolbarHidden = NO;
		self.navigationController.toolbar.barStyle = UIBarStyleBlack;
	}
	[self reloadFiles];
	[self.tableView reloadData];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	self.navigationController.toolbarHidden = YES;
}

/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

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
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return files.count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
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
	if([aFile isDirectory])
		cell.image = [File folderImage];
	else
		cell.image = [File fileImage];
	#else
	/*iPhone OS 3.0*/
	cell.textLabel.text = aFile.name;
	if([aFile isDirectory])
		cell.imageView.image = [File folderImage];
	else
		cell.imageView.image = [File fileImage];
	#endif
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	File *aFile = [files objectAtIndex:indexPath.row];
	if(self.editing)
	{
		EditViewController *editViewController = [EditViewController sharedEditViewController];
		editViewController.file = aFile;
		[self.navigationController pushViewController:editViewController animated:YES];
	}
	else
	{			
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
																	delegate:self
														   cancelButtonTitle:@"OK"
														   otherButtonTitles:nil];
				[alertView show];				
			}
		}
	}
}

#pragma mark Editing (delete)
- (void)setEditing:(BOOL)editing animated:(BOOL)animated 
{
    [super setEditing:editing animated:animated];
	if(editing)
	{
		self.navigationController.toolbarHidden = NO;
		self.navigationController.toolbar.barStyle = UIBarStyleBlack;
	}
	else
	{
		self.navigationController.toolbarHidden = YES;
	}
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath 
{
	return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		File *aFile = [files objectAtIndex:indexPath.row];
		
		BOOL success = [aFile delete];
		
		if(success)
		{
			// delete the file from data source
			[files removeObject:aFile];
			
			// delete the file from table view
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
		}
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
	newFile = [[File alloc] init];
	newFile.name = nil;
	newFile.isDirectory = YES;
	newFile.parentDirectory = curPath;
	NewViewController *newViewController = [NewViewController sharedNewViewController];
	newViewController.file = newFile;
	[self.navigationController pushViewController:newViewController animated:YES];
}

@end

