//
//  AIInspectorWindow.m
//  AIEdit
//
//  Created by Akasaka Ryuunosuke on 15/02/15.
//  Copyright (c) 2015 Akasaka Ryuunosuke. All rights reserved.
//

#import "AIInspectorWindow.h"

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
- (void) loadTrack:(AITapeTrack*)track {
    inspectedTrack = track;
    [self.fileName setStringValue:inspectedTrack.fname];
    for (NSSlider*slide in [self.eqBox.subviews[0] subviews]) {
        if([slide isKindOfClass:[NSSlider class]] && slide.tag < 111) {
            [slide setFloatValue:[inspectedTrack.equalizer[slide.tag] floatValue]];
        }
    }
    [self.levelSlider setFloatValue:inspectedTrack.level];
}
- (void)windowDidLoad
{
    [super windowDidLoad];
    
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
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
}

- (IBAction)eqChange:(id)sender {
    for (NSSlider*slide in [self.eqBox.subviews[0] subviews]) {
        if([slide isKindOfClass:[NSSlider class]] && slide.tag < 111) {
            inspectedTrack.equalizer[slide.tag] = [NSNumber numberWithFloat:slide.floatValue];
        }
    }
    [inspectedTrack setEqualizer:inspectedTrack.equalizer]; // for KVO
}
@end
