//
//  SWEndpointConfiguration.h
//  swig
//
//  Created by Pierre-Marc Airoldi on 2014-08-20.
//  Copyright (c) 2014 PeteAppDesigns. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <pjsua.h>

@class TransportConfiguration;
@interface EndpointConfiguration : NSObject

//transport configurations
@property (nonatomic) Boolean no_udp;
@property (nonatomic) Boolean no_tcp;
@property (nonatomic, strong) TransportConfiguration *transportConfiguration;

@property (nonatomic) pjsua_transport_config rtp_cfg;

+(instancetype)configurationWithTransportConfiguration:(TransportConfiguration *)transportConfiguration;

@end
