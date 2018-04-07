//
//  Utils.h
//  Moonlight
//
//  Created by Diego Waxemberg on 10/20/14.
//  Copyright (c) 2014 Moonlight Stream. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

typedef NS_ENUM(int, PairState) {
    PairStateUnknown,
    PairStateUnpaired,
    PairStatePaired
};

// Enum of connection error types
typedef NS_ENUM(long, connectionTerminationCauses) {
    TerminationUser,
    TerminationUnknown,
    TerminationHostQuit,
    TerminationHostQuitUnexpectatly,
    TerminationClientQuit,
    TerminationClientQuitUnexpectatly,
    TerminationAudioStreamFailed,
    TerminationVideoStreamFailed,
    TerminationControlStreamFailed,
};

FOUNDATION_EXPORT NSString *const deviceName;

+ (NSData*) randomBytes:(NSInteger)length;
+ (NSString*) bytesToHex:(NSData*)data;
+ (NSData*) hexToBytes:(NSString*) hex;
+ (int) resolveHost:(NSString*)host;

@end

@interface NSString (NSStringWithTrim)

- (NSString*) trim;

@end
