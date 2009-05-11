//
//  PasswordKeeper.m
//

#import "PasswordKeeper.h"
#import <Security/Security.h>

@implementation PasswordKeeper

static PasswordKeeper *s_sharedPasswordKeeper = nil;

+ (PasswordKeeper *)sharedPasswordKeeper 
{
    if(!s_sharedPasswordKeeper) 
	{
		s_sharedPasswordKeeper = [[self alloc] init];
    }
    return s_sharedPasswordKeeper;
}

#if TARGET_IPHONE_SIMULATOR

NSString *kPasswordKey          = @"kPassword";

- (NSString *) fetchPassword
{
	NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:kPasswordKey];
	return password;	
}

- (BOOL) setPassword: (NSString *) thePassword
{
	[[NSUserDefaults standardUserDefaults] setObject:thePassword forKey:kPasswordKey];
	[[NSUserDefaults standardUserDefaults] synchronize];	
	return YES;
}

#else

// Translate status messages into return strings
- (NSString *) fetchStatus : (OSStatus) status
{
	if		(status == 0) return(@"Success!");
	else if (status == errSecNotAvailable) return(@"No trust results are available.");
	else if (status == errSecItemNotFound) return(@"The item cannot be found.");
	else if (status == errSecParam) return(@"Parameter error.");
	else if (status == errSecAllocate) return(@"Memory allocation error. Failed to allocate memory.");
	else if (status == errSecInteractionNotAllowed) return(@"User interaction is not allowed.");
	else if (status == errSecUnimplemented ) return(@"Function is not implemented");
	else if (status == errSecDuplicateItem) return(@"The item already exists.");
	else if (status == errSecDecode) return(@"Unable to decode the provided data.");
	else 
		return([NSString stringWithFormat:@"Function returned: %d", status]);
}

#define	ACCOUNT	@"GongPengjun iPhone Application Account"
#define	SERVICE	@"GongPengjun iPhone Application Service"
#define PWKEY	@"GongPengjun iPhone Application Password Data"

// Return a base dictionary
- (NSMutableDictionary *) baseDictionary
{
	NSMutableDictionary *md = [[NSMutableDictionary alloc] init];
	
	// Password identification keys
	NSData *identifier = [PWKEY dataUsingEncoding:NSUTF8StringEncoding];
	[md setObject:identifier forKey:(id)kSecAttrGeneric];
	[md setObject:ACCOUNT forKey:(id)kSecAttrAccount];
    [md setObject:SERVICE forKey:(id)kSecAttrService];
	[md setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
	
	return [md autorelease];
}

// Return a keychain-style dictionary populated with the password
- (NSMutableDictionary *) buildDictForPassword:(NSString *) password
{
	
	NSMutableDictionary *passwordDict = [self baseDictionary];
	
	// Add the password
	NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
    [passwordDict setObject:passwordData forKey:(id)kSecValueData]; // password 
	
	return passwordDict;
}

// Build a search query based
- (NSMutableDictionary *) buildSearchQuery
{
	NSMutableDictionary *genericPasswordQuery = [self baseDictionary];
	
	// Add the search constraints
	[genericPasswordQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
	[genericPasswordQuery setObject:(id)kCFBooleanTrue
							 forKey:(id)kSecReturnAttributes];
	[genericPasswordQuery setObject:(id)kCFBooleanTrue
							 forKey:(id)kSecReturnData];
	
	return genericPasswordQuery;
}

// retrieve data dictionary from the keychain
- (NSMutableDictionary *) fetchDictionary
{
	NSMutableDictionary *genericPasswordQuery = [self buildSearchQuery];
	
	NSMutableDictionary *outDictionary = nil;
	OSStatus status = SecItemCopyMatching((CFDictionaryRef)genericPasswordQuery, (CFTypeRef *)&outDictionary);

	#if DEBUG
	printf("FETCH: %s\n", [[self fetchStatus:status] UTF8String]);
	#endif
	
	if (status == errSecItemNotFound) return NULL;
	return outDictionary;
}	

// create a new keychain entry
- (BOOL) createKeychainValue:(NSString *) password
{
	NSMutableDictionary *md = [self buildDictForPassword:password];
	OSStatus status = SecItemAdd((CFDictionaryRef)md, NULL);

	#if DEBUG
	printf("CREATE: %s\n", [[self fetchStatus:status] UTF8String]);
	#endif
	
	if (status == noErr) return YES; else return NO;
}

// remove a keychain entry
- (void) clearKeychain
{
	NSMutableDictionary *genericPasswordQuery = [self baseDictionary];
	
	OSStatus status = SecItemDelete((CFDictionaryRef) genericPasswordQuery);
	
	#if DEBUG
	printf("DELETE: %s\n", [[self fetchStatus:status] UTF8String]);
	#else
	status = status;
	#endif
}

// update a keychaing entry
- (BOOL) updateKeychainValue:(NSString *)password
{
	NSMutableDictionary *genericPasswordQuery = [self baseDictionary];
	
	NSMutableDictionary *attributesToUpdate = [[NSMutableDictionary alloc] init];
	NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
	[attributesToUpdate setObject:passwordData forKey:(id)kSecValueData];
	
	OSStatus status = SecItemUpdate((CFDictionaryRef)genericPasswordQuery, (CFDictionaryRef)attributesToUpdate);
	
	#if DEBUG
	printf("UPDATE: %s\n", [[self fetchStatus:status] UTF8String]);
	#endif	
	
	if (status == 0) return YES; else return NO;
}

// fetch a keychain value
- (NSString *) fetchPassword
{
	NSMutableDictionary *outDictionary = [self fetchDictionary];
	
	if (outDictionary)
	{
		NSString *password = [[NSString alloc] initWithData:[outDictionary objectForKey:(id)kSecValueData] encoding:NSUTF8StringEncoding];
		return [password autorelease];
	} else return NULL;
}

- (BOOL) setPassword: (NSString *) thePassword
{
	BOOL success;
	success = [self createKeychainValue:thePassword];
	if (!success) 
		success = [self updateKeychainValue:thePassword];
	return success;
}
#endif

@end
