//
//  Folder.m
//

#import "Folder.h"

@implementation Folder

@synthesize level,name,parentFolder;

- (void)dealloc
{
	[name release];
	[parentFolder release];
	[super dealloc];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@:%u",name,level];
}

@end
