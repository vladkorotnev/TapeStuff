//
//  AIAudioOutputPlayer.m
//  AIEdit
//
//  Created by Akasaka Ryuunosuke on 13/07/14.
//  Copyright (c) 2014 Akasaka Ryuunosuke. All rights reserved.
//

#import "AIAudioOutputPlayer.h"
#import <mach/mach.h>
#import <mach/mach_time.h>
#include "CAXException.h"
#include "CAStreamBasicDescription.h"
#include "CAAudioUnit.h"
void checkErr(OSStatus e, NSString *desc){
    if (e != noErr) {
        NSLog(@"Error %i: %@", e, desc);
        abort();
    } else {
        NSLog(@"Success: %@", desc);
    }
}


@interface AIAudioOutputPlayer() {
    CAAudioUnit playUnit, outUnit, eqUnit;
    bool graphCreated;
    AUGraph graph;
    AUNode fileNode;  AUNode outputNode; AUNode eqNode;
    AudioFileID audioFile;
}
@end

@implementation AIAudioOutputPlayer


static AIAudioOutputPlayer *_sharedAudioFilePlayer = nil;

+ (id)sharedAudioFilePlayer
{
    if (!_sharedAudioFilePlayer) {
        _sharedAudioFilePlayer = [[self alloc] init];
    }
    return _sharedAudioFilePlayer;
}

- (id)init {
    self = [super init];
    if (self) {
        XThrowIfError (NewAUGraph (&graph), "NewAUGraph");
        // connect & setup
        XThrowIfError (AUGraphOpen (graph), "AUGraphOpen");
        CAComponentDescription cd;
        // output node
        cd.componentType = kAudioUnitType_Output;
        cd.componentSubType = kAudioUnitSubType_DefaultOutput;
        cd.componentManufacturer = kAudioUnitManufacturer_Apple;
        XThrowIfError (AUGraphAddNode (graph, &cd, &outputNode), "AUGraphAddNode");
        cd.componentType = kAudioUnitType_Effect;
        cd.componentSubType = kAudioUnitSubType_GraphicEQ;
        XThrowIfError (AUGraphAddNode (graph, &cd, &eqNode), "AUGraphAddNode");
        AudioUnit anAU;
        XThrowIfError (AUGraphNodeInfo(graph, eqNode, NULL, &anAU), "AUGraphNodeInfo");
        eqUnit = CAAudioUnit(eqNode, anAU);
        XThrowIfError(AudioUnitInitialize(eqUnit), "init eq");
        XThrowIfError(AudioUnitSetParameter(anAU, 10000, kAudioUnitScope_Global, 0, 0.0, 0), "set eq bands"); //10b eq
        // file AU node
        cd.componentType = kAudioUnitType_Generator;
        cd.componentSubType = kAudioUnitSubType_AudioFilePlayer;
        XThrowIfError (AUGraphAddNode (graph, &cd, &fileNode), "AUGraphAddNode");
        // install overload listener to detect when something is wrong
        XThrowIfError (AUGraphNodeInfo(graph, fileNode, NULL, &anAU), "AUGraphNodeInfo");
        playUnit = CAAudioUnit (fileNode, anAU);
        XThrowIfError (AUGraphConnectNodeInput (graph, fileNode, 0, eqNode, 0), "AUGraphConnectNodeInput");
         XThrowIfError (AUGraphConnectNodeInput (graph, eqNode, 0, outputNode, 0), "AUGraphConnectNodeInput");
        // AT this point we make sure we have the file player AU initialized
        // this also propogates the output format of the AU to the output unit
        XThrowIfError (AUGraphInitialize (graph), "AUGraphInitialize");
        CAShow(graph);
    }
    return self;
}

- (void) stop {
   AudioUnitReset(playUnit, kAudioUnitScope_Global, 0);
}

