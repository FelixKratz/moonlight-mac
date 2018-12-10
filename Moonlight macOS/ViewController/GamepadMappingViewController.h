//
//  GamepadMappingViewController.h
//  Moonlight macOS
//
//  Created by Felix on 29.07.18.
//  Copyright © 2018 Felix. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import "Gamepad.h"
#include "Gamepad.h"

@interface GamepadMappingViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate>
@property (weak) IBOutlet NSPopUpButton *popUpButtonControllerSelectionOutlet;
- (IBAction)popUpControllerSelectionSelected:(id)sender;
@property (weak) IBOutlet NSTableView *availableKeysTableViewOutlet;
-(void) didPressButton: (NSInteger) buttonID;
@property (weak) IBOutlet NSTextField *LB;
@property (weak) IBOutlet NSTextField *RB;
@property (weak) IBOutlet NSTextField *U;
@property (weak) IBOutlet NSTextField *R;
@property (weak) IBOutlet NSTextField *L;
@property (weak) IBOutlet NSTextField *D;
@property (weak) IBOutlet NSTextField *L3;
@property (weak) IBOutlet NSTextField *R3;
@property (weak) IBOutlet NSTextField *A;
@property (weak) IBOutlet NSTextField *B;
@property (weak) IBOutlet NSTextField *Y;
@property (weak) IBOutlet NSTextField *X;
@property (weak) IBOutlet NSTextField *START;
@property (weak) IBOutlet NSTextField *SELECT;
@property (weak) IBOutlet NSTextField *LX;
@property (weak) IBOutlet NSTextField *LY;
@property (weak) IBOutlet NSTextField *RX;
@property (weak) IBOutlet NSTextField *RY;
@property (weak) IBOutlet NSTextField *LT;
@property (weak) IBOutlet NSTextField *RT;

- (IBAction)buttonSave:(id)sender;

@property (weak) IBOutlet NSButton *LX_inv;
@property (weak) IBOutlet NSButton *LY_inv;
@property (weak) IBOutlet NSButton *RX_inv;
@property (weak) IBOutlet NSButton *RY_inv;

@end
