//
//  File.m
//

#import "File.h"
#import "DefaultsController.h"

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

+ (BOOL)deleteFile:(NSString*)filePath
{	
	// delete the defaults for the file
	[[DefaultsController sharedDefaultsController] deleteDefaultsForFile:filePath];
	
	// delete the file from file system permanently
	[[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
	
	return YES;
}

+ (BOOL)deleteFolder:(NSString*)folderPath
{	
	NSFileManager * fileManager = [NSFileManager defaultManager];
	NSArray * fileArray = [fileManager contentsOfDirectoryAtPath:folderPath error:nil];
	NSString *fullpath;
	for(NSString *file in fileArray)
	{
		if ([file characterAtIndex:0] == (unichar)'.') // Skip invisibles, like .DS_Store
			continue;
		
		BOOL isDir = NO;
		fullpath = [folderPath stringByAppendingPathComponent:file];
		if([fileManager fileExistsAtPath:fullpath isDirectory:&isDir]) 
		{
			if(isDir)
				[File deleteFolder:fullpath];
			else
				[File deleteFile:fullpath];
		}
	}
	
	// delete the defaults for the file
	[[DefaultsController sharedDefaultsController] deleteDefaultsForFile:folderPath];
	
	// delete the file from file system permanently
	[[NSFileManager defaultManager] removeItemAtPath:folderPath error:NULL];
	
	return YES;
}

- (BOOL)delete
{
	NSString* fullpath = [parentDirectory stringByAppendingPathComponent:name];
	if(isDirectory)
		return [File deleteFolder:fullpath];
	else
		return [File deleteFile:fullpath];
}

@end
