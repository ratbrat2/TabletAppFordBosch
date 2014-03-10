//
//  IncompleteCircleNode.m
//  dummy
//
//  Created by Johan Ismael on 11/22/13.
//  Copyright (c) 2013 Johan Ismael. All rights reserved.
//

#import "IncompleteCircleNode.h"
#import "FlubbleColors.h"

@interface IncompleteCircleNode()

@property (nonatomic, assign) CGAffineTransform rotation;
@property (nonatomic, assign) CGFloat holeAngle;
@property (nonatomic, assign) CGFloat currentRadius;

@end

@implementation IncompleteCircleNode

- (instancetype)initWithStartingRadius:(CGFloat)radius
                             holeAngle:(CGFloat)holeAngle
{
    self = [super init];
    if (self) {
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointZero
                                                            radius:radius
                                                        startAngle:0
                                                          endAngle:2*M_PI - holeAngle
                                                         clockwise:YES];
        self.currentRadius = radius;
        self.holeAngle = holeAngle;
        self.rotation = CGAffineTransformMakeRotation(arc4random());
        [path applyTransform:self.rotation];
        self.path = [path CGPath];
        self.fillColor = [SKColor clearColor];
        self.strokeColor = [self enemyColor];
        self.lineWidth = 1.5;
    }
    return self;
}

- (SKColor *)enemyColor
{
    NSArray *colors = [FlubbleColors enemyColors];
    return colors[(int)arc4random() % [colors count]];
}

#define SHRINK_FACTOR 0.97

- (void)update
{
    self.currentRadius *= SHRINK_FACTOR;
    UIBezierPath *newPath = [UIBezierPath bezierPathWithArcCenter:CGPointZero
                                                           radius:self.currentRadius
                                                       startAngle:0
                                                         endAngle:2.0*M_PI - self.holeAngle
                                                        clockwise:YES];
    [newPath applyTransform:self.rotation];
    self.path = [newPath CGPath];
    
    uint32_t categoryBitMask = self.physicsBody.categoryBitMask;
    uint32_t contactTestBitMask = self.physicsBody.contactTestBitMask;
    self.physicsBody = [SKPhysicsBody bodyWithEdgeChainFromPath:[newPath CGPath]];
    self.physicsBody.categoryBitMask = categoryBitMask;
    self.physicsBody.contactTestBitMask = contactTestBitMask;
}

@end
