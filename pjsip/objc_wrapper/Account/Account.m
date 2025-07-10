//
//  SWAccount.m
//  swig
//
//  Created by Pierre-Marc Airoldi on 2014-08-21.
//  Copyright (c) 2014 PeteAppDesigns. All rights reserved.
//

#import "CallParameters.h"
#import "Account.h"
#import "AccountConfiguration.h"
#import "EndpointConfiguration.h"
#import "Endpoint.h"
#import "Call.h"
#import "UriFormatter.h"
#import "Endpoint.h"
#import "pjsua.h"
#import "NSString+PJString.h"
#import "MessageParameters.h"

#define kRegTimeout 800

@interface Account ()

@property (nonatomic, strong) AccountConfiguration *configuration;
@property (nonatomic, strong) NSMutableArray *calls;

@end

@implementation Account

-(instancetype)init {
    
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    _calls = [NSMutableArray new];
    
    return self;
}

-(void)dealloc {
    
}

-(void)setAccountId:(NSInteger)accountId {
    
    _accountId = accountId;
}


-(void)setAccountConfiguration:(AccountConfiguration *)accountConfiguration {
    
    [self willChangeValueForKey:@"accountConfiguration"];
    _accountConfiguration = accountConfiguration;
    [self didChangeValueForKey:@"accountConfiguration"];
}

-(void)configure:(AccountConfiguration *)configuration completionHandler:(void(^)(NSError *error))handler {
    
    Endpoint *endpoint = [Endpoint sharedEndpoint];
    
    self.accountConfiguration = configuration;
    
    if (!self.accountConfiguration.address) {
        self.accountConfiguration.address = [AccountConfiguration addressFromUsername:self.accountConfiguration.username domain:self.accountConfiguration.domain];
    }
    
    NSString *tcpSuffix = @"";
    
    pjsua_acc_config acc_cfg;
    pjsua_acc_config_default(&acc_cfg);

    NSString *uri = [self.accountConfiguration.address stringByAppendingString:tcpSuffix];
    NSString *sipUri = [UriFormatter sipUri:uri withDisplayName:self.accountConfiguration.displayName];
    acc_cfg.id = [self pjStringWithString:sipUri];
    
    NSString *regUri = [UriFormatter sipUri:[self.accountConfiguration.domain stringByAppendingString:tcpSuffix]];
    acc_cfg.reg_uri = [self pjStringWithString:regUri];
    acc_cfg.register_on_acc_add = self.accountConfiguration.registerOnAdd ? PJ_TRUE : PJ_FALSE;;
    acc_cfg.publish_enabled = self.accountConfiguration.publishEnabled ? PJ_TRUE : PJ_FALSE;
    acc_cfg.reg_timeout = kRegTimeout;
    
    acc_cfg.cred_count = 1;
    acc_cfg.cred_info[0].scheme = [self pjStringWithString:self.accountConfiguration.authScheme];
    acc_cfg.cred_info[0].realm = [self pjStringWithString:self.accountConfiguration.authRealm];
    acc_cfg.cred_info[0].username = [self pjStringWithString:self.accountConfiguration.username];
    acc_cfg.cred_info[0].data_type = PJSIP_CRED_DATA_PLAIN_PASSWD;
    acc_cfg.cred_info[0].data = [self pjStringWithString:self.accountConfiguration.password];
    acc_cfg.proxy_cnt = (unsigned) self.accountConfiguration.proxy.count;
    
    for (NSUInteger index = 0; index < self.accountConfiguration.proxy.count; index ++) {
        acc_cfg.proxy[(unsigned)index] = [self pjStringWithString:[self.accountConfiguration.proxy objectAtIndex:index]];
    }
    
    pj_status_t status;
    
    acc_cfg.rtp_cfg = endpoint.endpointConfiguration.rtp_cfg;
    
    status = pjsua_acc_add(&acc_cfg, PJ_TRUE, (int*)&_accountId);
    
    
    if (status != PJ_SUCCESS) {
        
        NSError *error = [NSError errorWithDomain:@"Error adding account" code:status userInfo:nil];
        
        if (handler) {
            handler(error);
        }
        
        return;
    }
    
    else {
        [Endpoint sharedEndpoint].account = self;
    }
    
    if (!self.accountConfiguration.registerOnAdd) {
        [self connect:handler];
    }
    else {
        
        if (handler) {
            handler(nil);
        }
    }
}

-(void)connect:(void(^)(NSError *error))handler {
    
    //FIX: registering too often will cause the server to possibly return error
        
    pj_status_t status;
    
    status = pjsua_acc_set_registration((int)self.accountId, PJ_TRUE);
    
    if (status != PJ_SUCCESS) {
        
        NSError *error = [NSError errorWithDomain:@"Error setting registration" code:status userInfo:nil];
        
        if (handler) {
            handler(error);
        }
        
        return;
    }
    
    status = pjsua_acc_set_online_status((int)self.accountId, PJ_TRUE);
    
    if (status != PJ_SUCCESS) {
        
        NSError *error = [NSError errorWithDomain:@"Error setting online status" code:status userInfo:nil];
        
        if (handler) {
            handler(error);
        }
        
        return;
    }
    
    if (handler) {
        handler(nil);
    }
}

