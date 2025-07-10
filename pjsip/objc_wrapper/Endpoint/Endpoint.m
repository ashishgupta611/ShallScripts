//
//  SWEndpoint.m
//  swig
//
//  Created by Pierre-Marc Airoldi on 2014-08-20.
//  Copyright (c) 2014 PeteAppDesigns. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Endpoint.h"
#import "TransportConfiguration.h"
#import "EndpointConfiguration.h"
#import "Account.h"
#import "Call.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "MessageParameters.h"
#import <pjsua.h>

typedef void (^AccountStateChangeBlock)(Account *account);
typedef void (^RegistrationStateChangeBlock)(Account *account, NSString *status, BOOL isRegistration);
typedef void (^IncomingCallBlock)(Account *account, Call *call);
typedef void (^MessageReceiveBlock)(Account *account, MessageParameters *message);
typedef void (^MessageStateBlock)(Account *account, NSString *status);
typedef void (^CallStateChangeBlock)(Account *account, Call *call);
typedef void (^CallMediaStateChangeBlock)(Account *account, Call *call);

static pjsua_config cfg;
static pjsua_logging_config log_cfg;
static pjsua_media_config media_cfg;


//callback functions
static void OnIncomingCall(pjsua_acc_id acc_id, pjsua_call_id call_id, pjsip_rx_data *rdata);
static void OnCallMediaState(pjsua_call_id call_id);
static void OnCallState(pjsua_call_id call_id, pjsip_event *e);
static void OnRegState(pjsua_acc_id acc_id);
static void OnRegistrationStateChangeBlock(pjsua_acc_id acc_id, pjsua_reg_info *info);
static void OnMessageReceive(pjsua_call_id call_id, const pj_str_t *from, const pj_str_t *to, const pj_str_t *contact, const pj_str_t *mime_type, const pj_str_t *body);
static void OnMessageState (pjsua_call_id call_id, const pj_str_t *to, const pj_str_t *body, void *user_data, pjsip_status_code status, const pj_str_t *reason);


@interface Endpoint ()

@property (nonatomic, copy) IncomingCallBlock incomingCallBlock;
@property (nonatomic, copy) MessageReceiveBlock messageReceiveBlock;
@property (nonatomic, copy) MessageStateBlock messageStateBlock;
@property (nonatomic, copy) AccountStateChangeBlock accountStateChangeBlock;
@property (nonatomic, copy) RegistrationStateChangeBlock registrationStateChangeBlock;
@property (nonatomic, copy) CallStateChangeBlock callStateChangeBlock;
@property (nonatomic, copy) CallMediaStateChangeBlock callMediaStateChangeBlock;

@end

@implementation Endpoint

static Endpoint *_sharedEndpoint = nil;

+(id)sharedEndpoint {
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedEndpoint = [self new];
    });
    
    return _sharedEndpoint;
}

#pragma Endpoint Methods

- (void)addSIPAccount:(AccountConfiguration *)configuration completionHandler:(void(^)(NSError *error))handler {
    
    Account *account = [Account new];
    [account configure:configuration completionHandler:^(NSError *error) {
        
        if (error) {
            NSLog(@"addSIPAccountP Error...  %@", [error description]);
        }
        
        if (handler) {
            handler(error);
        }
    }];
}

- (void)setEndpointConfiguration:(EndpointConfiguration *)endpointConfiguration {
    
    [self willChangeValueForKey:@"endpointConfiguration"];
    _endpointConfiguration = endpointConfiguration;
    [self didChangeValueForKey:@"endpointConfiguration"];
}

- (void)configureEndpoint:(TransportType)transportType withPort:(int)port {
    TransportConfiguration *transportConfiguration = [TransportConfiguration configurationWithTransportType:transportType];
    transportConfiguration.port = port;
    [self configureEndpointTransportConfiguration: transportConfiguration];
}

- (void)configureEndpointTransportConfiguration:(TransportConfiguration *)transportConfig {
    
    EndpointConfiguration *endpointConfig = [EndpointConfiguration configurationWithTransportConfiguration:transportConfig];
    
    endpointConfig.no_udp=NO;
    endpointConfig.no_tcp=YES;
    
    Endpoint *endpoint = [Endpoint sharedEndpoint];
    
    //Initialize pjsip configuration
    [endpoint configure:endpointConfig completionHandler:^(NSError *error) {
        
        if (error) {
            NSLog(@"%@", [error description]);
            
            [endpoint reset:^(NSError *error) {
                if(error) NSLog(@"%@", [error description]);
            }];
        }
    }];
}

