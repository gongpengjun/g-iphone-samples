//
//  Book.m
//

#import "Book.h"

@implementation Book

@synthesize title,name,basePath,hidden;

- (void)dealloc
{
	[title release];
	[name release];
	[basePath release];
	[super dealloc];
}

@end
