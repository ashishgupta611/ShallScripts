//
//  SWCall.h
//  swig
//
//  Created by Pierre-Marc Airoldi on 2014-08-21.
//  Copyright (c) 2014 PeteAppDesigns. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Contact.h"

//TODO: move to 2 sublclasses (incoming/outgoing)

@class Account;

typedef NS_ENUM(NSInteger, CallState) {
    CallStateReady,
    CallStateIncoming,
    CallStateCalling,
    CallStateConnecting,
    CallStateConnected,
    CallStateDisconnected
};

@interface Call : NSObject <NSCopying>

@property (nonatomic, readonly, strong) Contact *contact;
@property (nonatomic, readonly) NSInteger callId;
@property (nonatomic, readonly) NSInteger accountId;
@property (nonatomic, readonly) CallState callState;

-(instancetype)initWithCallId:(NSUInteger)callId accountId:(NSInteger)accountId;
+(instancetype)callWithId:(NSInteger)callId accountId:(NSInteger)accountId;

-(Account *)getAccount;

- (void)answer:(void(^)(NSError *error))handler;
- (void)hangup:(void(^)(NSError *error))handler;
- (void)sendDigits:(NSString *)digits completionHandler:(void(^)(NSError *error))handler;
- (void)setMute:(BOOL)muted completionHandler:(void(^)(NSError *error))handler;

@end
