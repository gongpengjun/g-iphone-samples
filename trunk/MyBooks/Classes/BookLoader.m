//
//  BookLoader.m
//

#import "BookLoader.h"
#import "Book.h"
#import "FGFileManager.h"

static BookLoader *s_bookLoader = nil;

@implementation BookLoader

@synthesize books;

- (void)dealloc
{
	[books release];
	[super dealloc];
}

+ (id)sharedInstance
{
	if(!s_bookLoader)
	{
		s_bookLoader = [[BookLoader alloc] init];
	}
	return s_bookLoader;
}

- (id)init
{
	if(self = [super init])
	{
		NSString * path = [FGFileManager fullPathOfFile:@"pdf"];
		NSArray * fileNameArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
		NSMutableArray *mutableBooks = [NSMutableArray arrayWithCapacity:fileNameArray.count];
		for(NSString *fileName in fileNameArray)
		{
			if([fileName hasSuffix:@".pdf"])
			{
				Book *aBook = [[Book alloc] init];
				if(fileName.length > 4)
					aBook.title = [fileName substringWithRange:NSMakeRange(0,fileName.length - 4)];
				else
					aBook.title = fileName;
				aBook.name = fileName;
				aBook.basePath = @"pdf";
				[mutableBooks addObject:aBook]; // Array'books' retain the object 'aBook'
				[aBook release];
			}
		}
		self.books = mutableBooks;
	}
	return self;
}

@end
