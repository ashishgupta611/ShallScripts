//
//  SWEndpointConfiguration.m
//  swig
//
//  Created by Pierre-Marc Airoldi on 2014-08-20.
//  Copyright (c) 2014 PeteAppDesigns. All rights reserved.
//

#import "EndpointConfiguration.h"
#import "TransportConfiguration.h"
#include "pj/file_io.h"

@implementation EndpointConfiguration

-(instancetype)init {
    
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    return self;
}

+(instancetype)configurationWithTransportConfiguration:(TransportConfiguration *)configuration {
    
    if (!configuration) {
        configuration = [TransportConfiguration configurationWithTransportType:TransportTypeUDP];
    }
    
    EndpointConfiguration *endpointConfiguration = [EndpointConfiguration new];
    endpointConfiguration.transportConfiguration = configuration;
    
    return endpointConfiguration;
}


@end
