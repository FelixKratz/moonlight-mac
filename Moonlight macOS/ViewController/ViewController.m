//
//  ViewController.m
//  Moonlight macOS
//
//  Created by Felix Kratz on 09.03.18.
//  Copyright © 2018 Felix Kratz. All rights reserved.
//

#import "ViewController.h"

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
#import "SettingsViewController.h"

#define BITRATE_OFFSET 1000
#define BITRATE_SCALE 1.25

@implementation ViewController{
    NSOperationQueue* _opQueue;
    TemporaryHost* _selectedHost;
    NSString* _uniqueId;
    NSData* _cert;
    StreamConfiguration* _streamConfig;
    //NSAlertController* _pairAlert;
    int currentPosition;
    NSArray* _sortedAppList;
    NSSet* _appList;
    NSString* _host;
    SettingsViewController *_settingsView;
    CGFloat settingsFrameHeight;
    bool showSettings;
    NSAlert* _alert;
    long error;
}

- (long)error {
    return error;
}

- (void)setError:(long)errorCode {
    error = errorCode;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [CryptoManager generateKeyPairUsingSSl];
    _uniqueId = [IdManager getUniqueId];
    _cert = [CryptoManager readCertFromFile];
    
    _opQueue = [[NSOperationQueue alloc] init];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear {
    [super viewWillAppear];
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"AppleInterfaceStyle"]  isEqual: @"Dark"]) {
        [self.view.window setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameVibrantDark]];
    }
}

- (void)viewDidAppear {
    [super viewDidAppear];
    
    if (self.view.bounds.size.height == NSScreen.mainScreen.frame.size.height && self.view.bounds.size.width == NSScreen.mainScreen.frame.size.width)
    {
        [self.view.window toggleFullScreen:self];
        [self.view.window setStyleMask:[self.view.window styleMask] & ~NSWindowStyleMaskResizable];
        return;
    }
    [_buttonLaunch setEnabled:false];
    [_popupButtonSelection removeAllItems];
    _settingsView = [self.childViewControllers lastObject];
    
    if (_settingsView.getCurrentHost != nil)
        _textFieldHost.stringValue = _settingsView.getCurrentHost;
    settingsFrameHeight = _layoutConstraintSetupFrame.constant;
    _layoutConstraintSetupFrame.constant = 0;
    showSettings = false;
    
    if (error != TerminationUser) {
        [self showAlert:[NSString stringWithFormat: @"The connection terminated."]];
    }
}

-(void) showAlert:(NSString*) message {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_alert = [NSAlert new];
        self->_alert.messageText = message;
        [self->_alert beginSheetModalForWindow:[self.view window] completionHandler:^(NSInteger result) {
            NSLog(@"Success");
        }];
    });
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void) saveSettings {
    DataManager* dataMan = [[DataManager alloc] init];
    NSInteger framerate = [_settingsView getChosenFrameRate];
    NSInteger height = [_settingsView getChosenStreamHeight];
    NSInteger width = [_settingsView getChosenStreamWidth];
    NSInteger streamingRemotely = [_settingsView getRemoteOptions];
    NSInteger bitrate = [_settingsView getChosenBitrate];
    [dataMan saveSettingsWithBitrate:bitrate framerate:framerate height:height width:width
                              remote: streamingRemotely host:_textFieldHost.stringValue];
}

- (IBAction)buttonLaunchPressed:(id)sender {
    [self saveSettings];
    DataManager* dataMan = [[DataManager alloc] init];
    TemporarySettings* streamSettings = [dataMan getSettings];
    _streamConfig = [[StreamConfiguration alloc] init];
    _streamConfig.frameRate = [streamSettings.framerate intValue];
    
    // It turns out, that the input bitrate and the streaming bitrate scale perfectly
    // linear with the coefficients: BITRATE_OFFSET and BITRATE_SCALE.
    // The transformation of the streaming bitrate makes it possible to set the total
    // bandwidth in the settings tab. This is a fairly rough estimate, as there are
    // some differences in the coefficients for the different resolutions and framerates.
    // Maybe I will implement this more accurate some time, but for now this will be much
    // better than before. Especially for connections where the host's upload or the
    // client's download speed is limited. -> see more in BitrateTests folder.
    _streamConfig.bitRate = ([streamSettings.bitrate intValue] - BITRATE_OFFSET) / BITRATE_SCALE;
    _streamConfig.height = [streamSettings.height intValue];
    _streamConfig.width = [streamSettings.width intValue];
    _streamConfig.streamingRemotely = [streamSettings.streamingRemotely intValue];
    _streamConfig.host = _textFieldHost.stringValue;
    _streamConfig.appID = [_sortedAppList[_popupButtonSelection.indexOfSelectedItem] id];
    
    CGRefreshRate refreshRate = CGDisplayModeGetRefreshRate(CGDisplayCopyDisplayMode(kCGDirectMainDisplay));
    _streamConfig.clientRefreshRateX100 = (int)refreshRate * 100;
    [self transitionToStreamView];
}

