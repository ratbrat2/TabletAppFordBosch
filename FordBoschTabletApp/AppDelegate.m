//
//  AppDelegate.m
//  FordBoschTabletApp
//
//  Created by Johan Ismael on 10/24/13.
//  Copyright (c) 2013 Johan Ismael. All rights reserved.
//

#import "AppDelegate.h"
#import "GCDAsyncUdpSocket.h"
#import "Constants.h"
#import "CustomIOS7AlertView.h"

@interface AppDelegate ()

@property (nonatomic, strong) GCDAsyncUdpSocket *udpSocket;
@property (nonatomic, strong) UIView *situationalMessageView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIImage *situationalAwarenessImage;
@property (nonatomic, strong) UILabel *situationalAwarenessLabel;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSMutableDictionary *storedMessages;
@property (nonatomic) NSUInteger lastSituationalAwarenessIndex;
@property (nonatomic) NSUInteger lastTakeoverIndex;
@property (nonatomic) BOOL firstMessageReceived;

@end

@implementation AppDelegate

// Lazy instantiation
- (NSMutableDictionary *)storedMessages
{
    if (!_storedMessages) {
        _storedMessages = [[NSMutableDictionary alloc] init];
    }
    return _storedMessages;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    self.udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self
                                                   delegateQueue:dispatch_get_main_queue()];
    
    NSError *error = nil;
    [self.udpSocket bindToPort:UDP_PORT_NUMBER
                         error:&error];
    
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    } else {
        [self.udpSocket beginReceiving:&error];
        
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
    
    self.situationalMessageView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, self.window.bounds.size.width, 100)];
    self.situationalMessageView.backgroundColor = [UIColor blackColor];
    [self.window.rootViewController.view addSubview:self.situationalMessageView];
    
    self.lastTakeoverIndex = 0;
    self.lastSituationalAwarenessIndex = 0;
    self.firstMessageReceived = NO;

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)clearSituationalAwareness
{
    NSLog(@"Clear message received!");
    // Special debug case - let's clear up the situational awareness bar
    if (self.containerView) self.containerView.hidden = YES;
    
    
    if (self.timer != nil) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)clearSituationalAwareness:(NSTimer *)timer
{
    [self clearSituationalAwareness];
}

