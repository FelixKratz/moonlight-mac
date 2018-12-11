//
//  Control.m
//  Moonlight macOS
//
//  Created by Felix Kratz on 15.03.18.
//  Copyright © 2018 Felix Kratz. All rights reserved.
//


#include "Gamepad.h"
#include "Control.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include "Limelight.h"

@class Controller;

#ifdef _MSC_VER
#define snprintf _snprintf
#endif


Controller* _controller;
ControllerSupport* _controllerSupport;
NSMutableDictionary* _controllers;

typedef enum {
    LB = 0,
    RB,
    U,
    R,
    L,
    D,
    L3,
    R3,
    A,
    B,
    Y,
    X,
    START,
    SELECT,
    LX,
    LY,
    RX,
    RY,
    LT,
    RT,
    LX_inv,
    LY_inv,
    RX_inv,
    RY_inv,
} ControllerKeys;


void onButtonDown(struct Gamepad_device * device, unsigned int buttonID, double timestamp, void * context) {
    _controller = [_controllers objectForKey:[NSNumber numberWithInteger:device->deviceID]];
    if (buttonID == _controllerSupport.keys[SELECT])
            [_controllerSupport setButtonFlag:_controller flags:BACK_FLAG];
    if (buttonID == _controllerSupport.keys[L3])
            [_controllerSupport setButtonFlag:_controller flags:LS_CLK_FLAG];
    
    if (buttonID == _controllerSupport.keys[R3])
            [_controllerSupport setButtonFlag:_controller flags:RS_CLK_FLAG];
    if (buttonID == _controllerSupport.keys[START])
            [_controllerSupport setButtonFlag:_controller flags:PLAY_FLAG];
    if (buttonID == _controllerSupport.keys[U])
            [_controllerSupport setButtonFlag:_controller flags:UP_FLAG];
    if (buttonID == _controllerSupport.keys[R])
            [_controllerSupport setButtonFlag:_controller flags:RIGHT_FLAG];
    if (buttonID == _controllerSupport.keys[D])
            [_controllerSupport setButtonFlag:_controller flags:DOWN_FLAG];
    if (buttonID == _controllerSupport.keys[L])
            [_controllerSupport setButtonFlag:_controller flags:LEFT_FLAG];
    if (buttonID == _controllerSupport.keys[LB])
            [_controllerSupport setButtonFlag:_controller flags:LB_FLAG];
   if (buttonID == _controllerSupport.keys[RB])
            [_controllerSupport setButtonFlag:_controller flags:RB_FLAG];
   if (buttonID == _controllerSupport.keys[Y])
            [_controllerSupport setButtonFlag:_controller flags:Y_FLAG];
   if (buttonID == _controllerSupport.keys[B])
            [_controllerSupport setButtonFlag:_controller flags:B_FLAG];
   if (buttonID == _controllerSupport.keys[A])
            [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
  if (buttonID == _controllerSupport.keys[X])
            [_controllerSupport setButtonFlag:_controller flags:X_FLAG];
    [_controllerSupport updateFinished:_controller];
}

void onButtonUp(struct Gamepad_device * device, unsigned int buttonID, double timestamp, void * context) {
    _controller = [_controllers objectForKey:[NSNumber numberWithInteger:device->deviceID]];
        if (buttonID == _controllerSupport.keys[SELECT])
            [_controllerSupport clearButtonFlag:_controller flags:BACK_FLAG];
       if (buttonID == _controllerSupport.keys[L3])
            [_controllerSupport clearButtonFlag:_controller flags:LS_CLK_FLAG];
       if (buttonID == _controllerSupport.keys[R3])
            [_controllerSupport clearButtonFlag:_controller flags:RS_CLK_FLAG];
       if (buttonID == _controllerSupport.keys[START])
            [_controllerSupport clearButtonFlag:_controller flags:PLAY_FLAG];
       if (buttonID == _controllerSupport.keys[U])
            [_controllerSupport clearButtonFlag:_controller flags:UP_FLAG];
       if (buttonID == _controllerSupport.keys[R])
            [_controllerSupport clearButtonFlag:_controller flags:RIGHT_FLAG];
       if (buttonID == _controllerSupport.keys[D])
            [_controllerSupport clearButtonFlag:_controller flags:DOWN_FLAG];
       if (buttonID == _controllerSupport.keys[L])
            [_controllerSupport clearButtonFlag:_controller flags:LEFT_FLAG];
       if (buttonID == _controllerSupport.keys[LB])
            [_controllerSupport clearButtonFlag:_controller flags:LB_FLAG];
       if (buttonID == _controllerSupport.keys[RB])
            [_controllerSupport clearButtonFlag:_controller flags:RB_FLAG];
       if (buttonID == _controllerSupport.keys[Y])
            [_controllerSupport clearButtonFlag:_controller flags:Y_FLAG];
        if (buttonID == _controllerSupport.keys[B])
            [_controllerSupport clearButtonFlag:_controller flags:B_FLAG];
       if (buttonID == _controllerSupport.keys[A])
            [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
       if (buttonID == _controllerSupport.keys[X])
            [_controllerSupport clearButtonFlag:_controller flags:X_FLAG];
    [_controllerSupport updateFinished:_controller];
}

void onAxisMoved(struct Gamepad_device * device, unsigned int axisID, float value, float lastValue, double timestamp, void * context) {
    if (fabsf(lastValue - value) > 0.01) {
        _controller = [_controllers objectForKey:[NSNumber numberWithInteger:device->deviceID]];
        // The dualshock controller has much more than these axis because of the motion axis, so it
        // is better to call the updateFinished in the cases, because otherwise all of these
        // motion axis will also trigger an updateFinished event.
        if (axisID == _controllerSupport.keys[LX])
        {
                _controller.lastLeftStickX = value * 0X7FFE;
                [_controllerSupport updateFinished:_controller];
            return;
        }
        if (axisID == _controllerSupport.keys[LY])
        {
                _controller.lastLeftStickY = -value * 0X7FFE;
                [_controllerSupport updateFinished:_controller];
            return;
        }
        if (axisID == _controllerSupport.keys[RX])
        {
                _controller.lastRightStickX = value * 0X7FFE;
                [_controllerSupport updateFinished:_controller];
            return;
        }
        if (axisID == _controllerSupport.keys[RY])
        {
                _controller.lastRightStickY = -value * 0X7FFE;
                [_controllerSupport updateFinished:_controller];
            return;
        }
        if (axisID == _controllerSupport.keys[LT])
        {
                _controller.lastLeftTrigger = value * 0xFF;
                [_controllerSupport updateFinished:_controller];
            return;
        }
        if (axisID == _controllerSupport.keys[RT])
        {
                _controller.lastRightTrigger = value * 0xFF;
                [_controllerSupport updateFinished:_controller];
                return;
        }
    }
}

void onDeviceAttached(struct Gamepad_device * device, void * context) {
    [_controllerSupport assignGamepad:device];
    _controllers = [_controllerSupport getControllers];
}

void onDeviceRemoved(struct Gamepad_device * device, void * context) {
    [_controllerSupport removeGamepad:device];
    _controllers = [_controllerSupport getControllers];
}

void initGamepad(ControllerSupport* controllerSupport) {
    _controllerSupport = controllerSupport;
    _controller = [[Controller alloc] init];
    Gamepad_deviceAttachFunc(onDeviceAttached, NULL);
    Gamepad_deviceRemoveFunc(onDeviceRemoved, NULL);
    Gamepad_buttonDownFunc(onButtonDown, NULL);
    Gamepad_buttonUpFunc(onButtonUp, NULL);
    Gamepad_axisMoveFunc(onAxisMoved, NULL);
    Gamepad_init();
}

