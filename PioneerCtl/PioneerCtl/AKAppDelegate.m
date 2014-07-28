//
//  AKAppDelegate.m
//  PioneerCtl
//
//  Created by Akasaka Ryuunosuke on 18/04/14.
//  Copyright (c) 2014 Akasaka Ryuunosuke. All rights reserved.
//

#import "AKAppDelegate.h"
#import "BARRouter.h"
#import <IOKit/hidsystem/ev_keymap.h>
@implementation AKAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    actz = @[@"stop",@"power",@"rewind",@"play",@"forward",@"record",@"pause"];
    // Insert code here to initialize your application
    for (ORSSerialPort*p in [[ORSSerialPortManager sharedSerialPortManager]availablePorts]) {
        
        [self.portList addItemWithTitle:p.name];
        
    }
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"Transport"]) {
        [self.portList selectItemWithTitle:[[NSUserDefaults standardUserDefaults]objectForKey:@"Transport"]];
        [self chgPort:self];
    }
    srv = [BARServer serverWithPort:9898];
    BARRouter *router = [[BARRouter alloc] init];
	[srv addGlobalMiddleware:router];
    
	[router addRoute:@"/:action" forHTTPMethod:@"GET" handler:^BOOL(BARConnection *connection, BARRequest *request, NSDictionary *parameters) {
		NSString * p = parameters[@"action"];
        NSLog(@"Par %@",p);
        NSUInteger cmidx = -1;
        for (NSString*a in actz) {
            if ([a isEqualToString:[p lowercaseString]]) {
                cmidx = [actz indexOfObject:a];
            }
        }
        [self _oelutz: cmidx];
		BARResponse *response = [[BARResponse alloc] init];
		response.statusCode = 200;
		response.responseData = @"";
		[connection sendResponse:response];
		return YES;
	}];
    [srv setListening:YES];

}
- (void) _oelutz:(NSUInteger)cmd {
    NSLog(@"Oelutz %i",cmd);
    switch (cmd) {
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
- (IBAction)btnClick:(NSButton *)sender {
    [self _oelutz:sender.tag];
}

- (void)mediaKeyEvent: (int)key state: (BOOL)state repeat: (BOOL)repeat
{
    NSLog(@"Media key");
	switch( key )
	{
		case NX_KEYTYPE_PLAY:
			if( state == 0 )
                [deck playPause];
            break;
            
        case NX_KEYTYPE_PREVIOUS:
            if( state == 0 )
                [deck rewind];
            break;
            
        case NX_KEYTYPE_NEXT:
            if( state == 0 )
                [deck forward];
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
    [[NSUserDefaults standardUserDefaults]setObject:[self.portList.selectedItem title] forKey:@"Transport"];
}
@end
