//
//  StreamFrameViewController.m
//  Moonlight macOS
//
//  Created by Felix Kratz on 09.03.18.
//  Copyright © 2018 Felix Kratz. All rights reserved.
//

#import "StreamFrameViewController.h"
#import "ViewController.h"
#import "VideoDecoderRenderer.h"
#import "StreamManager.h"

#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

@interface StreamFrameViewController ()
@end

@implementation StreamFrameViewController {
    StreamManager *_streamMan;
    StreamConfiguration *_streamConfig;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.streamConfig = _streamConfig;
    _streamMan = [[StreamManager alloc] initWithConfig:self.streamConfig
                                            renderView:self.view
                                   connectionCallbacks:self];
    NSOperationQueue* opQueue = [[NSOperationQueue alloc] init];
    [opQueue addOperation:_streamMan];
    
    // Do view setup here.
}

- (void) viewDidAppear {
    [NSCursor hide];
    CGAssociateMouseAndMouseCursorPosition (false);
    CGWarpMouseCursorPosition(CGPointMake( self.view.frame.origin.x + self.view.frame.size.width/2 , self.view.frame.origin.y + self.view.frame.size.height/2));
    if (self.view.bounds.size.height != NSScreen.mainScreen.frame.size.height || self.view.bounds.size.width != NSScreen.mainScreen.frame.size.width)
    {
        [self.view.window toggleFullScreen:self];
    }
}

- (void)connectionStarted {
    
}

- (void)connectionTerminated:(long)errorCode {
    
}

- (void)displayMessage:(const char *)message {
    
}

- (void)displayTransientMessage:(const char *)message {
    
}

- (void)launchFailed:(NSString *)message {
    
}

- (void)stageComplete:(const char *)stageName {
    
}

- (void)stageFailed:(const char *)stageName withError:(long)errorCode {
    
}

- (void)stageStarting:(const char *)stageName {
    
}

@end