-(void)disconnect:(void(^)(NSError *error))handler {
    
    pj_status_t status;
    
    status = pjsua_acc_set_online_status((int)self.accountId, PJ_FALSE);
    
    if (status != PJ_SUCCESS) {
        
        NSError *error = [NSError errorWithDomain:@"Error setting online status" code:status userInfo:nil];
        
        if (handler) {
            handler(error);
        }
        
        return;
    }
    
    status = pjsua_acc_set_registration((int)self.accountId, PJ_FALSE);
    
    if (status != PJ_SUCCESS) {
        
        NSError *error = [NSError errorWithDomain:@"Error setting registration" code:status userInfo:nil];
        
        if (handler) {
            handler(error);
        }
        
        return;
    }
    
    if (handler) {
        handler(nil);
    }
}

-(BOOL)isValid {
    
    return pjsua_acc_is_valid((int)self.accountId);
}

#pragma Call Management

-(void)addCall:(Call *)call {
    
    [self.calls addObject:call];
    
    //TODO:: setup blocks
}

-(void)removeCall:(NSUInteger)callId {
    
    Call *call = [self lookupCall:callId];
    
    if (call) {
        [self.calls removeObject:call];
    }
    
    call = nil;
}

-(Call *)lookupCall:(NSInteger)callId {
    
    NSUInteger callIndex = [self.calls indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        
        Call *call = (Call *)obj;
        
        if (call.callId == callId && call.callId != PJSUA_INVALID_ID) {
            return YES;
        }
        
        return NO;
    }];
    
    if (callIndex != NSNotFound) {
        return [self.calls objectAtIndex:callIndex]; //TODO add more management
    }
    
    else {
        return nil;
    }
}

-(Call *)firstCall {
    
    if (self.calls.count > 0) {
        return self.calls[0];
    }
    
    else {
        return nil;
    }
}

-(void)endAllCalls {
    
    for (Call *call in self.calls) {
        [call hangup:nil];
    }
}

-(void)makeCall:(CallParameters *)callParams completionHandler:(void(^)(NSError *error))handler {
    
    pj_status_t status;
    NSError *error;
    
    pjsua_call_id callIdentifier;
    NSString *callUri = [UriFormatter sipUri:callParams.URI fromAccount:self];
    pj_str_t uri = [self pjStringWithString:callUri];
    
    pjsua_call_setting call_opt;
    pjsua_call_setting_default(&call_opt);
    call_opt.vid_cnt = (int)0;
    
    // Create a temporary pool to allocate default headers from
    pj_caching_pool cp;
    pj_caching_pool_init(&cp, &pj_pool_factory_default_policy, 0);
    pj_pool_t *pool = pj_pool_create(&cp.factory, "header", 1000, 1000, NULL);
    
    // Append any required default headers
    pjsua_msg_data msg_data;
    pjsua_msg_data_init(&msg_data);
    
    // Append any call-specific headers
    if (callParams.headers != nil) {
        [callParams.headers enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull key, NSString *_Nonnull obj, BOOL *_Nonnull stop) {
            pj_str_t name = key.pjString;
            pj_str_t value = obj.pjString;
            pj_list_push_back((pjsip_hdr *) &msg_data.hdr_list, pjsip_generic_string_hdr_create(pool, &name, &value));
        }];
    }
    
    status = pjsua_call_make_call((int)_accountId, &uri, &call_opt, NULL, &msg_data, &callIdentifier);
    
    if (status != PJ_SUCCESS) {
        error = [NSError errorWithDomain:@"Error hanging up call" code:0 userInfo:nil];
    }
    else {
        Call *call = [Call callWithId:callIdentifier accountId:self.accountId];
        [self addCall:call];
    }
    
    // Discard the pool to cleanup
    pj_pool_release(pool);
    
    if (handler) {
        handler(error);
    }
}

- (void)sendMessage:(MessageParameters *)messageParams completionHandler:(void(^)(NSError *error))handler {

    pj_status_t status;
    NSError *error = nil;
    
    pj_str_t remoteUri = [self pjStringWithString:messageParams.toURI];
    pj_str_t textMessage = [self pjStringWithString:messageParams.message];
    
    status = pjsua_im_send((int)_accountId, &remoteUri, NULL, &textMessage, NULL, NULL);
    
    if (status != PJ_SUCCESS) {
        error = [NSError errorWithDomain:@"Error in sending message" code:0 userInfo:nil];
    }
    
    if (handler) {
        handler(error);
    }
}

#pragma mark- Private

-(pj_str_t)pjStringWithString:(NSString *)string {
    return pj_str((char *)[string cStringUsingEncoding:NSUTF8StringEncoding]);
}

@end
