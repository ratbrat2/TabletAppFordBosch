//
//  VariableStore.m
//  FordBoschTabletApp
//
//  Created by Ted Kim on 4/27/14.
//  Copyright (c) 2014 Johan Ismael. All rights reserved.
//

#import "VariableStore.h"
#import "Constants.h"


@interface VariableStore()
// May have to move these to public .h
@property (nonatomic, strong) NSString *participantId;
@property (nonatomic, strong) NSString *timestamp;
@end

@implementation VariableStore


+ (id)sharedManager {
    static VariableStore *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

// If participantId is new, set new Id and timestamp
+ (void)setParticipantId:(NSString *)participantIdToSet
{
    VariableStore *myInstance = [VariableStore sharedManager];
    [myInstance setParticipantId:participantIdToSet];
}

// Write log, but with no participant Id - just use last one
+ (void)writeToLog:(NSString *)message
{
    VariableStore *myInstance = [VariableStore sharedManager];
    [self writeToLog:message withParticipantId:myInstance.participantId];
}

// Write log with given participant Id - change if new participant
+ (void)writeToLog:(NSString *)message withParticipantId:(NSString *)participantIdToSet
{
    VariableStore *myInstance = [VariableStore sharedManager];
    [myInstance setParticipantId:participantIdToSet];
    
    //Get the file path
    NSString *fileName = [myInstance getLogfilePath];
    
    //create file if it doesn't exist
    if(![[NSFileManager defaultManager] fileExistsAtPath:fileName])
        [[NSFileManager defaultManager] createFileAtPath:fileName contents:nil attributes:nil];
    
    // Form message
    NSString *content = [NSString stringWithFormat:@"%@,%@\n", [myInstance getCurrentTimestamp:NO], message];
    
    //append text to file (you'll probably want to add a newline every write)
    NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:fileName];
    [file seekToEndOfFile];
    [file writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
    [file closeFile];
}


- (id)init {
    if (self = [super init]) {
        _participantId = DEFAULT_PARTICIPANT_ID;  // Default value
        _timestamp = [self getCurrentTimestamp:YES];
    }
    return self;
}

// Instance method version
- (void)setParticipantId:(NSString *)participantIdToSet
{
    if (![participantIdToSet isEqualToString:_participantId]) {
        NSLog(@"Setting new Participant ID! %@ -> %@", _participantId, participantIdToSet);
        _participantId = participantIdToSet;
        _timestamp = [self getCurrentTimestamp:YES];
    }
}

- (NSString *)getCurrentTimestamp:(BOOL)isFilename
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSString *formatString;
    if (isFilename) {
        formatString = @"yyyy.MM.dd#HH.mm.ss.SS";
    } else {
        formatString = @"yyyy-MM-dd, HH:mm:ss.SS";
        
    }
    [dateFormatter setDateFormat:formatString];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"PST"]];
    
    NSDate *date = [[NSDate alloc] init];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:usLocale];

    return [dateFormatter stringFromDate:date];
}

- (NSString *)getLogfilePath
{
    NSString *filename = [NSString stringWithFormat:@"%@#%@.txt", self.participantId, self.timestamp];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:filename];
    return filePath;
}

@end
