//
//  ControllerSupport.m
//  Moonlight macOS
//
//  Created by Felix Kratz on 15.03.18.
//  Copyright © 2018 Felix Kratz. All rights reserved.
//

#import "ControllerSupport.h"
#import "DataManager.h"
#import "Control.h"

#include "Limelight.h"

#define NO_MAP 0xFFFFFF

@class Controller;

@implementation ControllerSupport {
    NSLock *_controllerStreamLock;
    NSMutableDictionary *_controllers;
    char _controllerNumbers;
    NSTimer* _eventTimer;
    NSTimer* _searchTimer;
    int key[26];
}

-(void) updateButtonFlags:(Controller*)controller flags:(int)flags
{
    @synchronized(controller) {
        controller.lastButtonFlags = flags;
    }
}

-(void) setButtonFlag:(Controller*)controller flags:(int)flags
{
    @synchronized(controller) {
        controller.lastButtonFlags |= flags;
    }
}

-(void) clearButtonFlag:(Controller*)controller flags:(int)flags
{
    @synchronized(controller) {
        controller.lastButtonFlags &= ~flags;
    }
}

-(void) updateFinished:(Controller*)controller
{
    [_controllerStreamLock lock];
    @synchronized(controller) {
        LiSendMultiControllerEvent(controller.playerIndex, _controllerNumbers, controller.lastButtonFlags, controller.lastLeftTrigger, controller.lastRightTrigger, controller.lastLeftStickX, controller.lastLeftStickY, controller.lastRightStickX, controller.lastRightStickY);
    }
    [_controllerStreamLock unlock];
}

-(NSMutableDictionary*) getControllers {
    return _controllers;
}

-(void) assignGamepad:(struct Gamepad_device *)gamepad {
    for (int i = 0; i < 4; i++) {
        if (!(_controllerNumbers & (1 << i))) {
            _controllerNumbers |= (1 << i);
            gamepad->deviceID = i;
            NSLog(@"Gamepad device id: %u assigned", gamepad->deviceID);
            Controller* limeController;
            limeController = [[Controller alloc] init];
            limeController.playerIndex = i;
            
            [_controllers setObject:limeController forKey:[NSNumber numberWithInteger:i]];
            break;
        }
    }
}

-(void) removeGamepad:(struct Gamepad_device *)gamepad {
    _controllerNumbers &= ~(1 << gamepad->deviceID);
    
    [self updateFinished:[_controllers objectForKey:[NSNumber numberWithInteger:gamepad->deviceID]]];
    [_controllers removeObjectForKey:[NSNumber numberWithInteger:gamepad->deviceID]];
}


-(void) eventTimerTick {
    Gamepad_processEvents();
}

-(void) searchTimerTick {
    Gamepad_detectDevices();
}


-(id) init
{
    self = [super init];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    _keys = key;
    NSData *data = [defaults objectForKey:@"keys"];
    if (data != nil)
    {
        memcpy(_keys, data.bytes, data.length);
    }
    else
    {
        // DualShock 4 Mapping
        _keys[0] = 4;
        _keys[1] = 5;
        _keys[2] = NO_MAP;
        _keys[3] = NO_MAP;
        _keys[4] = NO_MAP;
        _keys[5] = NO_MAP;
        _keys[6] = 10;
        _keys[7] = 11;
        _keys[8] = 1;
        _keys[9] = 2;
        _keys[10] = 3;
        _keys[11] = 0;
        _keys[12] = 9;
        _keys[13] = 8;
        _keys[14] = 0;
        _keys[15] = 1;
        _keys[16] = 2;
        _keys[17] = 3;
        _keys[18] = 6;
        _keys[19] = 7;
        _keys[20] = 0;
        _keys[21] = 0;
        _keys[22] = 0;
        _keys[23] = 0;
        _keys[24] = 5;
        _keys[25] = 4;
    }
    _controllerStreamLock = [[NSLock alloc] init];
    _controllers = [[NSMutableDictionary alloc] init];
    _controllerNumbers = 0;
    
    initGamepad(self);
    Gamepad_detectDevices();
    
    // The gamepad currently gets polled at 30Hz.
    _eventTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/30.0 target:self selector:@selector(eventTimerTick) userInfo:nil repeats:true];
    
    // We search for new devices every 5 seconds.
    _searchTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(searchTimerTick) userInfo:nil repeats:true];
    return self;
}

@end
