//
//  FolderPickerViewController.m
//

#import "FolderPickerViewController.h"
#import "DefaultsController.h"
#import "Folder.h"

@implementation FolderPickerViewController

@synthesize rootFolder,pickedFolder,folders,delegate;

- (void)dealloc 
{
	[rootFolder release];
	[pickedFolder release];
	[folders release];
    [super dealloc];
}

- (id)init
{
    if (self = [super initWithStyle:UITableViewStylePlain])
	{
		self.title = @"Folder Picker";
		folders = [[NSMutableArray alloc] init];
    }
    return self;
}

static FolderPickerViewController *s_sharedFolderPickerViewController = nil;

+ (id)sharedPicker
{
	if(!s_sharedFolderPickerViewController)
	{
		s_sharedFolderPickerViewController = [[FolderPickerViewController alloc] init];
	}
	return s_sharedFolderPickerViewController;
}

- (void)viewDidLoad 
{
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)loadFoldersInFolder:(NSString*)parentFolder parentFolderLevel:(NSUInteger)parentLevel
{
	DefaultsController *defaultsController = [DefaultsController sharedDefaultsController];
	NSFileManager * fileManager = [NSFileManager defaultManager];
	NSArray * fileArray = [fileManager contentsOfDirectoryAtPath:parentFolder error:nil];
	NSString *fullpath;
	for(NSString *file in fileArray)
	{
		if(NO == [defaultsController showUnreadableFiles])
			if ([file characterAtIndex:0] == (unichar)'.') // Skip invisibles, like .DS_Store
				continue;
		
		fullpath = [parentFolder stringByAppendingPathComponent:file];
		if( (NO == [defaultsController showHiddenFiles]) && [defaultsController isHiddenOfFile:fullpath] )
			continue;
		
		BOOL isDir = NO;
		Folder *aFolder;
		if( [fileManager fileExistsAtPath:fullpath isDirectory:&isDir] && (YES == isDir) )
		{
			
			if(delegate && [delegate respondsToSelector:@selector(folderPicker:shouldShowFolder:)])
				if(![delegate folderPicker:self shouldShowFolder:fullpath])
					continue; // this folder is skiped by delegate
			
			aFolder = [[Folder alloc] init];
			aFolder.name = file;
			aFolder.parentFolder = parentFolder;
			aFolder.level = parentLevel + 1;
			[folders addObject:aFolder];
			[aFolder release];
			
			[self loadFoldersInFolder:fullpath parentFolderLevel:aFolder.level];
		}
	}	
}

- (void)reloadFolders
{
	[folders removeAllObjects];
	
	Folder *aFolder;
	aFolder = [[Folder alloc] init];
	aFolder.name = [rootFolder lastPathComponent];
	aFolder.parentFolder = [rootFolder stringByDeletingLastPathComponent];
	aFolder.level = 0;
	[folders addObject:aFolder];
	[aFolder release];
	
	[self loadFoldersInFolder:rootFolder parentFolderLevel:0];
	
	NSLog(@"reloadFolders:\n%@",folders);
}

- (void)pickedFolder_to_pickedIndex
{
	if(nil == pickedFolder)
	{
		pickedIndex = -1;
		return;
	}
	
	NSString *folderPath;
	for(Folder *aFolder in folders)
	{
		folderPath = [aFolder.parentFolder stringByAppendingPathComponent:aFolder.name];
		if([pickedFolder isEqualToString:folderPath])
		{
			pickedIndex = [folders indexOfObject:aFolder];
			return;
		}
	}
	
	//correct them if 'pickedFolder' is not in 'folders'
	pickedIndex = -1;
	self.pickedFolder = nil;
}

- (NSString*)folderOfIndex:(NSInteger)index
{
	NSString *folder = nil;
	if(index < 0 || index >= folders.count)
		return folder;
	
	Folder * aFolder = [folders objectAtIndex:index];
	folder = [aFolder.parentFolder stringByAppendingPathComponent:aFolder.name];
	return folder;
}

- (void)pickedIndex_to_pickedFolder
{
	self.pickedFolder = [self folderOfIndex:pickedIndex];		
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
	[self reloadFolders];
	[self pickedFolder_to_pickedIndex];
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
	if(delegate && [delegate respondsToSelector:@selector(folderPicker:pickedFolder:)])
		[delegate folderPicker:self pickedFolder:pickedFolder];
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
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return folders.count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	Folder *aFolder = [folders objectAtIndex:indexPath.row];
	cell.textLabel.text = aFolder.name;
	cell.indentationLevel = aFolder.level;
	
	if(aFolder.level <= 0)
		cell.imageView.image = [Folder folderImage];
	else
		cell.imageView.image = [Folder smallFolderImage];
	
    if (indexPath.row == pickedIndex)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
	else
		cell.accessoryType = UITableViewCellAccessoryNone;
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[self.tableView deselectRowAtIndexPath:indexPath animated:NO];
	if(pickedIndex == indexPath.row)
		return;
	
	NSString *fullpath = [self folderOfIndex:indexPath.row];
	if(nil == fullpath) return;
	
	if(delegate && [delegate respondsToSelector:@selector(folderPicker:canPickFolder:)])
		if(![delegate folderPicker:self canPickFolder:fullpath])
			return; // this folder is skiped by delegate
	
    UITableViewCell *newCell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (newCell.accessoryType == UITableViewCellAccessoryNone)
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
	
	if( 0 <= pickedIndex && pickedIndex < folders.count )
	{
		NSUInteger ints[2] = {0,pickedIndex};
		NSIndexPath* oldIndexPath = [NSIndexPath indexPathWithIndexes:ints length:2];
		UITableViewCell *oldCell = [self.tableView cellForRowAtIndexPath:oldIndexPath];
		if (oldCell.accessoryType == UITableViewCellAccessoryCheckmark)
			oldCell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	pickedIndex = indexPath.row;
	[self pickedIndex_to_pickedFolder];
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

