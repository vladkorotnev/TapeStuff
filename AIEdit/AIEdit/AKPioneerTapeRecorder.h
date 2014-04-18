//
//  AKPioneerTapeRecorder.h
//  PioneerCtl
//
//  Created by Akasaka Ryuunosuke on 18/04/14.
//  Copyright (c) 2014 Akasaka Ryuunosuke. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ORSSerialPort.h"
@interface AKPioneerTapeRecorder : NSObject
{
    ORSSerialPort* port;
    bool isPlaying;
}
- (AKPioneerTapeRecorder*)initWithSerialPort: (ORSSerialPort*)port;
- (void) play;
- (void) playPause;
- (void) pause;
- (void) stop;
- (void) rewind;
- (void) forward;
- (void) record;
- (void) power;
- (void) close;
@end
