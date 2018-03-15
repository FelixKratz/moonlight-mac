//
//  StreamManager.m
//  Moonlight macOS
//
//  Created by Felix Kratz on 10.03.18.
//  Copyright (c) 2018 Felix Kratz. All rights reserved.
//

#import "StreamManager.h"
#import "CryptoManager.h"
#import "HttpManager.h"
#import "Utils.h"
#import "StreamView.h"
#import "ServerInfoResponse.h"
#import "HttpResponse.h"
#import "HttpRequest.h"
#import "IdManager.h"
#import <AppKit/AppKit.h>

@implementation StreamManager {
    StreamConfiguration* _config;
    NSView* _renderView;
    id<ConnectionCallbacks> _callbacks;
    Connection* _connection;
}

- (id) initWithConfig:(StreamConfiguration*)config renderView:(NSView*)view connectionCallbacks:(id<ConnectionCallbacks>)callbacks {
    self = [super init];
    _config = config;
    _renderView = view;
    _callbacks = callbacks;
    _config.riKey = [Utils randomBytes:16];
    _config.riKeyId = arc4random();
    return self;
}


- (void)main {
    [CryptoManager generateKeyPairUsingSSl];
    NSString* uniqueId = [IdManager getUniqueId];
    NSData* cert = [CryptoManager readCertFromFile];
    
    HttpManager* hMan = [[HttpManager alloc] initWithHost:_config.host
                                                 uniqueId:uniqueId
                                               deviceName:@"roth"
                                                     cert:cert];
    
    ServerInfoResponse* serverInfoResp = [[ServerInfoResponse alloc] init];
    [hMan executeRequestSynchronously:[HttpRequest requestForResponse:serverInfoResp withUrlRequest:[hMan newServerInfoRequest]
                                       fallbackError:401 fallbackRequest:[hMan newHttpServerInfoRequest]]];
    NSString* pairStatus = [serverInfoResp getStringTag:@"PairStatus"];
    NSString* appversion = [serverInfoResp getStringTag:@"appversion"];
    NSString* gfeVersion = [serverInfoResp getStringTag:@"GfeVersion"];
    NSString* serverState = [serverInfoResp getStringTag:@"state"];
    NSLog(@"%@", pairStatus);
    NSLog(@"\n");
    NSLog(@"%@", appversion);
    NSLog(@"\n");
    NSLog(@"%@", gfeVersion);
    NSLog(@"\n");
    NSLog(@"%@", serverState);
    
    if (![serverInfoResp isStatusOk] || pairStatus == NULL || appversion == NULL || serverState == NULL) {
        [_callbacks launchFailed:@"Failed to connect to PC"];
        return;
    }
    
    if (![pairStatus isEqualToString:@"1"]) {
        // Not paired
        [_callbacks launchFailed:@"Device not paired to PC"];
        return;
    }
    
    // resumeApp and launchApp handle calling launchFailed
    if ([serverState hasSuffix:@"_SERVER_BUSY"]) {
        // App already running, resume it
        if (![self resumeApp:hMan]) {
            return;
        }
    } else {
        // Start app
        if (![self launchApp:hMan]) {
            return;
        }
    }
    
    // Populate the config's version fields from serverinfo
    _config.appVersion = appversion;
    _config.gfeVersion = gfeVersion;
    VideoDecoderRenderer* renderer = [[VideoDecoderRenderer alloc]initWithView: _renderView];
    _connection = [[Connection alloc] initWithConfig:_config renderer:renderer connectionCallbacks:_callbacks];
    NSOperationQueue* opQueue = [[NSOperationQueue alloc] init];
    [opQueue addOperation:_connection];
}

- (void) stopStream
{
    [_connection terminate];
}

- (BOOL) launchApp:(HttpManager*)hMan {
    HttpResponse* launchResp = [[HttpResponse alloc] init];
    [hMan executeRequestSynchronously:[HttpRequest requestForResponse:launchResp withUrlRequest:
                          [hMan newLaunchRequest:_config.appID
                                           width:_config.width
                                          height:_config.height
                                     refreshRate:_config.frameRate
                                            sops:0
                                           rikey:[Utils bytesToHex:_config.riKey]
                                         rikeyid:_config.riKeyId
                                      localAudio:1
                                     gamepadMask:_config.gamepadMask]]];
    NSString *gameSession = [launchResp getStringTag:@"gamesession"];
    if (launchResp == NULL || ![launchResp isStatusOk]) {
        [_callbacks launchFailed:@"Failed to launch app"];
        return FALSE;
    } else if (gameSession == NULL || [gameSession isEqualToString:@"0"]) {
        [_callbacks launchFailed:launchResp.statusMessage];
        return FALSE;
    }
    
    return TRUE;
}

- (BOOL) resumeApp:(HttpManager*)hMan {
    HttpResponse* resumeResp = [[HttpResponse alloc] init];
    [hMan executeRequestSynchronously:[HttpRequest requestForResponse:resumeResp withUrlRequest:
                          [hMan newResumeRequestWithRiKey:[Utils bytesToHex:_config.riKey]
                                                  riKeyId:_config.riKeyId]]];
    NSString* resume = [resumeResp getStringTag:@"resume"];
    if (resumeResp == NULL || ![resumeResp isStatusOk]) {
        [_callbacks launchFailed:@"Failed to resume app"];
        return FALSE;
    } else if (resume == NULL || [resume isEqualToString:@"0"]) {
        [_callbacks launchFailed:resumeResp.statusMessage];
        return FALSE;
    }
    
    return TRUE;
}

@end
