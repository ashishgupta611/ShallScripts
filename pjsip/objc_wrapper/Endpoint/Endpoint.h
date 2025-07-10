//
//  SWEndpoint.h
//  swig
//
//  Created by Pierre-Marc Airoldi on 2014-08-20.
//  Copyright (c) 2014 PeteAppDesigns. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransportConfiguration.h"

@class EndpointConfiguration, Account, Call, MessageParameters, AccountConfiguration;

@interface Endpoint : NSObject

@property (nonatomic, strong, readonly) EndpointConfiguration *endpointConfiguration;
@property (nonatomic, strong) Account *account;

+(instancetype)sharedEndpoint;

- (void)configure:(EndpointConfiguration *)configuration completionHandler:(void(^)(NSError *error))handler;
-(void)start:(void(^)(NSError *error))handler;
-(void)reset:(void(^)(NSError *error))handler; //reset endpoint

- (void)configureEndpoint:(TransportType)transportType withPort:(int)port;
- (void)configureEndpointForTLS:(int)port;
- (void)addSIPAccount:(AccountConfiguration *)configuration completionHandler:(void(^)(NSError *response))handler;
-(void)setAccountStateChangeBlock:(void(^)(Account *account))accountStateChangeBlock;
-(void)setRegistrationStateChangeBlock:(void(^)(Account *account, NSString *status, BOOL isRegistration))registrationStateChangeBlock;
-(void)setIncomingCallBlock:(void(^)(Account *account, Call *call))incomingCallBlock;
-(void)setMessageReceiveBlock:(void(^)(Account *account, MessageParameters *message))messageReceiveBlock;
-(void)setMessageStateBlock:(void(^)(Account *account, NSString *status))messageStateBlock;
-(void)setCallStateChangeBlock:(void(^)(Account *account, Call *call))callStateChangeBlock;
-(void)setCallMediaStateChangeBlock:(void(^)(Account *account, Call *call))callMediaStateChangeBlock;

@end

