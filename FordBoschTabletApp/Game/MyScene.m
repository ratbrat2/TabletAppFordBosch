//
//  MyScene.m
//  dummy
//
//  Created by Johan Ismael on 11/21/13.
//  Copyright (c) 2013 Johan Ismael. All rights reserved.
//

#import "MyScene.h"
#import "FlubbleSpawner.h"
#import "FlubbleConstants.h"
#import "GameOverScene.h"
@import AVFoundation;

@interface MyScene()<SKPhysicsContactDelegate>

@property (nonatomic, strong) SKNode *planetNode;
@property (nonatomic, strong) SKNode *flubbleNode;
@property (nonatomic, assign) CGFloat flubbleAngle;
@property (nonatomic, assign) CGFloat flubbleOrbitRadius;
@property (nonatomic, assign) CGPoint flubbleSpeed;
@property (nonatomic, strong) NSMutableArray *enemies;
@property (nonatomic, assign) NSUInteger score;
@property (nonatomic, strong) SKLabelNode *scoreNode;
@property (nonatomic, assign) CFTimeInterval initialTime;
@property (nonatomic, assign) NSUInteger livesCount;
@property (nonatomic, strong) SKLabelNode *livesCountNode;
@property (nonatomic, strong) AVPlayer *bgVideoPlayer;

@end

@implementation MyScene

#define SCORE_LABEL_OFFSET_X 10
#define SCORE_LABEL_OFFSET_Y 10
#define LIVES_LABEL_OFFSET_Y 40

- (SKLabelNode *)scoreNode
{
    if (!_scoreNode) {
        _scoreNode = [[SKLabelNode alloc] initWithFontNamed:@"Avenir-Light"];
        _scoreNode.position = CGPointMake(-self.size.width/2 + SCORE_LABEL_OFFSET_X,-self.size.height/2 + SCORE_LABEL_OFFSET_Y);
        _scoreNode.fontColor = [SKColor whiteColor];
        _scoreNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        _scoreNode.fontSize = 24;
        [self addChild:_scoreNode];
    }
    return _scoreNode;
}

- (SKLabelNode *)livesCountNode
{
    if (!_livesCountNode) {
        _livesCountNode = [[SKLabelNode alloc] initWithFontNamed:@"Avenir-Light"];
        _livesCountNode.position = CGPointMake(-self.size.width/2 + SCORE_LABEL_OFFSET_X,-self.size.height/2 + LIVES_LABEL_OFFSET_Y);
        _livesCountNode.fontColor = [SKColor whiteColor];
        _livesCountNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        _livesCountNode.fontSize = 24;
        [self addChild:_livesCountNode];
    }
    return _livesCountNode;
}

- (void)didChangeSize:(CGSize)oldSize
{
    _scoreNode.position = CGPointMake(-self.size.width/2 + SCORE_LABEL_OFFSET_X,-self.size.height/2 + SCORE_LABEL_OFFSET_Y);
}

- (void)setScore:(NSUInteger)score
{
    _score = score;
    self.scoreNode.text = [NSString stringWithFormat:@"Score %lu", (unsigned long)score];
}

- (void)setLivesCount:(NSUInteger)livesCount
{
    _livesCount = livesCount;
    self.livesCountNode.text = [NSString stringWithFormat:@"Lives Left: %lu", (unsigned long)livesCount];
}

- (NSMutableArray *)enemies
{
    if (!_enemies) {
        _enemies = [[NSMutableArray alloc] init];
    }
    return _enemies;
}

- (AVPlayer *)bgVideoPlayer
{
    if (!_bgVideoPlayer) {
        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"black_bg" ofType:@"mp4"]];
        _bgVideoPlayer = [[AVPlayer alloc] initWithURL:url];
        _bgVideoPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(bgVideoDidEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:[_bgVideoPlayer currentItem]];
    }
    return _bgVideoPlayer;
}

- (void)bgVideoDidEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
}

