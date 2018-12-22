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
    int keys[30];
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
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:@"keys"];
    if (data != nil)
    {
        memcpy(keys, data.bytes, data.length);
        if (keys[0] != NO_MAP)
            _LB.intValue = keys[0];
        if (keys[1] != NO_MAP)
            _RB.intValue = keys[1];
        if (keys[2] != NO_MAP)
            _U.intValue = keys[2];
        if (keys[3] != NO_MAP)
            _R.intValue = keys[3];
        if (keys[4] != NO_MAP)
            _L.intValue = keys[4];
        if (keys[5] != NO_MAP)
            _D.intValue = keys[5];
        if (keys[6] != NO_MAP)
            _L3.intValue = keys[6];
        if (keys[7] != NO_MAP)
            _R3.intValue = keys[7];
        if (keys[8] != NO_MAP)
            _A.intValue = keys[8];
        if (keys[9] != NO_MAP)
            _B.intValue = keys[9];
        if (keys[10] != NO_MAP)
            _Y.intValue = keys[10];
        if (keys[11] != NO_MAP)
            _X.intValue = keys[11];
        if (keys[12] != NO_MAP)
            _START.intValue = keys[12];
        if (keys[13] != NO_MAP)
            _SELECT.intValue = keys[13];
        if (keys[14] != NO_MAP)
            _LX.intValue = keys[14];
        if (keys[15] != NO_MAP)
            _LY.intValue = keys[15];
        if (keys[16] != NO_MAP)
            _RX.intValue = keys[16];
        if (keys[17] != NO_MAP)
            _RY.intValue = keys[17];
        if (keys[18] != NO_MAP)
            _LT.intValue = keys[18];
        if (keys[19] != NO_MAP)
            _RT.intValue = keys[19];
        
        _LX_inv.state = keys[20];
        _LY_inv.state = keys[21];
        _RX_inv.state = keys[22];
        _RY_inv.state = keys[23];
        
        [_popUpUD selectItemAtIndex:keys[26]];
        [_popUpLR selectItemAtIndex:keys[27]];
        _UDInvert.state = keys[28];
        _LRInvert.state = keys[29];
        
        if (keys[24] != NO_MAP)
            _UDAxis.intValue = keys[24];
        if (keys[25] != NO_MAP)
            _LRAxis.intValue = keys[25];
    }
    
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
    keys[0] = [_LB.stringValue  isEqual: @""] ? NO_MAP : _LB.intValue;
    keys[1] = [_RB.stringValue  isEqual: @""] ? NO_MAP :_RB.intValue;
    keys[2] = [_U.stringValue  isEqual: @""] ? NO_MAP :_U.intValue;
    keys[3] = [_R.stringValue  isEqual: @""] ? NO_MAP :_R.intValue;
    keys[4] = [_L.stringValue  isEqual: @""] ? NO_MAP : _L.intValue;
    keys[5] = [_D.stringValue  isEqual: @""] ? NO_MAP :_D.intValue;
    keys[6] = [_L3.stringValue  isEqual: @""] ? NO_MAP :_L3.intValue;
    keys[7] = [_R3.stringValue  isEqual: @""] ? NO_MAP :_R3.intValue;
    keys[8] = [_A.stringValue  isEqual: @""] ? NO_MAP :_A.intValue;
    keys[9] = [_B.stringValue  isEqual: @""] ? NO_MAP :_B.intValue;
    keys[10] = [_Y.stringValue  isEqual: @""] ? NO_MAP :_Y.intValue;
    keys[11] = [_X.stringValue  isEqual: @""] ? NO_MAP :_X.intValue;
    keys[12] = [_START.stringValue  isEqual: @""] ? NO_MAP :_START.intValue;
    keys[13] = [_SELECT.stringValue  isEqual: @""] ? NO_MAP : _SELECT.intValue;
    keys[14] = [_LX.stringValue  isEqual: @""] ? NO_MAP :_LX.intValue;
    keys[15] = [_LY.stringValue  isEqual: @""] ? NO_MAP :_LY.intValue;
    keys[16] = [_RX.stringValue  isEqual: @""] ? NO_MAP :_RX.intValue;
    keys[17] = [_RY.stringValue  isEqual: @""] ? NO_MAP :_RY.intValue;
    keys[18] = [_LT.stringValue  isEqual: @""] ? NO_MAP :_LT.intValue;
    keys[19] = [_RT.stringValue  isEqual: @""] ? NO_MAP :_RT.intValue;
    keys[20] = (_LX_inv.state == NSOnState) ? 1 : 0;
    keys[21] = (_LY_inv.state == NSOnState) ? 1 : 0;
    keys[22] = (_RX_inv.state == NSOnState) ? 1 : 0;
    keys[23] = (_RY_inv.state == NSOnState) ? 1 : 0;
    keys[24] = [_UDAxis.stringValue  isEqual: @""] ? NO_MAP : _UDAxis.intValue;
    keys[25] = [_LRAxis.stringValue  isEqual: @""] ? NO_MAP : _LRAxis.intValue;
    keys[26] = _popUpUD.indexOfSelectedItem;
    keys[27] = _popUpLR.indexOfSelectedItem;
    keys[28] = (_UDInvert.state == NSOnState) ? 1 : 0;
    keys[29] = (_LRInvert.state == NSOnState) ? 1 : 0;
    
    NSData *data = [NSData dataWithBytes:&keys length:sizeof(keys)];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:data forKey:@"keys"];
    [defaults synchronize];
}

- (IBAction)buttonResetMapping:(id)sender
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"keys"];
    [defaults synchronize];
    
    _LB.stringValue = @"";
    _RB.stringValue = @"";
    _U.stringValue = @"";
    _R.stringValue = @"";
    _L.stringValue = @"";
    _D.stringValue = @"";
    _L3.stringValue = @"";
    _R3.stringValue = @"";
    _A.stringValue = @"";
    _B.stringValue = @"";
    _Y.stringValue = @"";
    _X.stringValue = @"";
    _START.stringValue = @"";
    _SELECT.stringValue = @"";
    _LX.stringValue = @"";
    _LY.stringValue = @"";
    _RX.stringValue = @"";
    _RY.stringValue = @"";
    _LT.stringValue = @"";
    _RT.stringValue = @"";
    _UDAxis.stringValue = @"";
    _LRAxis.stringValue = @"";
    
    _LX_inv.state = 0;
    _LY_inv.state = 0;
    _RX_inv.state = 0;
    _RY_inv.state = 0;
    _UDInvert.state = 0;
    _LRInvert.state = 0;
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if (Gamepad_numDevices() > 0)
        return Gamepad_deviceAtIndex(_popUpButtonControllerSelectionOutlet.selectedTag)->numAxes + Gamepad_deviceAtIndex(_popUpButtonControllerSelectionOutlet.selectedTag)->numButtons;
    return 0;
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
