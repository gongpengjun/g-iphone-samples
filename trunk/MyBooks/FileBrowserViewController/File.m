//
//  File.m
//

#import "File.h"

@implementation File

@synthesize isDirectory,name,parentDirectory;

- (void)dealloc
{
	[parentDirectory release];
	[name release];
	[super dealloc];
}

static UIImage * s_folderImage = nil;
static UIImage * s_fileImage   = nil;

+ (UIImage*)folderImage
{
	if(!s_folderImage)
		s_folderImage = [[UIImage imageNamed:@"collection_small.png"] retain];
	return s_folderImage;
}

+ (UIImage*)fileImage
{
	if(!s_fileImage)
		s_fileImage = [[UIImage imageNamed:@"generic_small.png"] retain];
	return s_fileImage;
}

@end
