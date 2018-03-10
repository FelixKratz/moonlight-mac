//
//  ViewController.m
//  Moonlight macOS
//
//  Created by Felix Kratz on 09.03.18.
//  Copyright © 2018 Felix Kratz. All rights reserved.
//

#import "ViewController.h"
@import ImageIO;

#import "CryptoManager.h"
#import "HttpManager.h"
#import "Connection.h"
#import "StreamManager.h"
#import "Utils.h"
#import "DataManager.h"
#import "TemporarySettings.h"
#import "WakeOnLanManager.h"
#import "AppListResponse.h"
#import "ServerInfoResponse.h"
#import "StreamFrameViewController.h"
#import "TemporaryApp.h"
#import "IdManager.h"

@implementation ViewController{
    NSOperationQueue* _opQueue;
    TemporaryHost* _selectedHost;
    NSString* _uniqueId;
    NSData* _cert;
    DiscoveryManager* _discMan;
    AppAssetManager* _appManager;
    StreamConfiguration* _streamConfig;
    //NSAlertController* _pairAlert;
    int currentPosition;
    NSArray* _sortedAppList;
    NSCache* _boxArtCache;
    NSString* _host;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [CryptoManager generateKeyPairUsingSSl];
    _uniqueId = [IdManager getUniqueId];
    _cert = [CryptoManager readCertFromFile];
    
    _appManager = [[AppAssetManager alloc] initWithCallback:self];
    _opQueue = [[NSOperationQueue alloc] init];
    
    // Do any additional setup after loading the view.
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


- (IBAction)buttonConnect:(id)sender {
    _host = _textFieldHost.stringValue;
    HttpManager* hMan = [[HttpManager alloc] initWithHost:_textFieldHost.stringValue
                                                 uniqueId:_uniqueId
                                               deviceName:@"roth"
                                                     cert:_cert];
    
    ServerInfoResponse* serverInfoResp = [[ServerInfoResponse alloc] init];
    [hMan executeRequestSynchronously:[HttpRequest requestForResponse:serverInfoResp withUrlRequest:[hMan newServerInfoRequest]
                                                        fallbackError:401 fallbackRequest:[hMan newHttpServerInfoRequest]]];
    
    if ([[serverInfoResp getStringTag:@"PairStatus"] isEqualToString:@"1"]) {
        NSLog(@"alreadyPaired");
        [self alreadyPaired];
    } else {
        // Polling the server while pairing causes the server to screw up
        NSLog(@"Pairing");
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            HttpManager* hMan = [[HttpManager alloc] initWithHost:_host uniqueId:_uniqueId deviceName:deviceName cert:_cert];
        PairManager* pMan = [[PairManager alloc] initWithManager:hMan   andCert:_cert callback:self];
        [_opQueue addOperation:pMan];
    });
    }
}
- (void)updateAllHosts:(NSArray *)hosts {
    
}

- (void)alreadyPaired {
    _streamConfig = [[StreamConfiguration alloc] init];
    _streamConfig.bitRate = 7000;
    _streamConfig.frameRate = 30;
    _streamConfig.height = 1050;
    _streamConfig.width = 1680;
    _streamConfig.host = _textFieldHost.stringValue;
    _streamConfig.streamingRemotely = 1;
    _streamConfig.appID = @"93751264";
    [self performSegueWithIdentifier:@"showStream" sender:self];
}

- (void)pairFailed:(NSString *)message {
    
}

- (void)pairSuccessful {
    [self alreadyPaired];
}

- (void)showPIN:(NSString *)PIN
{
    NSLog(@"Pin: %@", PIN);
    NSAlert *alert = [NSAlert init];
    NSMutableString *alertMessage = [NSMutableString init];
    [alertMessage appendString:@"Pin: "];
    [alertMessage appendString:PIN];
    alert.messageText = alertMessage;
    [alert runModal];
}

- (void)addHostClicked {
    
}

- (void)hostClicked:(TemporaryHost *)host view:(NSView *)view {
    
}

- (void)hostLongClicked:(TemporaryHost *)host view:(NSView *)view {
    
}

- (void)appClicked:(TemporaryApp *)app {
    
}

- (void)receivedAssetForApp:(TemporaryApp *)app {
    
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    
}

- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationController isKindOfClass:[StreamFrameViewController class]]) {
        StreamFrameViewController* streamFrame = segue.destinationController;
        streamFrame.streamConfig = _streamConfig;
    }
}

@end
