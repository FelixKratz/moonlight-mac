//
//  StreamFrameViewController.m
//  Moonlight macOS
//
//  Created by Felix Kratz on 09.03.18.
//  Copyright © 2018 Felix Kratz. All rights reserved.
//

#import "StreamFrameViewController.h"
#import "VideoDecoderRenderer.h"
#import "StreamManager.h"
#import "Control.h"
#import "Gamepad.h"
#import "keepAlive.h"
#import "StreamView.h"

@interface StreamFrameViewController ()
@end

@implementation StreamFrameViewController {
    StreamManager *_streamMan;
    StreamConfiguration *_streamConfig;
    ViewController* _origin;
    ControllerSupport* _controllerSupport;
}

-(ViewController*) _origin {
    return _origin;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [keepAlive keepSystemAlive];
    self.streamConfig = _streamConfig;
   
    _streamMan = [[StreamManager alloc] initWithConfig:self.streamConfig
                                            renderView:self.view
                                   connectionCallbacks:self];
    NSOperationQueue* opQueue = [[NSOperationQueue alloc] init];
    [opQueue addOperation:_streamMan];
    
    _controllerSupport = [[ControllerSupport alloc] init];
}

- (void) viewDidAppear {
    [super viewDidAppear];
    [NSCursor hide];
    CGAssociateMouseAndMouseCursorPosition(false);
    //CGWarpMouseCursorPosition(CGPointMake(self.view.frame.origin.x + self.view.frame.size.width/2 , self.view.frame.origin.y + self.view.frame.size.height/2));

    [self.view.window setStyleMask:[self.view.window styleMask] | NSWindowStyleMaskResizable];
    if (self.view.bounds.size.height != NSScreen.mainScreen.frame.size.height || self.view.bounds.size.width != NSScreen.mainScreen.frame.size.width)
    {
        [self.view.window toggleFullScreen:self];
    }
    [_progressIndicator startAnimation:nil];
    [_origin dismissController:nil];
    _origin = nil;
}

-(void)viewWillDisappear {
    [NSCursor unhide];
    [keepAlive allowSleep];
    [_streamMan stopStream];
    CGAssociateMouseAndMouseCursorPosition(true);
    if (self.view.bounds.size.height == NSScreen.mainScreen.frame.size.height && self.view.bounds.size.width == NSScreen.mainScreen.frame.size.width)
    {
        [self.view.window toggleFullScreen:self];
        [self.view.window setStyleMask:[self.view.window styleMask] & ~NSWindowStyleMaskResizable];
    }
}

- (void)connectionStarted {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_progressIndicator stopAnimation:nil];
        self->_progressIndicator.hidden = true;
    });
    //[_streamView drawMessage:@"Waiting for the first frame"];
    
}

- (void)connectionTerminated:(long)errorCode {
    [_streamMan stopStream];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"error has occured: %ld", errorCode);
        NSStoryboard *storyBoard = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
        ViewController* view = (ViewController*)[storyBoard instantiateControllerWithIdentifier :@"setupFrameVC"];
        [view setError:1];
        self.view.window.contentViewController = view;
    });
}

- (void)setOrigin: (ViewController*) viewController
{
    _origin = viewController;
}

- (void)displayMessage:(const char *)message {
    //[_streamView drawMessage:[NSString stringWithFormat:@"%s", message]];
}

- (void)displayTransientMessage:(const char *)message {
   // [_streamView drawMessage:[NSString stringWithFormat:@"%s", message]];
}

- (void)launchFailed:(NSString *)message {
    //[_streamView drawMessage:message];
}

- (void)stageComplete:(const char *)stageName {
   // [_streamView drawMessage:@""];
}

- (void)stageFailed:(const char *)stageName withError:(long)errorCode {
   // [_streamView drawMessage:[NSString stringWithFormat:@"Stage: %s failed with code: %li", stageName, errorCode]];
}

- (void)stageStarting:(const char *)stageName {
    //[_streamView drawMessage:[NSString stringWithFormat:@"%s", stageName]];
}

@end
