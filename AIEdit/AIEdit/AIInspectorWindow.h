//
//  AIInspectorWindow.h
//  AIEdit
//
//  Created by Akasaka Ryuunosuke on 15/02/15.
//  Copyright (c) 2015 Akasaka Ryuunosuke. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AITapeTrack.h"
@interface AIInspectorWindow : NSWindowController
@property (weak) IBOutlet NSBox *eqBox;
@property (weak) IBOutlet NSSlider *levelSlider;
- (IBAction)eqZero:(id)sender;
- (IBAction)eqBalance:(id)sender;
@property (weak) IBOutlet NSTextField *fileName;
- (IBAction)levelChange:(id)sender;
- (IBAction)eqChange:(id)sender;

@property (nonatomic) AITapeTrack * inspectedTrack;
- (void) loadTrack:(AITapeTrack*)track;
- (void) show;
@end
