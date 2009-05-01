//
//  DefaultsController.h
//

#import <Foundation/Foundation.h>

@interface DefaultsController : NSObject {
@private	
	NSUserDefaults *_defaults;
	NSInteger       _lockedFileCount;
	BOOL            _autoPasswordValid;
	NSTimer        *_autoPasswordTimer;
}

+ (DefaultsController*)sharedDefaultsController;
- (BOOL)synchronize;

extern NSString * const kShowHiddenFiles;

extern NSString * const kShowUnreadableFiles;


/* Key used to retrieve the dictionary that contains all books' specific dictionary
 * every key of the dictionary is a file/folder full path 
 */
extern NSString * const kFileSpecificDefaults;

/* Keys used in each book specific dictionary which is the retrieved value data for a specific file/folder */
extern NSString * const kFileEncoding;
extern NSString * const kFileLocked;
extern NSString * const kFileHidden;
extern NSString * const kAutoPasswordInterval;

- (BOOL)defaultsExistingForFile:(NSString*)file;

- (void)deleteDefaultsForFile:(NSString*)file;
- (void)deleteDefaultsForFolder:(NSString*)folder;

- (void)moveDefaultsForFile:(NSString*)fromFile toFile:(NSString*)toFile;
- (void)moveDefaultsForFolder:(NSString*)fromFolder toFolder:(NSString*)toFolder;

- (BOOL)showHiddenFiles;
- (BOOL)showUnreadableFiles;

- (BOOL)isHiddenOfFile:(NSString*)file;
- (void)setHidden:(BOOL)hidden forFile:(NSString*)file;

- (BOOL)isLockedOfFile:(NSString*)file;
- (void)setLocked:(BOOL)locked forFile:(NSString*)file;

- (NSUInteger)lockedFileCount;

- (void)autoPasswordEnable;
- (void)autoPasswordDisable;
- (BOOL)autoPasswordValid;


- (void)dumpFileSpecificDefaults:(NSString*)prefix;

@end
