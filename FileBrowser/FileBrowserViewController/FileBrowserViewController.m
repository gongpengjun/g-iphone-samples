//
//  FileTableViewController.m
//

#import "FileBrowserViewController.h"
#import "File.h"

@interface FileBrowserViewController (Private)
- (void)reloadFiles;
@end

@implementation FileBrowserViewController

@synthesize path,visibleExtensions,files;

- (void)dealloc 
{
	[visibleExtensions release];
	[path release];
	[files release];
    [super dealloc];
}

- (id)init
{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) 
	{
		self.title = @"File Browser";
		visibleExtensions = [[NSArray arrayWithObjects:@"txt", @"htm", @"html", @"pdb", @"pdf", @"jpg", @"png", @"gif", nil] retain];
		files = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)setPath:(NSString*)newPath
{
	[newPath retain];
	[path release];
	path = newPath;
	self.title = [path lastPathComponent];
	[self reloadFiles];
}

- (void)reloadFiles
{
	NSFileManager * fileManager = [NSFileManager defaultManager];
	NSArray * fileArray = [fileManager contentsOfDirectoryAtPath:path error:nil];
	for(NSString *file in fileArray)
	{
		if ([file characterAtIndex:0] == (unichar)'.') // Skip invisibles, like .DS_Store
			continue;
		
		BOOL isDir = NO;
		if([fileManager fileExistsAtPath:[path stringByAppendingPathComponent:file] isDirectory:&isDir]) 
		{
			File *aFile;
			if(isDir) 
			{
				aFile = [[File alloc] init];
				aFile.name = file;
				aFile.isDirectory = isDir;
				[files addObject:aFile];
				[aFile release];
			} 
			else
			{
				NSAssert(visibleExtensions,@"Please set visibleExtensions before setPath.");
				NSString *extension = [[file pathExtension] lowercaseString];
				if ([visibleExtensions containsObject:extension]) 
				{
					aFile = [[File alloc] init];
					aFile.name = file;
					aFile.isDirectory = isDir;
					[files addObject:aFile];
					[aFile release];
				}
			} 
		}
	}
}

/*
- (void)viewDidLoad 
{
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

/*
- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
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
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	File *aFile = [files objectAtIndex:[indexPath row]];
	cell.textLabel.text = aFile.name;
	if([aFile isDirectory])
		cell.imageView.image = [File folderImage];
	else
		cell.imageView.image = [File fileImage];
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	File *aFile = [files objectAtIndex:indexPath.row];
	if(aFile.isDirectory)
	{
		FileBrowserViewController *anotherViewController = [[FileBrowserViewController alloc] init];
		anotherViewController.path = [path stringByAppendingPathComponent:aFile.name];
		[self.navigationController pushViewController:anotherViewController animated:YES];
		[anotherViewController release];
	}
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

