//
//  DefaultsController.m
//

#import "DefaultsController.h"

NSString * const kShowHiddenFiles  = @"kShowHiddenFiles";

NSString * const kFileSpecificDefaults = @"kFileSpecificDefaults";
NSString * const kFileLock         = @"kFileLock";
NSString * const kFileHidden       = @"kFileHidden";

@implementation DefaultsController

#pragma mark Singleton implementation

- (id)init
{
	if(self = [super init]) 
	{
		_defaults = [[NSUserDefaults standardUserDefaults] retain];
		
		/* read defaults in Settings.bundle to 'Registration Domain' in-memory-only */
		NSString *settingsPath = [[NSBundle mainBundle] pathForResource:@"Root" ofType:@"plist" inDirectory:@"Settings.bundle"];
		NSDictionary *settingsDict = [NSDictionary dictionaryWithContentsOfFile:settingsPath];
		NSArray *prefSpecifierArray = [settingsDict objectForKey:@"PreferenceSpecifiers"];
		NSMutableDictionary *defaultDefaults = [NSMutableDictionary dictionaryWithCapacity:prefSpecifierArray.count];
		for (NSDictionary *prefItem in prefSpecifierArray)
		{
			id key          = [prefItem objectForKey:@"Key"];
			id defaultValue = [prefItem objectForKey:@"DefaultValue"];
			if(!key || !defaultValue)
				continue;
			[defaultDefaults setObject:defaultValue forKey:key];
		}		
		[[NSUserDefaults standardUserDefaults] registerDefaults:defaultDefaults];
	}
	return self;
}

static DefaultsController *sharedDefaultsController = nil;

+ (DefaultsController*)sharedDefaultsController
{
	@synchronized(self) 
	{
		if (sharedDefaultsController == nil) 
		{
			[[self alloc] init]; // assignment not done here
		}
	}
	return sharedDefaultsController;
}

+ (id)allocWithZone:(NSZone *)zone 
{
	@synchronized(self) 
	{
		if (sharedDefaultsController == nil) 
		{
			sharedDefaultsController = [super allocWithZone:zone];
			return sharedDefaultsController;  // assignment and return on first allocation
		}
	}	
	return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone {
	return self;
}

- (id)retain {
	return self;
}

- (unsigned)retainCount 
{
	return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release 
{
	//do nothing
}

- (id)autorelease 
{
	return self;
}

#pragma mark Instance method

- (BOOL)defaultsExistingForFile:(NSString*)file
{
	BOOL ret;
	NSDictionary *perFileDefaults = [_defaults objectForKey:kFileSpecificDefaults];
	id object = [perFileDefaults objectForKey:file];
	ret = ( nil == object ) ? YES : NO;
	NSLog(@"file:%@'s defaultsExisting:%d",file,ret);
	return ret;
}

- (NSDictionary*)defaultsForFile:(NSString*)file
{
	NSDictionary *perFileDefaults = [_defaults objectForKey:kFileSpecificDefaults];
	NSDictionary *fileDefaults    = [perFileDefaults objectForKey:file];
	return fileDefaults;
}

- (void)setDefaults:(NSDictionary*)fileDefaults forFile:(NSString*)file
{
	NSMutableDictionary *perFileDefaults = [NSMutableDictionary dictionaryWithDictionary:[_defaults objectForKey:kFileSpecificDefaults]];
	[perFileDefaults setObject:fileDefaults forKey:file];
	[_defaults setObject:perFileDefaults forKey:kFileSpecificDefaults];
}

- (void)deleteDefaultsForFile:(NSString*)file
{
	NSMutableDictionary *perFileDefaults = [NSMutableDictionary dictionaryWithDictionary:[_defaults objectForKey:kFileSpecificDefaults]];
	[perFileDefaults removeObjectForKey:file];
	[_defaults setObject:perFileDefaults forKey:kFileSpecificDefaults];
}

- (void)moveDefaultsForFile:(NSString*)fromFile toFile:(NSString*)toFile
{
	if(![self defaultsExistingForFile:fromFile])
		return;
	[self setDefaults:[self defaultsForFile:fromFile] forFile:toFile];
	[self deleteDefaultsForFile:fromFile];
}

- (void)deleteDefaultsForFolder:(NSString*)folder
{
	if(![self defaultsExistingForFile:folder])
		return;
	// needs to delete all files' defaults in the folder
}

- (void)moveDefaultsForFolder:(NSString*)fromFolder toFolder:(NSString*)toFolder
{
	if(![self defaultsExistingForFile:fromFolder])
		return;
	// needs to check all files' defaults in the fromFolder
}

- (BOOL)showHiddenFiles
{
	BOOL ret = [_defaults boolForKey:kShowHiddenFiles];
	NSLog(@"option showHiddenFiles:%d",ret);
	return ret;
}

- (BOOL)isHiddenOfFile:(NSString*)file
{
	NSDictionary *perFileDefaults = [_defaults objectForKey:kFileSpecificDefaults];
	NSDictionary *fileDefaults    = [perFileDefaults objectForKey:file];
	BOOL          hidden      = [[fileDefaults objectForKey:kFileHidden] boolValue];
	
	if (fileDefaults == nil)
		hidden = NO;
	NSLog(@"%@ is Hidden:%d",file,hidden);
	return hidden;
}

- (void)setHidden:(BOOL)hidden forFile:(NSString*)file
{
	NSMutableDictionary *perFileDefaults = [NSMutableDictionary dictionaryWithDictionary:[_defaults objectForKey:kFileSpecificDefaults]];
	NSMutableDictionary *fileDefaults    = [NSMutableDictionary dictionaryWithDictionary:[perFileDefaults objectForKey:file]];
	NSString            *hiddenStr   = [NSString stringWithFormat:@"%d", (hidden) ? 1 : 0];
	
	[fileDefaults setObject:hiddenStr forKey:kFileHidden];
	[perFileDefaults setObject:fileDefaults forKey:file];
	[_defaults setObject:perFileDefaults forKey:kFileSpecificDefaults];
}

@end