- (void)configureEndpointForTLS:(int)port {
    [self configureEndpoint:TransportTypeTls withPort:port];
}

- (void)configure:(EndpointConfiguration *)configuration completionHandler:(void(^)(NSError *error))handler {
    
    _endpointConfiguration = configuration;
    pj_status_t status;

    status = pjsua_create();
    
    if (status != PJ_SUCCESS) {
        NSError *error = [NSError errorWithDomain:@"Error creating pjsua" code:status userInfo:nil];
        
        if (handler) {
            handler(error);
        }
        return;
    }
    
    /* Create pool for application */
    [self loadDefaultConfigs];
    status = pjsua_init(&cfg, &log_cfg, &media_cfg);
    
    if (status != PJ_SUCCESS) {
        NSError *error = [NSError errorWithDomain:@"Error initializing pjsua" code:status userInfo:nil];
        
        if (handler) {
            handler(error);
        }

        return;
    }
    
    //TODO autodetect port by checking transportId!!!!
    
    if (self.endpointConfiguration.transportConfiguration) {
        
        pjsua_transport_config transportConfig;
        pjsua_transport_id transportId;
        
        pjsua_transport_config_default(&transportConfig);
        
        pjsip_transport_type_e transportType = (pjsip_transport_type_e)self.endpointConfiguration.transportConfiguration.transportType;
        
        status = pjsua_transport_create(transportType, &transportConfig, &transportId);
        
        if (status != PJ_SUCCESS) {
            
            NSError *error = [NSError errorWithDomain:@"Error creating pjsua transport" code:status userInfo:nil];
            
            if (handler) {
                handler(error);
            }
            return;
        }
    }
    
    [self start:handler];
}


-(void)loadDefaultConfigs {
    
    pjsua_config_default(&cfg);
    
    pjsua_logging_config_default(&log_cfg);
    log_cfg.console_level = 4;
    pjsua_media_config_default(&media_cfg);
    
    pjsua_transport_config rtp_cfg;
    pjsua_transport_config_default(&rtp_cfg);
    rtp_cfg.port = (unsigned)_endpointConfiguration.transportConfiguration.port;
    
    _endpointConfiguration.rtp_cfg= rtp_cfg;
    media_cfg.quality = 5;
    
    cfg.cb.on_incoming_call = &OnIncomingCall;
    cfg.cb.on_call_media_state = &OnCallMediaState;
    cfg.cb.on_call_state = &OnCallState;
    cfg.cb.on_pager = &OnMessageReceive;
    cfg.cb.on_reg_state = &OnRegState;
    cfg.cb.on_reg_state2 = &OnRegistrationStateChangeBlock;
    cfg.cb.on_pager_status = &OnMessageState;
}

-(void)start:(void(^)(NSError *error))handler {
    
    pj_status_t status = pjsua_start();
    
    if (status != PJ_SUCCESS) {
        
        NSError *error = [NSError errorWithDomain:@"Error starting pjsua" code:status userInfo:nil];
        
        if (handler) {
            handler(error);
        }
        
        return;
    }
    
    if (handler) {
        handler(nil);
    }
}

