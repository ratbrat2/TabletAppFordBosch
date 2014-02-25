//
//  IncompleteCircleNode.h
//  dummy
//
//  Created by Johan Ismael on 11/22/13.
//  Copyright (c) 2013 Johan Ismael. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface IncompleteCircleNode : SKShapeNode

- (instancetype)initWithStartingRadius:(CGFloat)radius
                             holeAngle:(CGFloat)holeAngle;

- (void)update;

@end
