//
//  BARServer.m
//  Barista
//
//  Created by Steve Streza on 4/23/13.
//  Copyright (c) 2013: Steve Streza
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//  of the Software, and to permit persons to whom the Software is furnished to do
//  so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "BARServer.h"

#import "BARConnection.h"
#import "GCDAsyncSocket.h"

@interface BARConnection (BARServer)

+(instancetype)connectionWithIncomingSocket:(GCDAsyncSocket *)socket server:(BARServer *)server;

@end

@implementation BARServer {
	GCDAsyncSocket *_socket;
	NSMutableArray *_connections;
	NSMutableArray *_globalMiddleware;
}

@synthesize listening=_listening;

+(instancetype)serverWithBoundHost:(NSString *)host port:(uint16_t)port{
	return [[self alloc] initWithBoundHost:host port:port];
}

+(instancetype)serverWithPort:(uint16_t)port{
	return [self serverWithBoundHost:nil port:port];
}

-(instancetype)initWithBoundHost:(NSString *)boundHost port:(uint16_t)port{
	if(self = [super init]){
		_boundHost = boundHost;
		_port = port;
		
		_dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
		
		_unhandledRequestHandler = [^(BARRequest *request, BARConnection *connection){
			BARResponse *response = [[BARResponse alloc] init];
			response.statusCode = 404;
			response.responseData = [[NSString stringWithFormat:@"Could not %@ %@", request.HTTPMethod, request.URL.path] dataUsingEncoding:NSUTF8StringEncoding];
			[connection sendResponse:response];
		} copy];
	}
	return self;
}

-(BOOL)isListening{
	return _listening;
}

-(BOOL)startListening{
	if([self isListening]) return NO;

	_listening = YES;

	if(!_socket){
		_socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
	}
	NSError *error = nil;
	_socket.delegate = self;
	
	if(![_socket acceptOnInterface:self.boundHost port:self.port error:&error]){
		NSLog(@"Couldn't start socket: %@", error);
		return NO;
	}else{
		NSLog(@"Listening on %i", self.port);
		
		return YES;
	}
}

-(BOOL)stopListening{
	if(![self isListening]) return NO;

	_listening = NO;
	
	[_socket disconnect];
	return YES;
}

-(void)setListening:(BOOL)listening{
	if(listening == [self isListening]) return;
	
	if(listening) {
		[self startListening];
	}else{
		[self stopListening];
	}
}

-(void)runForever{
	while(YES){
		[[NSRunLoop mainRunLoop] run];
	}
}

#pragma mark Sockets

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket{
	if(!_connections){
		_connections = [NSMutableArray array];
	}
	
	BARConnection *connection = [BARConnection connectionWithIncomingSocket:newSocket server:self];
	[_connections addObject:connection];
}

#pragma mark Connections

-(void)connection:(BARConnection *)connection didReceiveRequest:(BARRequest *)request{
	[_connections removeObject:connection];
	dispatch_async(self.dispatchQueue, ^{
		[self processMiddlewareForRequest:request forConnection:connection continueHandler:NULL];
	});
}

-(void)connection:(BARConnection *)connection willSendResponse:(BARResponse *)response forRequest:(BARRequest *)request handler:(void (^)(void))handler{
	dispatch_async(self.dispatchQueue, ^{
		[self processMiddlewareForResponse:response withRequest:request forConnection:connection continueHandler:handler];
	});
}

#pragma mark Middleware

-(void)addGlobalMiddleware:(id<BaristaMiddleware>)middleware{
	if(!_globalMiddleware){
		_globalMiddleware = [NSMutableArray array];
	}
	
	[_globalMiddleware addObject:middleware];
}

-(NSArray *)globalMiddleware{
	return _globalMiddleware;
}

-(void)processMiddlewareForRequest:(BARRequest *)request forConnection:(BARConnection *)connection continueHandler:(void (^)(void))handler{
		@autoreleasepool {
			NSEnumerator *middlewareEnumerator = [request customValueForKey:@"BARServerMiddlewareEnumerator"];
			if(!middlewareEnumerator){
				NSArray *middlewareArray = [self globalMiddleware];
				middlewareEnumerator = [middlewareArray objectEnumerator];
				[request setCustomValue:middlewareEnumerator forKey:@"BARServerMiddlewareEnumerator"];
			}
			
			id<BaristaMiddleware> middleware = [middlewareEnumerator nextObject];
			if(middleware){
				if([middleware respondsToSelector:@selector(didReceiveRequest:forConnection:continueHandler:)]){
					[middleware didReceiveRequest:request forConnection:connection continueHandler:^{
						[self processMiddlewareForRequest:request forConnection:connection continueHandler:handler];
					}];
				}else{
					[self processMiddlewareForRequest:request forConnection:connection continueHandler:handler];
				}
			}else{
				if(handler){
					handler();
				}else if(!connection.didSendResponse && self.unhandledRequestHandler){
					self.unhandledRequestHandler(request, connection);
				}
			}
		}
}

-(void)processMiddlewareForResponse:(BARResponse *)response withRequest:(BARRequest *)request forConnection:(BARConnection *)connection continueHandler:(void (^)(void))handler{
		@autoreleasepool {
			NSEnumerator *middlewareEnumerator = [request customValueForKey:@"BARServerMiddlewareReverseEnumerator"];
			if(!middlewareEnumerator){
				NSArray *middlewareArray = [self globalMiddleware];
				middlewareEnumerator = [middlewareArray reverseObjectEnumerator];
				[request setCustomValue:middlewareEnumerator forKey:@"BARServerMiddlewareReverseEnumerator"];
			}
			
			id<BaristaMiddleware> middleware = [middlewareEnumerator nextObject];
			if(middleware){
				if([middleware respondsToSelector:@selector(willSendResponse:forRequest:forConnection:continueHandler:)]){
					[middleware willSendResponse:response forRequest:request forConnection:connection continueHandler:^{
						[self processMiddlewareForResponse:response withRequest:request forConnection:connection continueHandler:handler];
					}];
				}else{
					[self processMiddlewareForResponse:response withRequest:request forConnection:connection continueHandler:handler];
				}
			}else{
				if(handler){
					handler();
				}
				
				[_connections removeObject:connection];
			}
		}
}

@end
