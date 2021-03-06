//
//  ViewController.m
//  FordBoschTabletApp
//
//  Created by Johan Ismael on 10/24/13.
//  Copyright (c) 2013 Johan Ismael. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncUdpSocket.h"
#import "Constants.h"
#import "VariableStore.h"

@interface ViewController ()
@property (nonatomic, strong) NSString *situationalAwarenessMessage;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // When user first enters a view, disable back button until at least 7 minutes
    if (self.navigationItem) {
        [NSTimer scheduledTimerWithTimeInterval:30.0f
                                         target:self
                                       selector:@selector(disableBackButton:)
                                       userInfo:nil
                                        repeats:NO];
    }
    // Log entered into view message
    [VariableStore writeToLog:[NSString stringWithFormat:@"%@,-1,Entered %@ View", LOG_IPAD_EVENT, self.title]];
}

- (void)disableBackButton:(NSTimer *)timer
{
    self.navigationItem.hidesBackButton = YES;
    [NSTimer scheduledTimerWithTimeInterval:360.0f
                                     target:self
                                   selector:@selector(reEnableBackButton:)
                                   userInfo:nil
                                    repeats:NO];

}
- (void)reEnableBackButton:(NSTimer *)timer
{
    if (self.navigationItem) {
        if (![self.title isEqual: @"Main"]) {
            self.navigationItem.hidesBackButton = NO;
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Log exited from view message
    [VariableStore writeToLog:[NSString stringWithFormat:@"%@,-1,Exited %@ View", LOG_IPAD_EVENT, self.title]];

}

// Debug buttons to send takeover or awareness messages via UDP
// Situational awareness message: '1x:message'
// Takeover message: '2x:message'
- (IBAction)takeOver:(UIButton *)sender {
    NSString *message = @"Please take over driving of your vehicle";
    [self sendUdp:[NSString stringWithFormat:@"%@%@:0", PREFIX_TAKE_OVER, message]];
}

- (IBAction)situationalAwareness:(UIButton *)sender {
    NSString *message = @"Caution: entering school zone";
    if (!self.situationalAwarenessMessage) {
        self.situationalAwarenessMessage = message;
    } else {
        message = UDP_CLEAR_MESSAGE;
        self.situationalAwarenessMessage = nil;
    }
    [self sendUdp:[NSString stringWithFormat:@"%@%@:0", PREFIX_SITUATIONAL_AWARENESS, message]];
}

- (void)sendUdp:(NSString *)message
{
    GCDAsyncUdpSocket *udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self
                                                                 delegateQueue:dispatch_get_main_queue()];
    NSError *error = nil;
    [udpSocket bindToPort:UDP_PORT_NUMBER
                    error:&error];
    
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    [udpSocket sendData:data
                 toHost:UDP_HOST_ADDRESS
                   port:UDP_PORT_NUMBER
            withTimeout:3
                    tag:0];
}


@end
