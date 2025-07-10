
//
//  Contact.m
//  
//
//  Created by Pierre-Marc Airoldi on 2014-09-08.
//
//

#import "Contact.h"

@implementation Contact

-(instancetype)init {
    
    return [self initWithName:nil address:nil];
}

-(instancetype)initWithName:(NSString *)name address:(NSString *)address {
    
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    if (!name) {
        _name = @"";
    }
    
    else {
        _name = name;
    }
    
    if (!address) {
        _address = @"";
    }
    
    else {
        _address = address;
    }
    
    return self;
}

-(instancetype)copyWithZone:(NSZone *)zone {
    
    Contact *contact = [[Contact allocWithZone:zone] init];
    contact.name = [self.name copyWithZone:zone];
    contact.address = [self.address copyWithZone:zone];
    
    return contact;
}

-(void)setName:(NSString *)name {
    
    [self willChangeValueForKey:@"name"];
    _name = name;
    [self didChangeValueForKey:@"name"];
}

-(void)setAddress:(NSString *)address {
    
    [self willChangeValueForKey:@"address"];
    _address = address;
    [self didChangeValueForKey:@"address"];
}


@end
