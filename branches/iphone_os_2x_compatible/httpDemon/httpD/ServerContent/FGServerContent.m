//
//  FGServerContent.m
//

#import "FGServerContent.h"

@implementation FGServerContent

+ (void)establishRootDirectory
{
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [paths objectAtIndex:0];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *writableFullPath = [docPath stringByAppendingPathComponent:@"root"];
    if (![fileManager fileExistsAtPath:writableFullPath]) 
	{
		NSString *defaultFullPath = [[[NSBundle mainBundle] resourcePath] 
									 stringByAppendingPathComponent:@"root"];
		[fileManager copyItemAtPath:defaultFullPath toPath:writableFullPath error:&error];
	}
}

+ (NSString*)rootDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [paths objectAtIndex:0];
    NSString *writableFullPath = [docPath stringByAppendingPathComponent:@"root"];
	return writableFullPath;
}

@end