#define FLUBBLE_PLANET_OFFSET 30

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    SKNode *firstNode = contact.bodyA.node;
    SKNode *secondNode = contact.bodyB.node;
    
    SKNode *enemy;
    if (firstNode.physicsBody.categoryBitMask == enemyCategory) {
        enemy = firstNode;
    }
    
    if (secondNode.physicsBody.categoryBitMask == enemyCategory) {
        enemy = secondNode;
    }
    
    [enemy removeFromParent];
    [self.enemies removeObject:enemy];
    
    if (firstNode.physicsBody.categoryBitMask == flubbleCategory || secondNode.physicsBody.categoryBitMask == flubbleCategory) {
        self.livesCount--;
        if (self.livesCount == 0) [self transitionToGameOver];
    }
}

- (void)transitionToGameOver
{
    SKTransition *transition = [SKTransition revealWithDirection:SKTransitionDirectionDown duration:1.0];
    transition.pausesOutgoingScene = YES;
    GameOverScene *goScene = [[GameOverScene alloc] initWithSize:self.size score:self.score];
    [self.scene.view presentScene:goScene
                       transition:transition];
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        self.anchorPoint = CGPointMake(0.5, 0.5);
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate = self;
        self.score = 0;
        self.livesCount = 3;
        
        SKVideoNode *videoNode = [[SKVideoNode alloc] initWithAVPlayer:self.bgVideoPlayer];
        videoNode.size = self.size;
        videoNode.zPosition = -1;
        [self addChild:videoNode];
        [videoNode play];
        
        SKNode *planet = [FlubbleSpawner planetNode];
        planet.position = CGPointMake(-planet.frame.size.width/2, -planet.frame.size.height/2);
        [self addChild:planet];
        self.planetNode = planet;
        
        self.flubbleNode = [FlubbleSpawner flubbleNode];
        self.flubbleAngle = 0;
        self.flubbleOrbitRadius = planet.frame.size.width/2 + self.flubbleNode.frame.size.width/2 + FLUBBLE_PLANET_OFFSET;
        [planet addChild:self.flubbleNode];
        
        [NSTimer scheduledTimerWithTimeInterval:3
                                         target:self
                                       selector:@selector(addEnemy:)
                                       userInfo:nil
                                        repeats:YES];
        
    }
    return self;
}

- (void)addEnemy:(NSTimer *)timer
{
    SKNode *newEnemy = [FlubbleSpawner enemyCircleWithStartingRadius:self.size.width];
    [self.enemies addObject:newEnemy];
    [self addChild:newEnemy];
}

#define DECELERATION_FACTOR 1.1
#define GESTURE_TO_SPEED_FACTOR 2000

-(void)update:(CFTimeInterval)currentTime {
    if (self.initialTime == 0) {
        self.initialTime = currentTime;
    }
    self.score = currentTime - self.initialTime;
    
    
    /* Called before each frame is rendered */
    self.flubbleSpeed = CGPointMake(self.flubbleSpeed.x / DECELERATION_FACTOR, self.flubbleSpeed.y);
    self.flubbleAngle += self.flubbleSpeed.x/GESTURE_TO_SPEED_FACTOR;
    self.flubbleNode.position = CGPointMake(self.flubbleOrbitRadius*cos(self.flubbleAngle) + [self planetWidth]/2 - [self flubbleWidth]/2,
                                            self.flubbleOrbitRadius*sin(self.flubbleAngle) + [self planetWidth]/2 - [self flubbleWidth]/2);
    
    [self.enemies makeObjectsPerformSelector:@selector(update)];
}



- (void)didMoveToView:(SKView *)view
{
    [view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)]];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture
{
    self.flubbleSpeed = [gesture velocityInView:self.view];
}

- (CGFloat)flubbleWidth
{
    return self.flubbleNode.frame.size.width;
}

- (CGFloat)planetWidth
{
    return self.planetNode.frame.size.width;
}

@end
