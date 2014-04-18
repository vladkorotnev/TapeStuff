//
//  AKPioneerTapeRecorder.m
//  PioneerCtl
//
//  Created by Akasaka Ryuunosuke on 18/04/14.
//  Copyright (c) 2014 Akasaka Ryuunosuke. All rights reserved.
//

#import "AKPioneerTapeRecorder.h"
@interface NSString(datA)
-(NSData*)data;
@end
@implementation NSString (datA)

-(NSData*)data { return [self dataUsingEncoding:NSASCIIStringEncoding]; }

@end
@implementation AKPioneerTapeRecorder
- (AKPioneerTapeRecorder*)initWithSerialPort: (ORSSerialPort*)p {
    self = [self init];
    
    if (self) {
        self->port = p;
        [self->port setDelegate:self];
        [self->port setBaudRate:[NSNumber numberWithInteger:38400]];
        self->isPlaying = false;
        [self->port open];
    }
    return self;
}
- (void) play {
    [self->port sendData:[@"PP" data]];
}
- (void) pause {
    [self->port sendData:[@"HH" data]];
}
- (void) stop {
    [self->port sendData:[@"SS" data]];
}
- (void) rewind {
    [self->port sendData:[@"BB" data]];
}
- (void) forward {
    [self->port sendData:[@"FF" data]];
}
- (void) record{
    [self->port sendData:[@"RR" data]];
}
- (void) power {
    [self->port sendData:[@"OO" data]];
}
- (void) close {
    [self->port close];
    
}
- (void)serialPort:(ORSSerialPort *)serialPort didReceiveData:(NSData *)data
{
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"RECV %@",string);
}
- (void) playPause {
    if (self->isPlaying) {
        [self pause];isPlaying = false;
    } else {
        [self play]; isPlaying = true;
    }
}
@end
