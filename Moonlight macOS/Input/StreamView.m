//
//  StreamView.m
//  Moonlight macOS
//
//  Created by Felix Kratz on 10.3.18.
//  Copyright (c) 2018 Felix Kratz. All rights reserved.
//

#import "StreamView.h"
#include <Limelight.h>
#import "DataManager.h"
#import <AppKit/AppKit.h>
#include <ApplicationServices/ApplicationServices.h>
#include "keyboardTranslation.h"
#import "NetworkTraffic.h"

@implementation StreamView {
    bool isDragging;
    bool statsDisplayed;
    unsigned long lastNetworkDown;
    unsigned long lastNetworkUp;
    NSTrackingArea* _trackingArea;
    NSTextField* _textFieldIncomingBitrate;
    NSTextField* _textFieldOutgoingBitrate;
    NSTextField* _textFieldCodec;
    NSTextField* _stageLabel;
    NSTimer* _statTimer;
}

- (void) updateTrackingAreas {
    if (_trackingArea != nil) {
        [self removeTrackingArea:_trackingArea];
    }
    NSTrackingAreaOptions options = (NSTrackingActiveAlways | NSTrackingInVisibleRect |
                                     NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved);
    
    _trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds]
                                                        options:options
                                                          owner:self
                                                       userInfo:nil];
    [self addTrackingArea:_trackingArea];
}

-(void)mouseDragged:(NSEvent *)event {
    if (isDragging) {
        [self mouseMoved:event];
    }
    else {
        [self mouseDown:event];
        isDragging = true;
    }
}

-(void)rightMouseDragged:(NSEvent *)event
{
    if (isDragging) {
        [self mouseMoved:event];
    }
    else {
        [self rightMouseDown:event];
        isDragging = true;
    }
}

-(void)scrollWheel:(NSEvent *)event {
    LiSendScrollEvent(event.scrollingDeltaY);
}

- (void)mouseDown:(NSEvent *)mouseEvent {
    LiSendMouseButtonEvent(BUTTON_ACTION_PRESS, BUTTON_LEFT);
    [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)mouseEvent {
    isDragging = false;
    LiSendMouseButtonEvent(BUTTON_ACTION_RELEASE, BUTTON_LEFT);
    [self setNeedsDisplay:YES];
}

- (void)rightMouseUp:(NSEvent *)mouseEvent {
    isDragging = false;
    LiSendMouseButtonEvent(BUTTON_ACTION_RELEASE, BUTTON_RIGHT);
    [self setNeedsDisplay:YES];
}

- (void)rightMouseDown:(NSEvent *)mouseEvent {
    LiSendMouseButtonEvent(BUTTON_ACTION_PRESS, BUTTON_RIGHT);
    [self setNeedsDisplay:YES];
}

- (void)mouseMoved:(NSEvent *)mouseEvent {
    LiSendMouseMoveEvent(mouseEvent.deltaX, mouseEvent.deltaY);
}

-(void)keyDown:(NSEvent *)event {
    int keyChar = keyCharFromKeyCode(event.keyCode);
    NSLog(@"DOWN: KeyCode: %hu, keyChar: %d, keyModifier: %lu \n", event.keyCode, keyChar, event.modifierFlags);
    
    LiSendKeyboardEvent(keyChar, KEY_ACTION_DOWN, modifierFlagForKeyModifier(event.modifierFlags));
    if (event.modifierFlags & kCGEventFlagMaskCommand && event.keyCode == kVK_ANSI_I) {
        [self toggleStats];
    }
}

-(void)keyUp:(NSEvent *)event {
    short keyChar = keyCharFromKeyCode(event.keyCode);
    NSLog(@"UP: KeyChar: %d \n‚", keyChar);
    LiSendKeyboardEvent(keyChar, KEY_ACTION_UP, modifierFlagForKeyModifier(event.modifierFlags));
}

- (void)flagsChanged:(NSEvent *)event
{
    short keyChar = keyCodeFromModifierKey(event.modifierFlags);
    if(keyChar)
    {
        printf("DOWN: FlagChanged: %hd \n", keyChar);
        LiSendKeyboardEvent(keyChar, KEY_ACTION_DOWN, 0x00);
    }
    else
    {
        LiSendKeyboardEvent(58, KEY_ACTION_UP, 0x00);
    }
}

- (void)setupTextField:(NSTextField*)textField {
    textField.drawsBackground = false;
    textField.bordered = false;
    textField.enabled = false;
    textField.alignment = NSTextAlignmentLeft;
    textField.textColor = [NSColor magentaColor];
}

- (void)initStats {
    _textFieldCodec = [[NSTextField alloc] initWithFrame:NSMakeRect(10, 30, 200, 17)];
    _textFieldIncomingBitrate = [[NSTextField alloc] initWithFrame:NSMakeRect(10, 10, 250, 17)];
    _textFieldOutgoingBitrate = [[NSTextField alloc] initWithFrame:NSMakeRect(10 + 250, 10, 250, 17)];
    
    [self setupTextField:_textFieldOutgoingBitrate];
    [self setupTextField:_textFieldIncomingBitrate];
    [self setupTextField:_textFieldCodec];
    
    [self addSubview:_textFieldCodec];
    [self addSubview:_textFieldIncomingBitrate];
    [self addSubview:_textFieldOutgoingBitrate];
}

- (void)initStageLabel {
    _stageLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(NSScreen.mainScreen.frame.size.width/2 - 100, NSScreen.mainScreen.frame.size.height/2 - 8, 200, 17)];
    _stageLabel.drawsBackground = false;
    _stageLabel.bordered = false;
    _stageLabel.alignment = NSTextAlignmentCenter;
    _stageLabel.textColor = [NSColor blackColor];
    
    [self addSubview:_stageLabel];
}

- (void)statTimerTick {
    NSLog(@"HI!");
    unsigned long currentNetworkDown = getBytesDown();
    _textFieldIncomingBitrate.stringValue = [NSString stringWithFormat:@"Incoming Bitrate (System): %lu kbps", (currentNetworkDown - lastNetworkDown)*8 / 1000];
    lastNetworkDown = currentNetworkDown;
    
    unsigned long currentNetworkUp = getBytesUp();
    _textFieldOutgoingBitrate.stringValue = [NSString stringWithFormat:@"Outgoing Bitrate (System): %lu kbps", (currentNetworkUp - lastNetworkUp)*8 / 1000];
    lastNetworkUp = currentNetworkUp;
}

- (void)toggleStats {
    statsDisplayed = !statsDisplayed;
    if (statsDisplayed) {
        _statTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(statTimerTick) userInfo:nil repeats:true];
        NSLog(@"display stats");
        if (_textFieldIncomingBitrate == nil || _textFieldCodec == nil || _textFieldOutgoingBitrate == nil) {
            [self initStats];
        }
        _textFieldCodec.stringValue = [NSString stringWithFormat:@"Codec: H%i", _codec];
        _textFieldIncomingBitrate.stringValue = @"Incoming Bitrate (System): ";
        _textFieldOutgoingBitrate.stringValue = @"Outgoing Bitrate (System): ";
    }
    else    {
        [_statTimer invalidate];
        _textFieldCodec.stringValue = @"";
        _textFieldIncomingBitrate.stringValue = @"";
        _textFieldOutgoingBitrate.stringValue = @"";
    }
}

- (void)drawMessage:(NSString*)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_stageLabel == nil) {
            [self initStageLabel];
        }
        _stageLabel.stringValue = message;
    });
}

- (BOOL)acceptsFirstResponder {
    return YES;
}
@end
