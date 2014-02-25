//
//  GameOverScene.m
//  Flubble
//
//  Created by Johan Ismael on 11/19/13.
//  Copyright (c) 2013 Johan Ismael. All rights reserved.
//

#import "GameOverScene.h"
#import "MyScene.h"

@implementation GameOverScene

- (id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor blackColor];
        self.anchorPoint = CGPointMake(0.5, 0.5);
        SKLabelNode *goNode = [[SKLabelNode alloc] initWithFontNamed:@"Avenir-Light"];
        goNode.fontColor = [SKColor whiteColor];
        goNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        [self addChild:goNode];
        goNode.text = @"GAME OVER";
        goNode.fontSize = 40;
        
        SKLabelNode *node = [[SKLabelNode alloc] initWithFontNamed:@"Avenir-Light"];
        node.position = CGPointMake(0, -50);
        node.fontColor = [SKColor whiteColor];
        node.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        [self addChild:node];
        node.text = @"Tap to replay";
        node.fontSize = 24;
    }
    return self;
}

- (void)didMoveToView:(SKView *)view
{
    [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)]];
}

- (void)handleTapGesture:(UITapGestureRecognizer *)gesture
{
    SKTransition *transition = [SKTransition revealWithDirection:SKTransitionDirectionDown duration:1.0];
    transition.pausesOutgoingScene = YES;
    MyScene *scene = [[MyScene alloc] initWithSize:self.size];
    [self.scene.view presentScene:scene
                       transition:transition];
}

@end
