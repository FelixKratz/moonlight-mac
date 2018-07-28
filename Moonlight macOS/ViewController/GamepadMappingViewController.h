//
//  GamepadMappingViewController.h
//  Moonlight macOS
//
//  Created by Felix on 29.07.18.
//  Copyright © 2018 Felix. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Gamepad.h"

@interface GamepadMappingViewController : NSViewController
@property (weak) IBOutlet NSPopUpButton *popUpButtonControllerSelectionOutlet;
- (IBAction)popUpControllerSelectionSelected:(id)sender;

@end
