//
//  AKApp.m
//  PioneerCtl
//
//  Created by Akasaka Ryuunosuke on 18/04/14.
//  Copyright (c) 2014 Akasaka Ryuunosuke. All rights reserved.
//

#import "AKApp.h"
#import "AKAppDelegate.h"
@implementation AKApp
- (void)sendEvent: (NSEvent*)event
{
	if( [event type] == NSSystemDefined && [event subtype] == 8 )
	{
		int keyCode = (([event data1] & 0xFFFF0000) >> 16);
		int keyFlags = ([event data1] & 0x0000FFFF);
		int keyState = (((keyFlags & 0xFF00) >> 8)) == 0xA;
		int keyRepeat = (keyFlags & 0x1);
		
		[(AKAppDelegate*)self.delegate mediaKeyEvent: keyCode state: keyState repeat: keyRepeat];
	}
    
	[super sendEvent: event];
}
@end
