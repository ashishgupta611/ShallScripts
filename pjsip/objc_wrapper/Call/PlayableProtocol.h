//
//  PlayableProtocol.h
//  
//
//  Created by Pierre-Marc Airoldi on 2014-09-04.
//
//

#import <Foundation/Foundation.h>

@protocol PlayableProtocol <NSObject>

-(void)start;
-(void)configureAudioSession;
-(void)stop;

@end
