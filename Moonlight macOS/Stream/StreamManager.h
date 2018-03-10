//
//  StreamManager.h
//  Moonlight macOS
//
//  Created by Felix Kratz on 10.03.18.
//  Copyright (c) 2018 Felix Kratz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StreamConfiguration.h"
#import "Connection.h"
#import "StreamView.h"

@interface StreamManager : NSOperation

- (id) initWithConfig:(StreamConfiguration*)config renderView:(NSView*)view connectionCallbacks:(id<ConnectionCallbacks>)callback;
- (void) stopStream;

@end
