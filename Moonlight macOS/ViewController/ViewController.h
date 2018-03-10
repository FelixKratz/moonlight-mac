//
//  ViewController.h
//  Moonlight macOS
//
//  Created by Felix Kratz on 09.03.18.
//  Copyright © 2018 Felix Kratz. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>
#import "DiscoveryManager.h"
#import "PairManager.h"
#import "StreamConfiguration.h"
#import "AppAssetManager.h"

@interface ViewController : NSViewController <DiscoveryCallback, PairCallback, AppAssetCallback, NSURLConnectionDelegate>

- (IBAction)buttonConnect:(id)sender;
@property (weak) IBOutlet NSTextField *textFieldHost;
@end

