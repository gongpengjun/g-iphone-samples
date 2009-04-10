//
//  FGDirectoryService.m
//

#import "FGDirectoryService.h"

@implementation FGDirectoryService

+ (void)establishRootDirectory
{
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [paths objectAtIndex:0];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *writableFullPath = [docPath stringByAppendingPathComponent:@"Books"];
    if (![fileManager fileExistsAtPath:writableFullPath]) 
	{
		NSString *defaultFullPath = [[[NSBundle mainBundle] resourcePath] 
									 stringByAppendingPathComponent:@"Books"];
		[fileManager copyItemAtPath:defaultFullPath toPath:writableFullPath error:&error];
	}
}

+ (NSString*)rootDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [paths objectAtIndex:0];
    NSString *writableFullPath = [docPath stringByAppendingPathComponent:@"Books"];
	return writableFullPath;
}

+ (NSString*)fullPathOfFile:(NSString*)file
{
	return [[FGDirectoryService rootDirectory] stringByAppendingPathComponent:file];
}

@end
