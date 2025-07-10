//
//  SWTransportConfigurations.h
//  swig
//
//  Created by Pierre-Marc Airoldi on 2014-08-20.
//  Copyright (c) 2014 PeteAppDesigns. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "pjsip/sip_types.h"

typedef NS_ENUM(NSUInteger, TransportType) {
    TransportTypeUDP = PJSIP_TRANSPORT_UDP,
    TransportTypeTCP = PJSIP_TRANSPORT_TCP,
    TransportTypeUDP6 = PJSIP_TRANSPORT_UDP6,
    TransportTypeTCP6 = PJSIP_TRANSPORT_TCP6,
    TransportTypeTls = PJSIP_TRANSPORT_TLS,
    TransportTypeIPV6 = PJSIP_TRANSPORT_IPV6,
    TransportTypeTLS6 = PJSIP_TRANSPORT_TLS6,
    TransportTypeDTLS = PJSIP_TRANSPORT_DTLS,
    TransportTypeSCTP = PJSIP_TRANSPORT_SCTP,
    TransportTypeLOOP = PJSIP_TRANSPORT_LOOP,
    TransportTypeLoopDgram = PJSIP_TRANSPORT_LOOP_DGRAM,
    TransportTypeDTLS6 = PJSIP_TRANSPORT_DTLS6,
    TransportTypeStartOther = PJSIP_TRANSPORT_START_OTHER
};

@interface TransportConfiguration : NSObject

@property (nonatomic) TransportType transportType;
@property (nonatomic) NSUInteger port; //5060 is default
@property (nonatomic) NSUInteger portRange; //0 is default


+(instancetype)configurationWithTransportType:(TransportType)transportType;

@end
