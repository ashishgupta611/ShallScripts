//
//  CallParameters.h
//  ipjsua
//
//  Created by MacBook  on 9/11/17.
//  Copyright © 2017 CesTR. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface CallParameters : NSObject

@property (nonatomic) NSString *URI;
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *headers;

@end
