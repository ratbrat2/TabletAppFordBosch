//
//  VideoViewController.m
//  FordBoschTabletApp
//
//  Created by Ted Kim on 11/10/13.
//  Copyright (c) 2013 Johan Ismael. All rights reserved.
//

#import "VideoViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface VideoViewController ()
@property (nonatomic, strong) MPMoviePlayerController *player;
// We only need these as properties here to make them appear as subview
@property (weak, nonatomic) IBOutlet UIButton *situationalAwarenessButton;
@property (weak, nonatomic) IBOutlet UIButton *takeoverButton;
@end

@implementation VideoViewController

#pragma mark - Properties

// setup player
- (void)setupPlayer
{
    if (!self.player) {
        // Make sure movie is in root path to this app (e.g. /TabletAppFordBosch/<movie>)
        NSString *stringPath = [[NSBundle mainBundle] pathForResource:@"Big Buck Bunny" ofType:@"mp4"];
        NSURL *movieURL = [NSURL fileURLWithPath:stringPath];
        self.player = [[MPMoviePlayerController alloc] initWithContentURL: movieURL];
        
        // Keeping media slider for now until stability issues resolved
        //self.player.controlStyle = MPMovieControlStyleNone;
        
    }
}

#pragma mark - Initialization

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    if (!self.player) {
        [self setupPlayer];
    }
    [self.player prepareToPlay];
    [self.player.view setFrame:self.view.bounds];  // player's frame must match parent's
    [self.view addSubview: self.player.view];
    [self.player play];
    
    // Bring debug buttons to front
    [self.view bringSubviewToFront:self.situationalAwarenessButton];
    [self.view bringSubviewToFront:self.takeoverButton];
}

- (void)viewDidLayoutSubviews
{
    [self.player.view setFrame:self.view.bounds];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // Unload player
    if (self.player) {
        self.player = nil;
    }
}

@end
