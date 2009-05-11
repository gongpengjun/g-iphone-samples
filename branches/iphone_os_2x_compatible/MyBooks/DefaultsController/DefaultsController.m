//
//  DefaultsController.m
//

#import "DefaultsController.h"

NSString * const kShowHiddenFiles     = @"kShowHiddenFiles";
NSString * const kShowUnreadableFiles = @"kShowUnreadableFiles";

NSString * const kFileSpecificDefaults = @"kFileSpecificDefaults";
NSString * const kFileLocked		   = @"kFileLocked";
NSString * const kFileHidden		   = @"kFileHidden";
NSString * const kAutoPasswordInterval = @"kAutoPasswordInterval";

@interface DefaultsController (Private)
- (void)initLockedFileCount;
@end

@implementation DefaultsController

#pragma mark Singleton implementation

- (id)init
{
	if(self = [super init]) 
	{
		_defaults = [[NSUserDefaults standardUserDefaults] retain];
		[self initLockedFileCount];
		
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
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		_DocumentsPath = [paths objectAtIndex:0];
		[_DocumentsPath retain];
		_DocumentsPathLength = _DocumentsPath.length;
		NSLog(@"Documents path: %@",_DocumentsPath);
	}
	return self;
}

- (BOOL)synchronize
{
	return [_defaults synchronize];
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

- (void)dumpFileSpecificDefaults:(NSString*)prefix
{
	#ifndef __OPTIMIZE__
	NSDictionary *perFileDefaults = [_defaults objectForKey:kFileSpecificDefaults];
	NSLog(@"file specific defaults(%@):\n%@",prefix,perFileDefaults);
	#endif
}

- (BOOL)defaultsExistingForFile:(NSString*)file
{
	NSString* rPath = [file substringFromIndex:_DocumentsPathLength];
	BOOL ret;
	NSDictionary *perFileDefaults = [_defaults objectForKey:kFileSpecificDefaults];
	id object = [perFileDefaults objectForKey:rPath];
	ret = ( nil == object ) ? NO : YES;
	//NSLog(@"file:%@'s defaultsExisting:%d",rPath,ret);
	return ret;
}

- (NSDictionary*)defaultsForFile:(NSString*)file
{
	NSString* rPath = [file substringFromIndex:_DocumentsPathLength];
	NSDictionary *perFileDefaults = [_defaults objectForKey:kFileSpecificDefaults];
	NSDictionary *fileDefaults    = [perFileDefaults objectForKey:rPath];
	return fileDefaults;
}

- (void)setDefaults:(NSDictionary*)fileDefaults forFile:(NSString*)file
{
	NSString* rPath = [file substringFromIndex:_DocumentsPathLength];
	NSMutableDictionary *perFileDefaults = [NSMutableDictionary dictionaryWithDictionary:[_defaults objectForKey:kFileSpecificDefaults]];
	[perFileDefaults setObject:fileDefaults forKey:rPath];
	[_defaults setObject:perFileDefaults forKey:kFileSpecificDefaults];
}

- (void)deleteDefaultsForFile:(NSString*)file
{
	NSString* rPath = [file substringFromIndex:_DocumentsPathLength];
	if([self isLockedOfFile:file])
		_lockedFileCount--;
	NSMutableDictionary *perFileDefaults = [NSMutableDictionary dictionaryWithDictionary:[_defaults objectForKey:kFileSpecificDefaults]];
	[perFileDefaults removeObjectForKey:rPath];
	[_defaults setObject:perFileDefaults forKey:kFileSpecificDefaults];
}

- (void)moveDefaultsForFile:(NSString*)fromFile toFile:(NSString*)toFile
{
	if([self defaultsExistingForFile:fromFile])
	{
		[self dumpFileSpecificDefaults:@"before moveDefaultsForFile"];
		[self setDefaults:[self defaultsForFile:fromFile] forFile:toFile];
		if([self isLockedOfFile:toFile])
			_lockedFileCount++;
		[self deleteDefaultsForFile:fromFile];
		[self dumpFileSpecificDefaults:@"after  moveDefaultsForFile"];
	}
}

- (void)deleteDefaultsForFolder:(NSString*)folder
{
	NSFileManager * fileManager = [NSFileManager defaultManager];
	NSArray * fileArray = [fileManager contentsOfDirectoryAtPath:folder error:nil];
	NSString *fullpath;
	for(NSString *file in fileArray)
	{
		if([file characterAtIndex:0] == (unichar)'.') // Skip invisibles, like .DS_Store
			continue;
		
		BOOL isDir = NO;
		fullpath = [folder stringByAppendingPathComponent:file];
		if([fileManager fileExistsAtPath:fullpath isDirectory:&isDir])
		{
			if(isDir)
				[self deleteDefaultsForFolder:fullpath];
			else
				[self deleteDefaultsForFile:fullpath];
		}
	}
	
	[self deleteDefaultsForFile:folder];
}

- (void)moveDefaultsForFolder:(NSString*)fromFolder toFolder:(NSString*)toFolder
{
	NSFileManager * fileManager = [NSFileManager defaultManager];
	NSArray * fileArray = [fileManager contentsOfDirectoryAtPath:fromFolder error:nil];
	NSString *oldFullPath;
	NSString *newFullPath;
	for(NSString *file in fileArray)
	{
		if ([file characterAtIndex:0] == (unichar)'.') // Skip invisibles, like .DS_Store
			continue;

		BOOL isDir = NO;
		oldFullPath = [fromFolder stringByAppendingPathComponent:file];
		newFullPath = [toFolder stringByAppendingPathComponent:file];
		if([fileManager fileExistsAtPath:oldFullPath isDirectory:&isDir])
		{
			if(isDir)
				[self moveDefaultsForFolder:oldFullPath toFolder:newFullPath];
			else
				[self moveDefaultsForFile:oldFullPath toFile:newFullPath];
		}
	}
	
	[self moveDefaultsForFile:fromFolder toFile:toFolder];
}

- (BOOL)showHiddenFiles
{
	BOOL ret = [_defaults boolForKey:kShowHiddenFiles];
	//NSLog(@"option showHiddenFiles:%d",ret);
	return ret;
}

- (BOOL)showUnreadableFiles
{
	BOOL ret = [_defaults boolForKey:kShowUnreadableFiles];
	//NSLog(@"option kShowUnreadableFiles:%d",ret);
	return ret;
}

- (BOOL)isHiddenOfFile:(NSString*)file
{
	NSString* rPath = [file substringFromIndex:_DocumentsPathLength];
	NSDictionary *perFileDefaults = [_defaults objectForKey:kFileSpecificDefaults];
	NSDictionary *fileDefaults    = [perFileDefaults objectForKey:rPath];
	BOOL          hidden          = [[fileDefaults objectForKey:kFileHidden] boolValue];
	
	if (fileDefaults == nil)
		hidden = NO;
	//NSLog(@"%@ is Hidden:%d",rPath,hidden);
	return hidden;
}

- (void)setHidden:(BOOL)hidden forFile:(NSString*)file
{
	NSString* rPath = [file substringFromIndex:_DocumentsPathLength];
	NSMutableDictionary *perFileDefaults = [NSMutableDictionary dictionaryWithDictionary:[_defaults objectForKey:kFileSpecificDefaults]];
	NSMutableDictionary *fileDefaults    = [NSMutableDictionary dictionaryWithDictionary:[perFileDefaults objectForKey:rPath]];
	NSString            *hiddenStr   = [NSString stringWithFormat:@"%d", (hidden) ? 1 : 0];
	
	//NSLog(@"%@ setHidden:%d",rPath,hidden);
	[fileDefaults setObject:hiddenStr forKey:kFileHidden];
	[perFileDefaults setObject:fileDefaults forKey:rPath];
	[_defaults setObject:perFileDefaults forKey:kFileSpecificDefaults];
}

- (BOOL)isLockedOfFile:(NSString*)file
{
	NSString* rPath = [file substringFromIndex:_DocumentsPathLength];
	NSDictionary *perFileDefaults = [_defaults objectForKey:kFileSpecificDefaults];
	NSDictionary *fileDefaults    = [perFileDefaults objectForKey:rPath];
	BOOL          locked          = [[fileDefaults objectForKey:kFileLocked] boolValue];
	
	if (fileDefaults == nil)
		locked = NO;
	NSLog(@"%@ is Locked:%d",rPath,locked);
	return locked;
}

- (void)setLocked:(BOOL)locked forFile:(NSString*)file
{
	NSString* rPath = [file substringFromIndex:_DocumentsPathLength];
	if(locked == [self isLockedOfFile:file])
		return;
	
	NSMutableDictionary *perFileDefaults = [NSMutableDictionary dictionaryWithDictionary:[_defaults objectForKey:kFileSpecificDefaults]];
	NSMutableDictionary *fileDefaults    = [NSMutableDictionary dictionaryWithDictionary:[perFileDefaults objectForKey:rPath]];
	NSString            *lockedStr       = [NSString stringWithFormat:@"%d", (locked) ? 1 : 0];
	
	NSLog(@"%@ setLocked:%d",rPath,locked);
	[fileDefaults setObject:lockedStr forKey:kFileLocked];
	[perFileDefaults setObject:fileDefaults forKey:rPath];
	[_defaults setObject:perFileDefaults forKey:kFileSpecificDefaults];
	
	if(locked)
		_lockedFileCount++;
	else
		_lockedFileCount--;
}

- (void)initLockedFileCount
{
	_lockedFileCount = 0;
	NSDictionary *perFileDefaults = [_defaults objectForKey:kFileSpecificDefaults];
	NSLog(@"file specific defaults:\n%@",perFileDefaults);

	NSEnumerator *enumerator = [perFileDefaults objectEnumerator];
	NSDictionary *fileDefaults;	
	while ((fileDefaults = [enumerator nextObject])) 
	{
		NSLog(@"fileDefaults:%@",fileDefaults);
		if([[fileDefaults objectForKey:kFileLocked] boolValue])
			_lockedFileCount++;
	}
	NSLog(@"locked file count:%d",_lockedFileCount);
}

- (NSUInteger)lockedFileCount
{
	if(_lockedFileCount < 0)
	{		
		[self initLockedFileCount];
	}
	return _lockedFileCount;
}

- (void)autoPasswordTimerLaunch
{	
	NSTimeInterval autoPasswordInterval = [_defaults doubleForKey:kAutoPasswordInterval];
	
	NSLog([NSString stringWithFormat:@"auto password interval:%1.1f seconds",autoPasswordInterval]);
	
	if(autoPasswordInterval >= 300)
	{
		_autoPasswordValid = YES;
		_autoPasswordTimer = [NSTimer scheduledTimerWithTimeInterval:autoPasswordInterval
															  target: self
															selector: @selector(autoPasswordTimerAction:)
															userInfo: nil
															 repeats: NO];
	}
	else
	{
		_autoPasswordValid = NO;
	}
}

- (void)autoPasswordTimerSuspend
{
	_autoPasswordValid = NO;
	
	if(_autoPasswordTimer && [_autoPasswordTimer isValid])
	{
		[_autoPasswordTimer invalidate];
		_autoPasswordTimer = nil;
	}
}

- (void)autoPasswordTimerAction:(id)timer
{
	_autoPasswordValid = NO;
}

- (BOOL)autoPasswordValid
{
	return _autoPasswordValid;
}

- (void)autoPasswordEnable
{
	[self autoPasswordTimerLaunch];
}

- (void)autoPasswordDisable
{
	[self autoPasswordTimerSuspend];
}


@end
