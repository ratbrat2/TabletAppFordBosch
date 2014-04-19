//
//  Constants.h
//  FordBoschTabletApp
//
//  Created by Ted Kim on 12/10/13.
//  Copyright (c) 2013 Johan Ismael. All rights reserved.
//

#ifndef FordBoschTabletApp_Constants_h
#define FordBoschTabletApp_Constants_h

// participant id:event numbering: counter: message: random stuff
#define PREFIX_SITUATIONAL_AWARENESS @"Participant#:event#:10:"
#define PREFIX_TAKE_OVER @"Participant#:event#:20:"

// Log file
#define LOG_FILE_PATH @"StanfordResearchLog.txt"
#define LOG_SIMULATOR_MESSAGE @"Simulator Message"
#define LOG_SIMULATOR_EVENT @"Simulator Event"
#define LOG_IPAD_EVENT @"Ipad Event"


#define UDP_HOST_ADDRESS @"127.0.0.1"
#define UDP_PORT_NUMBER 55555

// For debug, clearing of situational awareness bar
#define UDP_CLEAR_MESSAGE @"CLEAR_CLEAR_CLEAR"

#endif
