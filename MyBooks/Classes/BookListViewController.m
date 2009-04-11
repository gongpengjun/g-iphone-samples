//
//  BookListViewController.m
//

#import "BookListViewController.h"
#import "BookReaderViewController.h"
#import "FGFileManager.h"
#import "Book.h"
#import "BookLoader.h"

@implementation BookListViewController

- (void)dealloc 
{
    [super dealloc];
}

- (id)init
{
	if(self = [super initWithStyle:UITableViewStyleGrouped])
	{
		self.title = NSLocalizedString(@"My Books", @"");
	}
	return self;
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload 
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// we support rotation in this view controller
	return YES;
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [[[BookLoader sharedInstance] books] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
	{
		#if __IPHONE_OS_VERSION_MAX_ALLOWED < 30000
		/*iPhone OS 2.2.1*/
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
		#else
		/*iPhone OS 3.0+*/
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		#endif
    }
    
	Book *aBook = [[[BookLoader sharedInstance] books] objectAtIndex:indexPath.row];
	
	#if __IPHONE_OS_VERSION_MAX_ALLOWED < 30000
	/*iPhone OS 2.2.1*/
	cell.text = aBook.name;
	#else
	/*iPhone OS 3.0+*/
	cell.textLabel.text = aBook.name;
	#endif
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	BookReaderViewController *bookReaderViewController = [BookReaderViewController sharedInstance];
	bookReaderViewController.book = [[[BookLoader sharedInstance] books] objectAtIndex:indexPath.row];
	[self.navigationController pushViewController:bookReaderViewController animated:YES];
}

@end
