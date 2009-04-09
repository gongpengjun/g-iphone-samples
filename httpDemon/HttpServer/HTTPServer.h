#import <Foundation/Foundation.h>

@class AsyncSocket,HTTPServer;

enum  {
	HTTPServerStatusStopped             = 0,
	HTTPServerStatusStarted             = 1 << 0,
	HTTPServerStatusNetServicePublished	= 1 << 1,
	HTTPServerStatusConnected           = 1 << 2
};

typedef int HTTPServerStatus;

@protocol HTTPServerDelegate <NSObject>
@optional
- (void)httpServer:(HTTPServer*)server changeToStatus:(HTTPServerStatus)newStatus;
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
@property(readonly) NSMutableArray *connections;

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
