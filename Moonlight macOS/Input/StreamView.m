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
#include <ApplicationServices/ApplicationServices.h>
#include "keyboardTranslation.h"
#import "OverlayView.h"
#import "StreamFrameViewController.h"

@implementation StreamView {
    bool isDragging;
    double delta_x;
    double delta_y;
    NSTrackingArea* _trackingArea;
    NSTextField* _stageLabel;
    OverlayView* _overlay;
    
    NSTimer* _mouseBatchTimer;
}

- (void) updateTrackingAreas {
    if (_trackingArea != nil)
        [self removeTrackingArea:_trackingArea];
    NSTrackingAreaOptions options = (NSTrackingActiveAlways | NSTrackingInVisibleRect |
                                     NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved);
    
    _trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds]
                                                        options:options
                                                          owner:self
                                                       userInfo:nil];
    [self addTrackingArea:_trackingArea];
}

-(void)mouseDragged:(NSEvent *)event {
    if (isDragging)
        [self mouseMoved:event];
    else {
        [self mouseDown:event];
        isDragging = true;
    }
}

-(void)rightMouseDragged:(NSEvent *)event {
    if (isDragging)
        [self mouseMoved:event];
    else {
        [self rightMouseDown:event];
        isDragging = true;
    }
}

-(void)otherMouseDragged:(NSEvent *)event {
    if (isDragging)
        [self mouseMoved:event];
    else {
        [self otherMouseDown:event];
        isDragging = true;
    }
}

-(void)scrollWheel:(NSEvent *)event {
    LiSendScrollEvent(event.scrollingDeltaY);
}

- (void)mouseDown:(NSEvent *)mouseEvent {
    LiSendMouseButtonEvent(BUTTON_ACTION_PRESS, BUTTON_LEFT);
}

- (void)otherMouseDown:(NSEvent *)event {
    LiSendMouseButtonEvent(BUTTON_ACTION_PRESS, BUTTON_MIDDLE);
}

- (void)otherMouseUp:(NSEvent *)event {
    isDragging = false;
    LiSendMouseButtonEvent(BUTTON_ACTION_RELEASE, BUTTON_MIDDLE);
}

- (void)mouseUp:(NSEvent *)mouseEvent {
    isDragging = false;
    LiSendMouseButtonEvent(BUTTON_ACTION_RELEASE, BUTTON_LEFT);
}

- (void)rightMouseUp:(NSEvent *)mouseEvent {
    isDragging = false;
    LiSendMouseButtonEvent(BUTTON_ACTION_RELEASE, BUTTON_RIGHT);
}

- (void)rightMouseDown:(NSEvent *)mouseEvent {
    LiSendMouseButtonEvent(BUTTON_ACTION_PRESS, BUTTON_RIGHT);
}

- (void)mouseMoved:(NSEvent *)mouseEvent {
    if (_mouseBatchTimer == nil)
        _mouseBatchTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0 target:self selector:@selector(mouseBatchTimerTick) userInfo:nil repeats:true];
    delta_x += mouseEvent.deltaX;
    delta_y += mouseEvent.deltaY;
}

-(void)mouseBatchTimerTick {
    LiSendMouseMoveEvent(delta_x, delta_y);
    delta_x = 0;
    delta_y = 0;
}

-(void)keyDown:(NSEvent *)event {
    unsigned char keyChar = keyCharFromKeyCode(event.keyCode);
    NSLog(@"DOWN: KeyCode: %hu, keyChar: %d, keyModifier: %lu \n", event.keyCode, keyChar, event.modifierFlags);
    
    LiSendKeyboardEvent(keyChar, KEY_ACTION_DOWN, modifierFlagForKeyModifier(event.modifierFlags));
    
    // Special key combo's for the client
    
    // Toggle the overlay: CMD + I
    if (event.modifierFlags & kCGEventFlagMaskCommand && event.keyCode == kVK_ANSI_I) {
        [self toggleStats];
    }
    
    // Kill the active connection: ALT + ESC
    if (event.modifierFlags & kCGEventFlagMaskAlternate && event.keyCode == kVK_Escape) {
        [self killConnection];
    }
}

-(void)keyUp:(NSEvent *)event {
    unsigned char keyChar = keyCharFromKeyCode(event.keyCode);
    NSLog(@"UP: KeyChar: %d \n‚", keyChar);
    LiSendKeyboardEvent(keyChar, KEY_ACTION_UP, modifierFlagForKeyModifier(event.modifierFlags));
}

- (void)flagsChanged:(NSEvent *)event {
    unsigned char keyChar = keyCodeFromModifierKey(event.modifierFlags);
    if(keyChar) {
        NSLog(@"DOWN: FlagChanged: %hhu \n", keyChar);
        LiSendKeyboardEvent(keyChar, KEY_ACTION_DOWN, 0x00);
    }
    else {
        LiSendKeyboardEvent(58, KEY_ACTION_UP, 0x00);
    }
}

- (void)killConnection {
    StreamFrameViewController* streamFrameViewController = (StreamFrameViewController*)self.window.contentViewController;
    [streamFrameViewController connectionTerminated:TerminationUser];
}

- (void)initStageLabel {
    _stageLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(NSScreen.mainScreen.frame.size.width/2 - 100, NSScreen.mainScreen.frame.size.height/2 - 8, 200, 17)];
    _stageLabel.drawsBackground = false;
    _stageLabel.bordered = false;
    _stageLabel.alignment = NSTextAlignmentCenter;
    _stageLabel.textColor = [NSColor blackColor];
    
    [self addSubview:_stageLabel];
}

- (void)toggleStats {
    if (_overlay == nil) {
        _overlay = [[OverlayView alloc] initWithFrame:self.frame sender:self];
        [self addSubview:_overlay];
    }
    [_overlay toggleOverlay:_codec];
}

- (void)drawMessage:(NSString*)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self->_stageLabel == nil) {
            [self initStageLabel];
        }
        self->_stageLabel.stringValue = message;
    });
}

- (BOOL)acceptsFirstResponder {
    return YES;
}
@end