-(void)reset:(void(^)(NSError *error))handler {
    
    //TODO shutdown agent correctly. stop all calls, destroy all accounts
    
    if (self.account != nil) {
        [self.account endAllCalls];
        
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        
        [self.account disconnect:^(NSError *error) {
            dispatch_semaphore_signal(sema);
        }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
}


#pragma Block Parameters

-(void)setAccountStateChangeBlock:(void(^)(Account *account))accountStateChangeBlock {
    
    _accountStateChangeBlock = accountStateChangeBlock;
}

-(void)setRegistrationStateChangeBlock:(void(^)(Account *account, NSString *status, BOOL isRegistration))registrationStateChangeBlock {
    
    _registrationStateChangeBlock = registrationStateChangeBlock;
}

-(void)setIncomingCallBlock:(void(^)(Account *account, Call *call))incomingCallBlock {
    
    _incomingCallBlock = incomingCallBlock;
}

-(void)setMessageReceiveBlock:(void(^)(Account *account, MessageParameters *message))messageReceiveBlock {
    
    _messageReceiveBlock = messageReceiveBlock;
}

-(void)setMessageStateBlock:(void(^)(Account *account, NSString *status))messageStateBlock {

    _messageStateBlock = messageStateBlock;
}

-(void)setCallStateChangeBlock:(void(^)(Account *account, Call *call))callStateChangeBlock {
    
    _callStateChangeBlock = callStateChangeBlock;
}

-(void)setCallMediaStateChangeBlock:(void(^)(Account *account, Call *call))callMediaStateChangeBlock {
    
    _callMediaStateChangeBlock = callMediaStateChangeBlock;
}

#pragma PJSUA Callbacks

static void OnRegState(pjsua_acc_id acc_id) {
    
    Account *account = [Endpoint sharedEndpoint].account;
    
    if (account) {
    
        if ([Endpoint sharedEndpoint].accountStateChangeBlock) {
            [Endpoint sharedEndpoint].accountStateChangeBlock(account);
        }
    }
}

static void OnRegistrationStateChangeBlock(pjsua_acc_id acc_id, pjsua_reg_info *info) {

    pj_str_t reason = info->cbparam->reason;
    NSString *string = [[NSString alloc] initWithBytes:reason.ptr length:(NSUInteger)reason.slen encoding:NSUTF8StringEncoding];
    
    //NSString *string = @"";
    //BOOL isRegistration = YES;
    BOOL isRegistration = info->cbparam->is_unreg ? NO : YES;
    
    Account *account = [Endpoint sharedEndpoint].account;
    
    if (account) {
        
        if ([Endpoint sharedEndpoint].registrationStateChangeBlock) {
            [Endpoint sharedEndpoint].registrationStateChangeBlock(account, string, isRegistration);
        }
    }
}

static void OnMessageReceive(pjsua_call_id call_id, const pj_str_t *from, const pj_str_t *to, const pj_str_t *contact, const pj_str_t *mime_type, const pj_str_t *body) {
    
    Account *account = [Endpoint sharedEndpoint].account;
    
    if (account) {
        MessageParameters *messageParam = [[MessageParameters alloc] init];
        
        messageParam.toURI = [[NSString alloc] initWithBytes:to->ptr length:(NSUInteger)to->slen encoding:NSUTF8StringEncoding];
        
        messageParam.fromURI = [[NSString alloc] initWithBytes:from->ptr length:(NSUInteger)from->slen encoding:NSUTF8StringEncoding];
        
        messageParam.message = [[NSString alloc] initWithBytes:body->ptr length:(NSUInteger)body->slen encoding:NSUTF8StringEncoding];
        
        if ([Endpoint sharedEndpoint].messageReceiveBlock) {
            [Endpoint sharedEndpoint].messageReceiveBlock(account, messageParam);
        }
    }
}

static void OnMessageState (pjsua_call_id call_id, const pj_str_t *to, const pj_str_t *body, void *user_data, pjsip_status_code status, const pj_str_t *reason) {
    
    NSString *string = [[NSString alloc] initWithBytes:reason->ptr length:(NSUInteger)reason->slen encoding:NSUTF8StringEncoding];
    Account *account = [Endpoint sharedEndpoint].account;
    
    if (account) {
        
        if ([Endpoint sharedEndpoint].messageStateBlock) {
            [Endpoint sharedEndpoint].messageStateBlock(account, string);
        }
    }
}

static void OnIncomingCall(pjsua_acc_id acc_id, pjsua_call_id call_id, pjsip_rx_data *rdata) {
    
    Account *account = [Endpoint sharedEndpoint].account;
    
    if (account) {
        Call *call = [Call callWithId:call_id accountId:acc_id];
        
        if (call) {
            [account addCall:call];
            
            [call performSelector:@selector(callStateChanged)];
            
            if ([Endpoint sharedEndpoint].incomingCallBlock) {
                [Endpoint sharedEndpoint].incomingCallBlock(account, call);
            }
        }
    }
}

static void OnCallState(pjsua_call_id call_id, pjsip_event *e) {
    
    pjsua_call_info callInfo;
    pjsua_call_get_info(call_id, &callInfo);
    
    Account *account = [Endpoint sharedEndpoint].account;
    
    if (account) {
        Call *call = [account lookupCall:call_id];
        
        if (call) {
            [call performSelector:@selector(callStateChanged)];
            
            if ([Endpoint sharedEndpoint].callStateChangeBlock) {
                [Endpoint sharedEndpoint].callStateChangeBlock(account, call);
            }
            
            if (call.callState == CallStateDisconnected) {
                [account removeCall:call.callId];
            }
        }
    }
}


/* Callback called by the library when call's media state has changed */
static void OnCallMediaState(pjsua_call_id call_id)
{
    pjsua_call_info ci;
    
    pjsua_call_get_info(call_id, &ci);
    
    if (ci.media_status == PJSUA_CALL_MEDIA_ACTIVE) {
        // When media is active, connect call to sound device.
        pjsua_conf_connect(ci.conf_slot, 0);
        pjsua_conf_connect(0, ci.conf_slot);
    }
}


@end
