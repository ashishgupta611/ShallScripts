//
//  SWTransportConfigurations.m
//  swig
//
//  Created by Pierre-Marc Airoldi on 2014-08-20.
//  Copyright (c) 2014 PeteAppDesigns. All rights reserved.
//

#import "TransportConfiguration.h"

#define kSWPort 5060
#define kSWPortRange 0

@implementation TransportConfiguration

-(instancetype)init {
    
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    _port = kSWPort;
    _portRange = kSWPortRange;
    
    return self;
}

+(instancetype)configurationWithTransportType:(TransportType)transportType {
    
    TransportConfiguration *configuration = [TransportConfiguration new];
    configuration.transportType = transportType;

    return configuration;
}

@end
