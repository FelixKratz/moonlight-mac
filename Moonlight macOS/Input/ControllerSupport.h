//
//  ControllerSupport.h
//  Moonlight macOS
//
//  Created by Felix Kratz on 15.03.18.
//  Copyright © 2018 Felix Kratz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Controller.h"
#import "Gamepad.h"

@interface ControllerSupport : NSObject

-(id) init;

-(void) assignGamepad:(struct Gamepad_device *)gamepad;
-(void) removeGamepad:(struct Gamepad_device *)gamepad;
-(NSMutableDictionary*) getControllers;
-(void) updateButtonFlags:(Controller*)controller flags:(int)flags;
-(void) setButtonFlag:(Controller*)controller flags:(int)flags;
-(void) clearButtonFlag:(Controller*)controller flags:(int)flags;

-(void) updateFinished:(Controller*)controller;

@property int* keys;

@end
