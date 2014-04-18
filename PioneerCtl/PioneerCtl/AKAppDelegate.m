//
//  AKAppDelegate.m
//  PioneerCtl
//
//  Created by Akasaka Ryuunosuke on 18/04/14.
//  Copyright (c) 2014 Akasaka Ryuunosuke. All rights reserved.
//

#import "AKAppDelegate.h"

#import <IOKit/hidsystem/ev_keymap.h>
@implementation AKAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    for (ORSSerialPort*p in [[ORSSerialPortManager sharedSerialPortManager]availablePorts]) {
        
        [self.portList addItemWithTitle:p.name];
        
    }
    [self chgPort:self];
}
- (IBAction)btnClick:(NSButton *)sender {
    switch (sender.tag) {
        case 0:
            [deck stop];
            break;
        case 1:
            [deck power];
            break;
            
        case 2:
            [deck rewind];
            break;
            
            case 3:
            [deck play];
            break;
            
        case 4:
            [deck forward];
            break  ;
        case 5:
            [deck record];
            break;
        case 6:
            [deck pause];
            break;
            
        default:
            break;
    }
}

- (void)mediaKeyEvent: (int)key state: (BOOL)state repeat: (BOOL)repeat
{
    NSLog(@"Media key");
	switch( key )
	{
		case NX_KEYTYPE_PLAY:
			if( state == 0 ){
                [deck playPause];
            }
            //Play pressed and released
            return;
            break;
            
        case NX_KEYTYPE_PREVIOUS:
            if( state == 0 ){
                [deck rewind];
            }
            
            
            break;
            
        case NX_KEYTYPE_NEXT:
            if( state == 0 ){
                [deck forward];
            }
            break;
            
	}
}
- (IBAction)chgPort:(id)sender {
    
    if (![[self.portList selectedItem].title isEqualToString:@"Select control port"]) {
        for (ORSSerialPort*pt  in [[ORSSerialPortManager sharedSerialPortManager]availablePorts]) {
            if ([pt.name isEqualToString:[self.portList.selectedItem title]]) {
                deck = nil;
                deck = [[AKPioneerTapeRecorder alloc]initWithSerialPort:pt];
            }
        }
    }
}
@end
