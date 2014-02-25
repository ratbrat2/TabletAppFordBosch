//
//  FlubbleSpawner.m
//  dummy
//
//  Created by Johan Ismael on 11/21/13.
//  Copyright (c) 2013 Johan Ismael. All rights reserved.
//

#import "FlubbleSpawner.h"
#import "FlubbleColors.h"
#import "IncompleteCircleNode.h"
#import "FlubbleConstants.h"

@implementation FlubbleSpawner

#define PLANET_WIDTH 50
#define PLANET_GLOW_WIDTH 5.0

+ (SKNode *)planetNode
{
    SKShapeNode *node = [[SKShapeNode alloc] init];
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, PLANET_WIDTH, PLANET_WIDTH)];
    node.path = [path CGPath];
    node.fillColor = [FlubbleColors planetColor];
    node.strokeColor = [FlubbleColors planetColor];
    node.glowWidth = PLANET_GLOW_WIDTH;
    
    NSString *particlePath = [[NSBundle mainBundle] pathForResource:@"PlanetEdgeParticle" ofType:@"sks"];
    SKEmitterNode *emitterNode = [NSKeyedUnarchiver unarchiveObjectWithFile:particlePath];
    [node addChild:emitterNode];
    emitterNode.position = CGPointMake(PLANET_WIDTH/2, PLANET_WIDTH/2);
    
    node.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:PLANET_WIDTH/2];
    node.physicsBody.categoryBitMask = planetCategory;
    node.physicsBody.contactTestBitMask = enemyCategory;
    node.physicsBody.collisionBitMask = 0;
    
    return node;
}

#define FLUBBLE_WIDTH 10
#define FLUBBLE_GLOW_WIDTH 1.0

+ (SKNode *)flubbleNode
{
    SKShapeNode *node = [[SKShapeNode alloc] init];
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, FLUBBLE_WIDTH, FLUBBLE_WIDTH)];
    node.path = [path CGPath];
    node.fillColor = [FlubbleColors flubbleColor];
    node.strokeColor = [FlubbleColors flubbleColor];
    node.glowWidth = FLUBBLE_GLOW_WIDTH;
    
    node.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:FLUBBLE_WIDTH/2];
    node.physicsBody.categoryBitMask = flubbleCategory;
    node.physicsBody.contactTestBitMask = enemyCategory;
    node.physicsBody.collisionBitMask = 0;
    
    return node;
}


+ (SKNode *)enemyCircleWithStartingRadius:(CGFloat)radius
{
    IncompleteCircleNode *node = [[IncompleteCircleNode alloc] initWithStartingRadius:radius
                                                                            holeAngle:M_PI/2.0];
    
    node.physicsBody = [SKPhysicsBody bodyWithEdgeChainFromPath:node.path];
    node.physicsBody.categoryBitMask = enemyCategory;
    node.physicsBody.contactTestBitMask = flubbleCategory;
    return node;
}

@end
