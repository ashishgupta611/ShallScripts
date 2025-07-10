//
//  SWCall.m
//  swig
//
//  Created by Pierre-Marc Airoldi on 2014-08-21.
//  Copyright (c) 2014 PeteAppDesigns. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Call.h"
#import "Account.h"
#import "Endpoint.h"
#import "UriFormatter.h"
#import "pjsua.h"
#import "NSString+PJString.h"
#import <AVFoundation/AVFoundation.h>

@interface Call ()


@end


@implementation Call

-(instancetype)init {
    
    NSAssert(NO, @"never call init directly use init with call id");
    
    return nil;
}

-(instancetype)initWithCallId:(NSUInteger)callId accountId:(NSInteger)accountId {
    
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    _callState = CallStateReady;
    _callId = callId;
    _accountId = accountId;
    
    [self contactChanged];
    
    return self;
}

-(instancetype)copyWithZone:(NSZone *)zone {
    
    Call *call = [[Call allocWithZone:zone] init];
    call.contact = [self.contact copyWithZone:zone];
    call.callId = self.callId;
    call.accountId = self.accountId;
    call.callState = self.callState;
    
    return call;
}

+(instancetype)callWithId:(NSInteger)callId accountId:(NSInteger)accountId {
    
    Call *call = [[Call alloc] initWithCallId:callId accountId:accountId];
    
    return call;
}


-(void)dealloc {
    
    if (_callState != CallStateDisconnected && _callId != PJSUA_INVALID_ID) {
        pjsua_call_hangup((int)_callId, 0, NULL, NULL);
    }
}

-(void)setCallId:(NSInteger)callId {
    
    [self willChangeValueForKey:@"callId"];
    _callId = callId;
    [self didChangeValueForKey:@"callId"];
}

-(void)setAccountId:(NSInteger)accountId {
    
    [self willChangeValueForKey:@"callId"];
    _accountId = accountId;
    [self didChangeValueForKey:@"callId"];
}

-(void)setCallState:(CallState)callState {
    
    [self willChangeValueForKey:@"callState"];
    _callState = callState;
    [self didChangeValueForKey:@"callState"];
}

-(void)setContact:(Contact *)contact {
    
    [self willChangeValueForKey:@"contact"];
    _contact = contact;
    [self didChangeValueForKey:@"contact"];
}


-(void)callStateChanged {
    
    pjsua_call_info callInfo;
    pjsua_call_get_info((int)self.callId, &callInfo);
    
    switch (callInfo.state) {
        case PJSIP_INV_STATE_NULL: {
            self.callState = CallStateReady;
        } break;
            
        case PJSIP_INV_STATE_INCOMING: {
            self.callState = CallStateIncoming;
        } break;
            
        case PJSIP_INV_STATE_CALLING: {
            self.callState = CallStateCalling;
        } break;
            
        case PJSIP_INV_STATE_EARLY: {
            if (self.callState != CallStateCalling)
                self.callState = CallStateCalling;
        } break;
            
        case PJSIP_INV_STATE_CONNECTING: {
            
            if (self.callState != CallStateConnecting)
                self.callState = CallStateConnecting;
            
        } break;
            
        case PJSIP_INV_STATE_CONFIRMED: {
            self.callState = CallStateConnected;
            
        } break;
            
        case PJSIP_INV_STATE_DISCONNECTED: {
            self.callState = CallStateDisconnected;
        } break;
    }
    [self contactChanged];
}

-(Account *)getAccount {
    
    pjsua_call_info info;
    pjsua_call_get_info((int)self.callId, &info);
    
    return [Endpoint sharedEndpoint].account;
}

-(void)contactChanged {
    
    pjsua_call_info info;
    pjsua_call_get_info((int)self.callId, &info);
    
    pj_str_t pjString = info.remote_info;
    NSString *remoteURI = [[NSString alloc] initWithBytes:pjString.ptr length:(NSUInteger)pjString.slen encoding:NSUTF8StringEncoding];
    
    //NSString *remoteURI = [NSString stringWithPJString:info.remote_info];
    
    self.contact = [UriFormatter contactFromURI:remoteURI];
}

#pragma Call Management

-(void)answer:(void(^)(NSError *error))handler {
    
    pj_status_t status;
    NSError *error;
    
    status = pjsua_call_answer((int)self.callId, PJSIP_SC_OK, NULL, NULL);
    
    if (status != PJ_SUCCESS) {
        error = [NSError errorWithDomain:@"Error answering up call" code:0 userInfo:nil];
    }
    
    if (handler) {
        handler(error);
    }
}

- (void)hangup:(void(^)(NSError *error))handler {
    
    pj_status_t status;
    NSError *error;
    
    if (self.callId != PJSUA_INVALID_ID && self.callState != CallStateDisconnected) {
        status = pjsua_call_hangup((int)self.callId, 0, NULL, NULL);
        
        if (status != PJ_SUCCESS) {
            error = [NSError errorWithDomain:@"Error hanging up call" code:0 userInfo:nil];
        }
    }
    
    if (handler) {
        handler(error);
    }
}

- (void)sendDigits:(NSString *)digits completionHandler:(void(^)(NSError *error))handler {
    pj_status_t status;
    NSError *error;
    pj_str_t pj_digits = [digits pjString];
    
    status = pjsua_call_dial_dtmf((int)self.callId, &pj_digits);
    
    if (status != PJ_SUCCESS) {
        error = [NSError errorWithDomain:@"Error sending DTMF" code:0 userInfo:nil];
    }
    
    if (handler) {
        handler(error);
    }
}

- (void)setSpeaker:(BOOL)speaker completionHandler:(void(^)(NSError *error))handler {
    
    if (speaker) {
        [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    }
    
    else {
        [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
    }
}

- (void)setMute:(BOOL)muted completionHandler:(void(^)(NSError *error))handler {
    pjsua_call_info callInfo;
    pjsua_call_get_info((int)self.callId, &callInfo);
    
    if (muted) {
        pjsua_conf_disconnect(0, callInfo.conf_slot);
    }
    else {
        pjsua_conf_connect(0, callInfo.conf_slot);
    }
}

@end
