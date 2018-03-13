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

    float scrollingDelta;
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
    scrollingDelta += event.scrollingDeltaY;
    if (scrollingDelta > 1)
    {
        LiSendScrollEvent(scrollingDelta);
        scrollingDelta -= 1;
    }
}

- (void)mouseDown:(NSEvent *)mouseEvent {
    NSLog(@"LeftMouseDown");
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
    NSLog(@"RightMouseDown");
    LiSendMouseButtonEvent(BUTTON_ACTION_PRESS, BUTTON_RIGHT);
    [self setNeedsDisplay:YES];
}

- (void)mouseMoved:(NSEvent *)mouseEvent {
    LiSendMouseMoveEvent(mouseEvent.deltaX, mouseEvent.deltaY);
}

-(void)keyDown:(NSEvent *)event {
    int keyChar = keyCharFromKeyCode(event.keyCode);
    printf("DOWN: KeyCode: %hu, keyChar: %d, keyModifier: %lu \n", event.keyCode, keyChar, event.modifierFlags);
    
    LiSendKeyboardEvent(keyChar, KEY_ACTION_DOWN, keyModifierFromEvent(event.modifierFlags));
}

-(void)keyUp:(NSEvent *)event {
    short keyChar = keyCharFromKeyCode(event.keyCode);
    printf("UP: KeyChar: %d \n‚", keyChar);
    LiSendKeyboardEvent(keyChar, KEY_ACTION_UP, keyModifierFromEvent(event.modifierFlags));
}

- (void)flagsChanged:(NSEvent *)event
{
    short keyChar = modifierKeyFromEvent(event.modifierFlags);
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

- (BOOL)acceptsFirstResponder {
    return YES;
}
@end
