//
//  Book.m
//

#import "Book.h"

@implementation Book

@synthesize title,name,basePath;

- (void)dealloc
{
	[title release];
	[name release];
	[basePath release];
	[super dealloc];
}

- (id)init
{
	if(self = [super init])
	{
	}
	return self;
}

@end
