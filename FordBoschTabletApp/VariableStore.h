//
//  VariableStore.h
//  FordBoschTabletApp
//
//  Created by Ted Kim on 4/27/14.
//  Copyright (c) 2014 Johan Ismael. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VariableStore : NSObject


+ (id)sharedManager;
+ (void)writeToLog:(NSString *)message;
+ (void)writeToLog:(NSString *)message withParticipantId:(NSString *)participantId;
+ (void)setParticipantId:(NSString *)participantId;

@end