- (IBAction)textFieldAction:(id)sender {
    [self buttonConnectPressed:self];
}

- (IBAction)buttonConnectPressed:(id)sender {
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
            HttpManager* hMan = [[HttpManager alloc] initWithHost:self->_host uniqueId:self->_uniqueId deviceName:deviceName cert:self->_cert];
            PairManager* pMan = [[PairManager alloc] initWithManager:hMan   andCert:self->_cert callback:self];
            [self->_opQueue addOperation:pMan];
    });
    }
}

- (IBAction)buttonSettingsPressed:(id)sender {
    showSettings = !showSettings;
    if(showSettings) {
        _layoutConstraintSetupFrame.constant = settingsFrameHeight;
    }
    else {
        _layoutConstraintSetupFrame.constant = 0;
    }
}

- (IBAction)popupButtonSelectionPressed:(id)sender {
}

- (void)alreadyPaired {
    [_popupButtonSelection setEnabled:true];
    [_popupButtonSelection setHidden:false];
    [_buttonConnect setEnabled:false];
    [_buttonConnect setHidden:true];
    [_buttonLaunch setEnabled:true];
    [_textFieldHost setEnabled:false];
    [_buttonEditHost setEnabled:true];
    [self searchForHost:_host];
    [self updateAppsForHost];
    [self populatePopupButton];
}

- (IBAction)buttonEditHostClicked:(id)sender {
    [_popupButtonSelection removeAllItems];
    [_popupButtonSelection setEnabled:false];
    [_popupButtonSelection setHidden:true];
    [_buttonConnect setEnabled:true];
    [_buttonConnect setHidden:false];
    [_buttonLaunch setEnabled:false];
    [_textFieldHost setEnabled:true];
    [_buttonEditHost setEnabled:false];
    [self.view.window makeFirstResponder:_textFieldHost];
}


- (void)searchForHost:(NSString*) hostAddress {
    HttpManager* hMan = [[HttpManager alloc] initWithHost:_textFieldHost.stringValue
                                                 uniqueId:_uniqueId
                                               deviceName:@"roth"
                                                     cert:_cert];
    AppListResponse* appListResp;
    for (int i = 0; i < 5; i++) {
        appListResp = [[AppListResponse alloc] init];
        [hMan executeRequestSynchronously:[HttpRequest requestForResponse:appListResp withUrlRequest:[hMan newAppListRequest]]];
        if (appListResp == nil || ![appListResp isStatusOk] || [appListResp getAppList] == nil) {
            [NSThread sleepForTimeInterval:1];
        }
        else {
            _appList = appListResp.getAppList;
            break;
        }
    }
}

- (void)populatePopupButton {
    for (int i = 0; i < _appList.count; i++) {
        [_popupButtonSelection addItemWithTitle:[_sortedAppList[i] name]];
    }
}

- (void)pairFailed:(NSString *)message {
    [self showAlert:[NSString stringWithFormat: @"%@", message]];
}

- (void)pairSuccessful {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view.window endSheet:self->_alert.window];
        self->_alert = nil;
        [self alreadyPaired];
    });
}

- (void)showPIN:(NSString *)PIN {
    [self showAlert:[NSString stringWithFormat: @"PIN: %@", PIN]];
}

- (void) updateAppsForHost {
    _sortedAppList = [_appList allObjects];
    _sortedAppList = [_sortedAppList sortedArrayUsingSelector:@selector(compareName:)];
}

- (void)transitionToStreamView {
    NSStoryboard *storyBoard = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
    StreamFrameViewController* streamFrame = (StreamFrameViewController*)[storyBoard instantiateControllerWithIdentifier :@"streamFrameVC"];
    streamFrame.streamConfig = _streamConfig;
    [streamFrame setOrigin:self];
    self.view.window.contentViewController = streamFrame;
}

@end
