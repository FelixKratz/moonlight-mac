//
//  DiscoveryWorker.h
//  Moonlight
//
//  Created by Diego Waxemberg on 1/2/15.
//  Copyright (c) 2015 Moonlight Stream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TemporaryHost.h"

@interface DiscoveryWorker : NSOperation

- (id) initWithHost:(TemporaryHost*)host uniqueId:(NSString*)uniqueId cert:(NSData*)cert;
- (void) discoverHost;
- (TemporaryHost*) getHost;

@end
