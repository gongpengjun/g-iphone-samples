//
//  File.m
//

#import "File.h"
#import "DefaultsController.h"

@interface File(Private)
+ (BOOL)deleteFile:(NSString*)filePath;
+ (BOOL)deleteFolder:(NSString*)folderPath;

+ (BOOL)renameFile:(NSString*)oldFilePath toFile:(NSString*)newFilePath;
+ (BOOL)renameFolder:(NSString*)oldFolderPath toFolder:(NSString*)newFolderPath;
@end

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
	[[DefaultsController sharedDefaultsController] deleteDefaultsForFile:filePath];
	[[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
	return YES;
}

+ (BOOL)deleteFolder:(NSString*)folderPath
{
	// delete the defaults for the folder recursively
	[[DefaultsController sharedDefaultsController] deleteDefaultsForFolder:folderPath];
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

+ (BOOL)renameFile:(NSString*)oldFilePath toFile:(NSString*)newFilePath
{
	[[DefaultsController sharedDefaultsController] moveDefaultsForFile:oldFilePath toFile:newFilePath];
	[[NSFileManager defaultManager] moveItemAtPath:oldFilePath toPath:newFilePath error:NULL];
	return YES;
}

+ (BOOL)renameFolder:(NSString*)oldFolderPath toFolder:(NSString*)newFolderPath
{
	// delete the defaults for the folder recursively
	[[DefaultsController sharedDefaultsController] moveDefaultsForFolder:oldFolderPath toFolder:newFolderPath];
	[[NSFileManager defaultManager] moveItemAtPath:oldFolderPath toPath:newFolderPath error:NULL];
	return YES;
}

- (BOOL)renameTo:(NSString*)newName
{
	NSString* oldFullpath = [parentDirectory stringByAppendingPathComponent:name];
	NSString* newFullpath = [parentDirectory stringByAppendingPathComponent:newName];
	if(isDirectory)
		return [File renameFolder:oldFullpath toFolder:newFullpath];
	else
		return [File renameFile:oldFullpath toFile:newFullpath];
}

@end
