//
//  DefaultsController.m
//

#import "DefaultsController.h"

NSString * const kShowHiddenFiles  = @"kShowHiddenFiles";

NSString * const kFileSpecificData = @"kFileSpecificData";
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

- (BOOL)showHiddenFiles
{
	BOOL ret = [_defaults boolForKey:kShowHiddenFiles];
	NSLog(@"option showHiddenFiles:%d",ret);
	return ret;
}

- (BOOL)isHiddenOfFile:(NSString*)file
{
	NSDictionary *perFileData = [_defaults objectForKey:kFileSpecificData];
	NSDictionary *fileData    = [perFileData objectForKey:file];
	BOOL          hidden      = [[fileData objectForKey:kFileHidden] boolValue];
	
	if (fileData == nil)
		hidden = NO;
	NSLog(@"%@ is Hidden:%d",file,hidden);
	return hidden;
}

- (void)setHidden:(BOOL)hidden forFile:(NSString*)file
{
	NSMutableDictionary *perFileData = [NSMutableDictionary dictionaryWithDictionary:[_defaults objectForKey:kFileSpecificData]];
	NSMutableDictionary *fileData    = [NSMutableDictionary dictionaryWithDictionary:[perFileData objectForKey:file]];
	NSString            *hiddenStr   = [NSString stringWithFormat:@"%d", (hidden) ? 1 : 0];
	
	[fileData setObject:hiddenStr forKey:kFileHidden];
	[perFileData setObject:fileData forKey:file];
	[_defaults setObject:perFileData forKey:kFileSpecificData];
}

@end