- (void) playURL:(NSURL*)url {
    [self stop];
    NSLog(@"File url %@", url.absoluteString);
    CFURLRef theURL = (__bridge CFURLRef)url;
    OSStatus err = AudioFileOpenURL (theURL, kAudioFileReadPermission, 0, &audioFile);
    XThrowIfError (err, "AudioFileOpenURL");
    // get the number of channels of the file
    CAStreamBasicDescription fileFormat;
    UInt32 propsize = sizeof(CAStreamBasicDescription);
    XThrowIfError (AudioFileGetProperty(audioFile, kAudioFilePropertyDataFormat, &propsize, &fileFormat), "AudioFileGetProperty");
    printf ("format: "); fileFormat.Print();
    // calculate the duration
    UInt64 nPackets;
    propsize = sizeof(nPackets);
    XThrowIfError (AudioFileGetProperty(audioFile, kAudioFilePropertyAudioDataPacketCount, &propsize, &nPackets), "kAudioFilePropertyAudioDataPacketCount");
    // set its output channels
    XThrowIfError (playUnit.SetNumberChannels (kAudioUnitScope_Output, 0, fileFormat.NumberChannels()), "SetNumberChannels");
    // load in the file
    XThrowIfError (playUnit.SetProperty(kAudioUnitProperty_ScheduledFileIDs,
                                      kAudioUnitScope_Global, 0, &audioFile, sizeof(audioFile)), "SetScheduleFile");
    // workaround a race condition in the file player AU
    usleep (10 * 1000);
    Float64 fileDuration = (nPackets * fileFormat.mFramesPerPacket) / fileFormat.mSampleRate;
    ScheduledAudioFileRegion rgn;
    memset (&rgn.mTimeStamp, 0, sizeof(rgn.mTimeStamp));
    rgn.mTimeStamp.mFlags = kAudioTimeStampSampleTimeValid;
    rgn.mTimeStamp.mSampleTime = 0;
    rgn.mCompletionProc = NULL;
    rgn.mCompletionProcUserData = NULL;
    rgn.mAudioFile = audioFile;
    rgn.mLoopCount = 0;
    rgn.mStartFrame = 0;
    rgn.mFramesToPlay = UInt32(nPackets * fileFormat.mFramesPerPacket);
    // tell the file player AU to play all of the file
    XThrowIfError (playUnit.SetProperty (kAudioUnitProperty_ScheduledFileRegion,
                                         kAudioUnitScope_Global, 0,&rgn, sizeof(rgn)), "kAudioUnitProperty_ScheduledFileRegion");
    // prime the fp AU with default values
    UInt32 defaultVal = 0;
    XThrowIfError (playUnit.SetProperty (kAudioUnitProperty_ScheduledFilePrime,
                                         kAudioUnitScope_Global, 0, &defaultVal, sizeof(defaultVal)), "kAudioUnitProperty_ScheduledFilePrime");
    // tell the fp AU when to start playing (this ts is in the AU's render time stamps; -1 means next render cycle)
    AudioTimeStamp startTime;
    memset (&startTime, 0, sizeof(startTime));
    startTime.mFlags = kAudioTimeStampSampleTimeValid;
    startTime.mSampleTime = -1;
    XThrowIfError (playUnit.SetProperty(kAudioUnitProperty_ScheduleStartTimeStamp,
                                        kAudioUnitScope_Global, 0, &startTime, sizeof(startTime)), "kAudioUnitProperty_ScheduleStartTimeStamp");
    AUGraphStart(graph);
}

- (void) setEQFromArray:(NSArray*)tenBands{
    for (NSUInteger bandIndex = 0; bandIndex < MIN(10, tenBands.count); bandIndex++) {
      
        Float32 bandValue = [[tenBands objectAtIndex:bandIndex] floatValue];
        XThrowIfError(AudioUnitSetParameter(eqUnit, bandIndex, kAudioUnitScope_Global, 0, bandValue, 0), "band");
    }
}






@end
