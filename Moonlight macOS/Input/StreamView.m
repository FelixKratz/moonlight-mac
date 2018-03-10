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

@implementation StreamView {
    BOOL isDragging;
    
    NSTrackingArea *trackingArea;
}

- (void) updateTrackingAreas {
    if (trackingArea != nil) {
        [self removeTrackingArea:trackingArea];
    }
    NSTrackingAreaOptions options = (NSTrackingActiveAlways | NSTrackingInVisibleRect |
                                     NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved);
    
    trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds]
                                                        options:options
                                                          owner:self
                                                       userInfo:nil];
    [self addTrackingArea:trackingArea];
}

- (void)mouseDown:(NSEvent *)mouseEvent {
    NSLog(@"LeftMouseDown");
    LiSendMouseButtonEvent(BUTTON_ACTION_PRESS, BUTTON_LEFT);
    [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)mouseEvent {
    LiSendMouseButtonEvent(BUTTON_ACTION_RELEASE, BUTTON_LEFT);
    [self setNeedsDisplay:YES];
}

- (void)rightMouseUp:(NSEvent *)mouseEvent {
    LiSendMouseButtonEvent(BUTTON_ACTION_RELEASE, BUTTON_RIGHT);
    [self setNeedsDisplay:YES];
}

- (void)rightMouseDown:(NSEvent *)mouseEvent {
    NSLog(@"RightMouseDown");
    LiSendMouseButtonEvent(BUTTON_ACTION_PRESS, BUTTON_RIGHT);
    [self setNeedsDisplay:YES];
}

- (void)mouseMoved:(NSEvent *)mouseEvent {
    LiSendMouseMoveEvent(mouseEvent.deltaX, mouseEvent.deltaY);
}

-(void)keyDown:(NSEvent *)event
{
    char keyCode = keyCharFromKeyCode(event.keyCode);
    LiSendKeyboardEvent(keyCode, KEY_ACTION_DOWN, 0x00);
}

-(void)keyUp:(NSEvent *)event
{
    char keyCode = keyCharFromKeyCode(event.keyCode);

    LiSendKeyboardEvent(keyCode, KEY_ACTION_UP, 0x00);
}

- (BOOL)acceptsFirstResponder {
    return YES;
}
@end
