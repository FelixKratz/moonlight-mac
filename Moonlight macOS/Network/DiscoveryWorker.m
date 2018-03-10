//
//  DiscoveryWorker.m
//  Moonlight
//
//  Created by Diego Waxemberg on 1/2/15.
//  Copyright (c) 2015 Moonlight Stream. All rights reserved.
//

#import "DiscoveryWorker.h"
#import "Utils.h"
#import "HttpManager.h"
#import "ServerInfoResponse.h"
#import "HttpRequest.h"
#import "DataManager.h"

@implementation DiscoveryWorker {
    TemporaryHost* _host;
    NSString* _uniqueId;
    NSData* _cert;
}

static const float POLL_RATE = 2.0f; // Poll every 2 seconds

- (id) initWithHost:(TemporaryHost*)host uniqueId:(NSString*)uniqueId cert:(NSData*)cert {
    self = [super init];
    _host = host;
    _uniqueId = uniqueId;
    _cert = cert;
    return self;
}

- (TemporaryHost*) getHost {
    return _host;
}

- (void)main {
    while (!self.cancelled) {
        [self discoverHost];
        if (!self.cancelled) {
            [NSThread sleepForTimeInterval:POLL_RATE];
        }
    }
}

- (NSArray*) getHostAddressList {
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:3];

    if (_host.localAddress != nil) {
        [array addObject:_host.localAddress];
    }
    if (_host.externalAddress != nil) {
        [array addObject:_host.externalAddress];
    }
    if (_host.address != nil) {
        [array addObject:_host.address];
    }
    
    // Remove duplicate addresses from the list.
    // This is done using an array rather than a set
    // to preserve insertion order of addresses.
    for (int i = 0; i < [array count]; i++) {
        NSString *addr1 = [array objectAtIndex:i];
        
        for (int j = 1; j < [array count]; j++) {
            if (i == j) {
                continue;
            }
            
            NSString *addr2 = [array objectAtIndex:j];
            
            if ([addr1 isEqualToString:addr2]) {
                // Remove the last address
                [array removeObjectAtIndex:j];
                
                // Begin searching again from the start
                i = -1;
                break;
            }
        }
    }
    
    return array;
}

- (void) discoverHost {
    BOOL receivedResponse = NO;
    NSArray *addresses = [self getHostAddressList];
    
    
    // Give the PC 3 tries to respond before declaring it offline
    for (int i = 0; i < 3; i++) {
        for (NSString *address in addresses) {
            if (self.cancelled) {
                // Get out without updating the status because
                // it might not have finished checking the various
                // addresses
                return;
            }
            
            ServerInfoResponse* serverInfoResp = [self requestInfoAtAddress:address];
            receivedResponse = [self checkResponse:serverInfoResp];
            if (receivedResponse) {
                [serverInfoResp populateHost:_host];
                _host.activeAddress = address;
                
                // Update the database using the response
                DataManager *dataManager = [[DataManager alloc] init];
                [dataManager updateHost:_host];
                break;
            }
        }
        
        if (receivedResponse) {
            break;
        }
        else {
            // Wait for one second then retry
            [NSThread sleepForTimeInterval:1];
        }
    }

    _host.online = receivedResponse;
    if (receivedResponse) {
    }
}

- (ServerInfoResponse*) requestInfoAtAddress:(NSString*)address {
    HttpManager* hMan = [[HttpManager alloc] initWithHost:address
                                                 uniqueId:_uniqueId
                                               deviceName:deviceName
                                                     cert:_cert];
    ServerInfoResponse* response = [[ServerInfoResponse alloc] init];
    [hMan executeRequestSynchronously:[HttpRequest requestForResponse:response
                                                       withUrlRequest:[hMan newServerInfoRequest]
                                       fallbackError:401 fallbackRequest:[hMan newHttpServerInfoRequest]]];
    return response;
}

- (BOOL) checkResponse:(ServerInfoResponse*)response {
    if ([response isStatusOk]) {
        // If the response is from a different host then do not update this host
        if ((_host.uuid == nil || [[response getStringTag:TAG_UNIQUE_ID] isEqualToString:_host.uuid])) {
            return YES;
        } else {
        }
    }
    return NO;
}

@end
