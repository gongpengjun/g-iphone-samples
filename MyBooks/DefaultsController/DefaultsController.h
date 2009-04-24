//
//  DefaultsController.h
//

#import <Foundation/Foundation.h>

@interface DefaultsController : NSObject {
@private	
	NSUserDefaults *_defaults;
}

+ (DefaultsController*)sharedDefaultsController;
- (BOOL)synchronize;

extern NSString * const kShowHiddenFiles;

/* Key used to retrieve the dictionary that contains all books' specific dictionary
 * every key of the dictionary is a file/folder full path 
 */
extern NSString * const kFileSpecificDefaults;

/* Keys used in each book specific dictionary which is the retrieved value data for a specific file/folder */
extern NSString * const kFileEncoding;
extern NSString * const kFileLock;
extern NSString * const kFileHidden;

- (BOOL)defaultsExistingForFile:(NSString*)file;

- (void)deleteDefaultsForFile:(NSString*)file;
- (void)deleteDefaultsForFolder:(NSString*)folder;

- (void)moveDefaultsForFile:(NSString*)fromFile toFile:(NSString*)toFile;
- (void)moveDefaultsForFolder:(NSString*)fromFolder toFolder:(NSString*)toFolder;

- (BOOL)showHiddenFiles;

- (BOOL)isHiddenOfFile:(NSString*)file;
- (void)setHidden:(BOOL)hidden forFile:(NSString*)file;

- (void)dumpFileSpecificDefaults:(NSString*)prefix;

@end
