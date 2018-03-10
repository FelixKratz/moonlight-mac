//
//  MDNSManager.m
//  Moonlight
//
//  Created by Diego Waxemberg on 10/14/14.
//  Copyright (c) 2014 Moonlight Stream. All rights reserved.
//

#import "MDNSManager.h"
#import "TemporaryHost.h"

@implementation MDNSManager {
    NSNetServiceBrowser* mDNSBrowser;
    NSMutableArray* domains;
    NSMutableArray* services;
    BOOL scanActive;
}

static NSString* NV_SERVICE_TYPE = @"_nvstream._tcp";

- (id) initWithCallback:(id<MDNSCallback>)callback {
    self = [super init];
    
    self.callback = callback;
    
    mDNSBrowser = [[NSNetServiceBrowser alloc] init];
    [mDNSBrowser setDelegate:self];
    
    domains = [[NSMutableArray alloc] init];
    services = [[NSMutableArray alloc] init];
    
    return self;
}

- (void) searchForHosts {
    scanActive = TRUE;
    [mDNSBrowser searchForServicesOfType:NV_SERVICE_TYPE inDomain:@""];
}

- (void) stopSearching {
    scanActive = FALSE;
    [mDNSBrowser stop];
}

- (NSArray*) getFoundHosts {
    NSMutableArray* hosts = [[NSMutableArray alloc] init];
    for (NSNetService* service in services) {
        if (service.hostName != nil) {
            TemporaryHost* host = [[TemporaryHost alloc] init];
            host.activeAddress = host.localAddress = service.hostName;
            host.name = service.hostName;
            [hosts addObject:host];
        }
    }
    return hosts;
}

- (void)netServiceDidResolveAddress:(NSNetService *)service {
    [self.callback updateHosts:[self getFoundHosts]];
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
    
    // Schedule a retry in 2 seconds
    [NSTimer scheduledTimerWithTimeInterval:2.0
                                     target:self
                                   selector:@selector(retryResolveTimerCallback:)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    [aNetService setDelegate:self];
    [aNetService resolveWithTimeout:5];
    
    [services removeObject:aNetService];
    [services addObject:aNetService];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    [services removeObject:aNetService];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didNotSearch:(NSDictionary *)errorDict {
    
    // Schedule a retry in 2 seconds
    [NSTimer scheduledTimerWithTimeInterval:2.0
                                     target:self
                                   selector:@selector(retrySearchTimerCallback:)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)retrySearchTimerCallback:(NSTimer *)timer {
    // Check if we've been stopped since this was queued
    if (!scanActive) {
        return;
    }
    
    [mDNSBrowser stop];
    [mDNSBrowser searchForServicesOfType:NV_SERVICE_TYPE inDomain:@""];
}

- (void)retryResolveTimerCallback:(NSTimer *)timer {
    // Check if we've been stopped since this was queued
    if (!scanActive) {
        return;
    }
    
    for (NSNetService* service in services) {
        if (service.hostName == nil) {
            [service setDelegate:self];
            [service resolveWithTimeout:5];
        }
    }
}

@end
