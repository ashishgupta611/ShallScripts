//
//  MessageParameters.h
//  ipjsua
//
//  Created by ashish2199 on 01/11/17.
//  Copyright © 2017 Teluu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageParameters : NSObject

@property (nonatomic) NSString *toURI;
@property (nonatomic) NSString *fromURI;
@property (nonatomic) NSString *message;

@end
