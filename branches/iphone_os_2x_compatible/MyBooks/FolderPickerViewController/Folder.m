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

static UIImage * s_folderImage      = nil;
static UIImage * s_smallFolderImage = nil;

+ (UIImage*)folderImage
{
	if(!s_folderImage)
		s_folderImage = [[UIImage imageNamed:@"Folder.png"] retain];
	return s_folderImage;
}

+ (UIImage*)smallFolderImage
{
	if(!s_smallFolderImage)
		s_smallFolderImage = [[UIImage imageNamed:@"SmallFolder.png"] retain];
	return s_smallFolderImage;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@:%u",name,level];
}

@end
