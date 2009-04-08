#import <Foundation/Foundation.h>

@class AsyncSocket,HTTPServer;

enum  {
	HTTPServerStatusStarted				= 0,
	HTTPServerStatusStopped				= 1 << 0,
	HTTPServerStatusNetServiceStarted	= 1 << 1
};

typedef int HTTPServerStatus;

@protocol HTTPServerDelegate
@optional
- (void)httpServer:(HTTPServer*)server statusChangedTo:(HTTPServerStatus)status;
@end

@interface HTTPServer : NSObject
{
	// Underlying asynchronous TCP/IP socket
	AsyncSocket *asyncSocket;
	
	// Standard delegate
	id<HTTPServerDelegate> delegate;
	HTTPServerStatus status;
	
	// HTTP server configuration
	NSURL *documentRoot;
	Class connectionClass;
	
	// NSNetService and related variables
	NSNetService *netService;
    NSString *domain;
	NSString *type;
    NSString *name;
	UInt16 port;
	NSDictionary *txtRecordDictionary;
	
	NSMutableArray *connections;	
}

@property(assign) UInt16 port;

- (id)delegate;
- (void)setDelegate:(id)newDelegate;

- (NSURL *)documentRoot;
- (void)setDocumentRoot:(NSURL *)value;

- (Class)connectionClass;
- (void)setConnectionClass:(Class)value;

- (NSString *)domain;
- (void)setDomain:(NSString *)value;

- (NSString *)type;
- (void)setType:(NSString *)value;

- (NSString *)name;
- (void)setName:(NSString *)value;

- (UInt16)port;
- (void)setPort:(UInt16)value;

- (NSDictionary *)TXTRecordDictionary;
- (void)setTXTRecordDictionary:(NSDictionary *)dict;

- (BOOL)start:(NSError **)error;
- (BOOL)stop;

- (int)numberOfHTTPConnections;

@end
