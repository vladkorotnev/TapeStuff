//
//  AKAppDelegate.h
//  PioneerCtl
//
//  Created by Akasaka Ryuunosuke on 18/04/14.
//  Copyright (c) 2014 Akasaka Ryuunosuke. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ORSSerialPortManager.h"
#import "AKPioneerTapeRecorder.h"
@interface AKAppDelegate : NSObject <NSApplicationDelegate>
{
    AKPioneerTapeRecorder* deck;
}
- (IBAction)chgPort:(id)sender;

@property (weak) IBOutlet NSPopUpButton *portList;
@property (assign) IBOutlet NSWindow *window;
- (IBAction)btnClick:(NSButton *)sender;
- (void)mediaKeyEvent: (int)key state: (BOOL)state repeat: (BOOL)repeat;
@end
