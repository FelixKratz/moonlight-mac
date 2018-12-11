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
    initGamepad_Conf(self);
    [self updateControllerList];
    _availableKeysTableViewOutlet.delegate = self;
    _availableKeysTableViewOutlet.dataSource = self;
    _availableKeysTableViewOutlet.target = self;
    // Do view setup here.
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0/10.0 target:self selector:@selector(eventTimerTick) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}
- (void)viewDidAppear
{
    [super viewDidAppear];
}

- (void)viewDidDisappear
{
    [super viewDidDisappear];
}

-(void) eventTimerTick {
    Gamepad_processEvents();
}

-(void) didPressButton: (NSInteger) buttonID
{
    NSMutableIndexSet *mutableIndexSet = [[NSMutableIndexSet alloc] init];
    [mutableIndexSet addIndex:buttonID];
    [_availableKeysTableViewOutlet selectRowIndexes:mutableIndexSet byExtendingSelection:false];
}

-(void) didMoveAxis: (NSInteger) axisID
{
    NSMutableIndexSet *mutableIndexSet = [[NSMutableIndexSet alloc] init];
    [mutableIndexSet addIndex:axisID + Gamepad_deviceAtIndex(_popUpButtonControllerSelectionOutlet.selectedTag)->numButtons];
    [_availableKeysTableViewOutlet selectRowIndexes:mutableIndexSet byExtendingSelection:false];
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

- (IBAction)buttonSave:(id)sender
{
    int keys[24];
    keys[0] = _LB.intValue;
    keys[1] = _RB.intValue;
    keys[2] = _U.intValue;
    keys[3] = _R.intValue;
    keys[4] = _L.intValue;
    keys[5] = _D.intValue;
    keys[6] = _L3.intValue;
    keys[7] = _R3.intValue;
    keys[8] = _A.intValue;
    keys[9] = _B.intValue;
    keys[10] = _Y.intValue;
    keys[11] = _X.intValue;
    keys[12] = _START.intValue;
    keys[13] = _SELECT.intValue;
    keys[14] = _LX.intValue;
    keys[15] = _LY.intValue;
    keys[16] = _RX.intValue;
    keys[17] = _RY.intValue;
    keys[18] = _LT.intValue;
    keys[19] = _RT.intValue;
    keys[20] = (_LX_inv.state == NSOnState) ? 1 : 0;
    keys[21] = (_LY_inv.state == NSOnState) ? 1 : 0;
    keys[22] = (_RX_inv.state == NSOnState) ? 1 : 0;
    keys[23] = (_RY_inv.state == NSOnState) ? 1 : 0;
    
    for (int i = 0; i < 24; i++)
    {
        NSLog(@"%i", keys[i]);
    }
    
    NSData *data = [NSData dataWithBytes:&keys length:sizeof(keys)];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:data forKey:@"keys"];
    [defaults synchronize];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    
    // how many rows do we have here?
    return Gamepad_deviceAtIndex(_popUpButtonControllerSelectionOutlet.selectedTag)->numAxes + Gamepad_deviceAtIndex(_popUpButtonControllerSelectionOutlet.selectedTag)->numButtons;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {

    NSTableCellView *result = [tableView makeViewWithIdentifier:@"keysCellID" owner:self];
    
    if (Gamepad_deviceAtIndex(_popUpButtonControllerSelectionOutlet.selectedTag)->numButtons > row)
       result.textField.stringValue = [[NSString alloc] initWithFormat:@"Button: %li", (long)row];
    else
        result.textField.stringValue = [[NSString alloc] initWithFormat:@"Axis: %li", (long)row - Gamepad_deviceAtIndex(_popUpButtonControllerSelectionOutlet.selectedTag)->numButtons];
    
    
    return result;
}

#pragma mark - Table View Delegate

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSTableView *tableView = notification.object;
    NSLog(@"User has selected row %ld", (long)tableView.selectedRow);
}

#pragma mark - Controller Handling
GamepadMappingViewController* _viewController;

void onButtonDown_Conf(struct Gamepad_device * device, unsigned int buttonID, double timestamp, void * context) {
    [_viewController didPressButton:buttonID];
}

void onButtonUp_Conf(struct Gamepad_device * device, unsigned int buttonID, double timestamp, void * context) {
}

void onAxisMoved_Conf(struct Gamepad_device * device, unsigned int axisID, float value, float lastValue, double timestamp, void * context) {
    if (fabsf(lastValue - value) > 0.05) 
    {
        [_viewController didMoveAxis:axisID];
    }
}
void initGamepad_Conf(GamepadMappingViewController* view) {
    Gamepad_buttonDownFunc(onButtonDown_Conf, NULL);
    Gamepad_buttonUpFunc(onButtonUp_Conf, NULL);
    Gamepad_axisMoveFunc(onAxisMoved_Conf, NULL);
    Gamepad_init();
    _viewController = view;
}
@end
