//
//  ViewController.m
//  dummy
//
//  Created by Johan Ismael on 11/21/13.
//  Copyright (c) 2013 Johan Ismael. All rights reserved.
//

#import "GameViewController.h"
#import "MyScene.h"

@interface GameViewController ()
@property (nonatomic, strong) MyScene *myScene;
@end

@implementation GameViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
}

- (void)viewDidLayoutSubviews
{
    SKView * skView = (SKView *)self.view;
    // Create and configure the scene.
    if (!self.myScene) {
        self.myScene = [MyScene sceneWithSize:skView.bounds.size];
        self.myScene.scaleMode = SKSceneScaleModeAspectFill;
    
        // Present the scene.
        [skView presentScene:self.myScene];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // Unload
    if (self.myScene) {
        NSLog(@"unloadTimer from viewDidDisappear");
        [self.myScene unloadTimer];
    }
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
