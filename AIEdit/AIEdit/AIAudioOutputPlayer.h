//
//  AIAudioOutputPlayer.h
//  AIEdit
//
//  Created by Akasaka Ryuunosuke on 13/07/14.
//  Copyright (c) 2014 Akasaka Ryuunosuke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudio.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioUnit/AudioUnit.h>
#include "AudioDeviceList.h"

@interface AIAudioOutputPlayer : NSObject

+ (AIAudioOutputPlayer *)sharedAudioFilePlayer;
- (void) setEQFromArray:(NSArray*)tenBands ;
- (void) playURL:(NSURL*)url;
- (void) stop;
- (CFArrayRef)deviceList;
- (void) BuildDeviceMenuFromList:(AudioDeviceList *)devlist inMenu:(NSPopUpButton *)menu initial:(AudioDeviceID) initSel;
- (void) setAudioOutputDevice:(AudioDeviceID)oid;
- (void) setVol:(float) vol;
@end
