//
//  SWAccount.h
//  swig
//
//  Created by Pierre-Marc Airoldi on 2014-08-21.
//  Copyright (c) 2014 PeteAppDesigns. All rights reserved.
//

#import <Foundation/Foundation.h>

//TODO: remove account from accounts when disconnected

@class AccountConfiguration, Call, CallParameters, MessageParameters;


@interface Account : NSObject

@property (nonatomic, readonly) NSInteger accountId;
@property (nonatomic, readonly, strong) AccountConfiguration *accountConfiguration;
@property (nonatomic, readonly , assign, getter=isValid) BOOL valid;

-(void)configure:(AccountConfiguration *)configuration completionHandler:(void(^)(NSError *error))handler; //configure and add account

-(void)connect:(void(^)(NSError *error))handler;
-(void)disconnect:(void(^)(NSError *error))handler;

-(void)addCall:(Call *)call;
-(void)removeCall:(NSUInteger)callId;

-(Call *)lookupCall:(NSInteger)callId;
-(Call *)firstCall;

-(void)endAllCalls;
-(void)makeCall:(CallParameters *)callParams completionHandler:(void(^)(NSError *error))handler;
- (void)sendMessage:(MessageParameters *)messageParams completionHandler:(void(^)(NSError *error))handler;

@end