- (void)startTimerAndClearSituationalAwareness
{
    if (self.timer != nil) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    [NSTimer scheduledTimerWithTimeInterval:10.0f
                                     target:self
                                   selector:@selector(clearSituationalAwareness:)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock
   didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    // Parse received UDP message into Situational Awareness bar or Takeover message pop-up
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    // Use Regex to see if situational or takeover
    NSString *pattern = @"^(\\d+):(.*):.*$";
    
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:pattern
                                  options:NSRegularExpressionCaseInsensitive
                                  error:nil];
    NSTextCheckingResult *textCheckingResult = [regex firstMatchInString:dataString options:0 range:NSMakeRange(0, dataString.length)];
    
    // Non-matching string found!
    if (!textCheckingResult) {
        NSLog(@"WARNING: Unexpected UDP string: %@", dataString);
        return;
    }
    
    NSRange matchIndexRange = [textCheckingResult rangeAtIndex:1];
    NSRange matchMessageRange = [textCheckingResult rangeAtIndex:2];
    NSString *matchIndex = [dataString substringWithRange:matchIndexRange];
    NSString *matchMessage = [dataString substringWithRange:matchMessageRange];
    NSLog(@"Found index '%@' with string '%@'", matchIndex, matchMessage);
    
    if ([[matchIndex substringToIndex:1] isEqualToString:@"1"]) {
        // Situational Awareness message!
        if ([matchMessage isEqualToString:UDP_CLEAR_MESSAGE]) {
            [self clearSituationalAwareness];
            // Also cleanup counters
            self.lastSituationalAwarenessIndex = 0;
            self.lastTakeoverIndex = 0;
            self.firstMessageReceived = NO;

        } else {
            // Only update if monotonically increasing
            if ([matchIndex integerValue] > self.lastSituationalAwarenessIndex) {
                self.lastSituationalAwarenessIndex = [matchIndex integerValue];

                if (!self.firstMessageReceived) {
                    // If first message hasn't been received (starting logic), update index to first received UDP but don't display message
                    self.firstMessageReceived = YES;
                    return;
                }

                [self.storedMessages setValue:matchMessage forKey:matchIndex];
            
                if (self.containerView && self.situationalAwarenessLabel) {
                    self.situationalAwarenessLabel.text = matchMessage;
                } else {
                    self.containerView = [[UIView alloc] initWithFrame:CGRectZero];
                    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.situationalAwarenessImage];
                    self.situationalAwarenessLabel = [[UILabel alloc] initWithFrame:CGRectZero];
                    [self.containerView addSubview:imageView];
                    [self.containerView addSubview:self.situationalAwarenessLabel];
                    
                    self.situationalAwarenessLabel.textColor = [UIColor whiteColor];
                    self.situationalAwarenessLabel.backgroundColor = [UIColor clearColor];
                    self.situationalAwarenessLabel.text = matchMessage;
                    [self.situationalAwarenessLabel sizeToFit];
                    
                    CGFloat newX = imageView.frame.origin.x + imageView.frame.size.width + 5;
                    CGFloat newY = imageView.frame.origin.y + imageView.frame.size.height/2 - self.situationalAwarenessLabel.frame.size.height/2;
                    self.situationalAwarenessLabel.frame = CGRectMake(newX,
                                                                      newY,
                                                                      self.situationalAwarenessLabel.frame.size.width,
                                                                      self.situationalAwarenessLabel.frame.size.height);
                    
                    [self resizeToFitSubviews:self.containerView];
                    [self.situationalMessageView addSubview:self.containerView];
                    self.containerView.center = [self.situationalMessageView convertPoint:self.situationalMessageView.center fromView:self.situationalMessageView.superview];
                }
                self.containerView.hidden = NO;
                
                // Start timer to clear message
                [self startTimerAndClearSituationalAwareness];
            }
        }
    } else if ([[matchIndex substringToIndex:1] isEqualToString:@"2"]) {
        // Takeover message!
        
        // Only update if monotonically increasing
        if ([matchIndex integerValue] > self.lastTakeoverIndex) {
            self.lastTakeoverIndex = [matchIndex integerValue];
            
            if (!self.firstMessageReceived) {
                // If first message hasn't been received (starting logic), update index to first received UDP but don't display message
                self.firstMessageReceived = YES;
                return;
            }

            [self.storedMessages setValue:matchMessage forKey:matchIndex];
        
            CustomIOS7AlertView *alertView = [[CustomIOS7AlertView alloc] init];
            [alertView setButtonTitles:@[@"OK"]];
            UIView *demoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 290, 200)];
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(290/2.0 - 40, 20, 80, 80)];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 100, 270, 80)];
            label.text = matchMessage;
            label.textAlignment = NSTextAlignmentCenter;
            label.numberOfLines = 2;
            
            [imageView setImage:[UIImage imageNamed:@"TakeOver"]];
            [demoView addSubview:imageView];
            [demoView addSubview:label];
            
            // Add some custom content to the alert view
            [alertView setContainerView:demoView];
            
            [alertView show];
        }
    }
}

- (void)resizeToFitSubviews:(UIView *)view
{
    float w = 0;
    float h = 0;
    
    for (UIView *v in [view subviews]) {
        float fw = v.frame.origin.x + v.frame.size.width;
        float fh = v.frame.origin.y + v.frame.size.height;
        w = MAX(fw, w);
        h = MAX(fh, h);
    }
    [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, w, h)];
}

// Getter for situational awareness image
- (UIImage *)situationalAwarenessImage
{
    if (!_situationalAwarenessImage) {
        UIImage *origImage = [UIImage imageNamed:[NSString stringWithFormat:@"SituationalAwareness"]];
        
        // Let's resize to what we want
        CGSize newSize = CGSizeMake(70, 70);
        UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
        [origImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
        _situationalAwarenessImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return _situationalAwarenessImage;
}

@end
