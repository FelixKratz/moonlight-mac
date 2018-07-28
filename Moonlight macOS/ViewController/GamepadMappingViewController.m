//
//  GamepadMappingViewController.m
//  Moonlight macOS
//
//  Created by Felix Kratz on 29.07.18.
//  Copyright © 2018 Felix Kratz. All rights reserved.
//

#import "GamepadMappingViewController.h"

@interface GamepadMappingViewController ()
@end

@implementation GamepadMappingViewController {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    Gamepad_detectDevices();
    Gamepad_init();
    [self updateControllerList];
    
    // Do view setup here.
}

- (void)updateControllerList {
    [_popUpButtonControllerSelectionOutlet removeAllItems];
    for (int i = 0; i < Gamepad_numDevices(); i++) {
        [_popUpButtonControllerSelectionOutlet addItemWithTitle:[NSString stringWithUTF8String:Gamepad_deviceAtIndex(i)->description]];
    }
    if (Gamepad_numDevices() == 0)
        [_popUpButtonControllerSelectionOutlet addItemWithTitle:@"No Gamepad detected!"];
}

- (void)viewWillAppear {
    [super viewWillAppear];
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"AppleInterfaceStyle"]  isEqual: @"Dark"]) {
        [self.view.window setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameVibrantDark]];
    }
}
- (IBAction)popUpControllerSelectionSelected:(id)sender {
}
@end
