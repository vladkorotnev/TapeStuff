//
//  AIInspectorWindow.m
//  AIEdit
//
//  Created by Akasaka Ryuunosuke on 15/02/15.
//  Copyright (c) 2015 Akasaka Ryuunosuke. All rights reserved.
//

#import "AIInspectorWindow.h"
#import "AVAudioGapPlayer.h"
@interface AIInspectorWindow ()

@end

@implementation AIInspectorWindow
@synthesize inspectedTrack;

- (instancetype)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}
- (void) _delegateMustReloadData {
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(AIInspectorDidChangeTrack)]) {
            [self.delegate AIInspectorDidChangeTrack];
        }
    }
}
- (void) loadTrack:(AITapeTrack*)track {
    inspectedTrack = track;
    [self.fileName setStringValue:inspectedTrack.fname];
    
    NSRect frame = [self.window frame];
    if ([inspectedTrack.player isKindOfClass:[AVAudioGapPlayer class]]) {
        [self.durationBox setHidden:false];
        [self.durationBox.animator setAlphaValue:1.0];
        
        [self.eqBox.animator setAlphaValue:0.0];
        [self.eqBox.animator setHidden:true];
        [self.durationField setStringValue:[NSString stringWithFormat:@"%.0f",inspectedTrack.dur]];
        frame.size.height = 130;
    } else {
        [self.eqBox setHidden:false];
        [self.eqBox.animator setAlphaValue:1.0];
        
        [self.durationBox.animator setAlphaValue:0.0];
        [self.durationBox.animator setHidden:true];
        frame.size.height = 270;
        for (NSSlider*slide in [self.eqBox.subviews[0] subviews]) {
            if([slide isKindOfClass:[NSSlider class]] && slide.tag < 111) {
                [slide setFloatValue:[inspectedTrack.equalizer[slide.tag] floatValue]];
            }
        }
        [self.levelSlider setFloatValue:inspectedTrack.level];
    }
 
    [self.window setFrame:frame display:true animate:true];
}

- (IBAction)lvlZero:(id)sender {
    self.levelSlider.floatValue = 1.0f;
    [self levelChange:self.levelSlider];
}

- (IBAction)eqZero:(id)sender {
    for (NSSlider*slide in [self.eqBox.subviews[0] subviews]) {
        if([slide isKindOfClass:[NSSlider class]] && slide.tag < 111) {
            [slide setFloatValue:0.0f];
        }
    }
    [self eqChange:nil];
}
- (void) show {
    [self.window orderBack:self];
}
- (IBAction)eqBalance:(id)sender {
    NSMutableArray* src = [[self.inspectedTrack equalizer]mutableCopy];
    float max = -20.0f;
    for (NSNumber*val in src) {
        if (max < [val floatValue]) {
            max = [val floatValue];
        }
    }
    for (int i =0; i < src.count; i++) {
        src[i] = [NSNumber numberWithFloat:([src[i] floatValue] - max)];
    }
    for (NSSlider*slide in [self.eqBox.subviews[0] subviews]) {
        if([slide isKindOfClass:[NSSlider class]] && slide.tag < 111) {
            [slide setFloatValue:[src[slide.tag] floatValue]];
        }
    }
    [self eqChange:nil];
}
- (IBAction)levelChange:(id)sender {
    inspectedTrack.level = self.levelSlider.floatValue;
    [self _delegateMustReloadData];
}

- (IBAction)eqChange:(id)sender {
    for (NSSlider*slide in [self.eqBox.subviews[0] subviews]) {
        if([slide isKindOfClass:[NSSlider class]] && slide.tag < 111) {
            inspectedTrack.equalizer[slide.tag] = [NSNumber numberWithFloat:slide.floatValue];
        }
    }
    [inspectedTrack setEqualizer:inspectedTrack.equalizer]; // for KVO
    [self _delegateMustReloadData];
}
- (IBAction)durationChanged:(id)sender {
    if (![inspectedTrack.player isKindOfClass:[AVAudioGapPlayer class]]) {
        return;
    }
    if ([[self.durationField stringValue]isEqualToString:@""]) {
        return;
    }
    inspectedTrack.dur = [self.durationField floatValue];
    inspectedTrack.durStr = [NSString stringWithTimeInterval:inspectedTrack.dur];
    ((AVAudioGapPlayer*)inspectedTrack.player)->length = inspectedTrack.dur;
    [self _delegateMustReloadData];
}
@end
