//
//  FlubbleSpawner.h
//  dummy
//
//  Created by Johan Ismael on 11/21/13.
//  Copyright (c) 2013 Johan Ismael. All rights reserved.
//

#import <Foundation/Foundation.h>
@import SpriteKit;

@interface FlubbleSpawner : NSObject

+ (SKNode *)flubbleNode;
+ (SKNode *)planetNode;
+ (SKNode *)enemyCircleWithStartingRadius:(CGFloat)radius;

@end
