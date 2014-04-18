//
//  AIAppDelegate.h
//  AIEdit
//
//  Created by Akasaka Ryuunosuke on 06/04/14.
//  Copyright (c) 2014 Akasaka Ryuunosuke. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVFoundation.h>
#import "AITapeTrack.h"
#import "AKPioneerTapeRecorder.h"
#import "ORSSerialPortManager.h"
@interface AIAppDelegate : NSObject <NSApplicationDelegate, AVAudioPlayerDelegate, NSTableViewDataSource>
{
    NSMutableArray* files;
    float precalcMinutes;
    AVAudioPlayer* cur;
    int currentIdx;
    enum TapeSide currentSide;
    NSDate *start;
    AKPioneerTapeRecorder* deck;
}
@property (weak) IBOutlet NSPopUpButton *portList;
@property (weak) IBOutlet NSTextField *header;
@property (weak) IBOutlet NSTextField *tapelen;
@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *statis;
- (IBAction)recStart:(id)sender;
@property (weak) IBOutlet NSButton *recBtn;
@property (weak) IBOutlet NSButton *startBtn;
- (IBAction)start2:(id)sender;
- (IBAction)add:(id)sender;
@property (weak) IBOutlet NSTableView *filetable;
- (IBAction)rem:(id)sender;
@property (weak) IBOutlet NSProgressIndicator *bar1;
@property (weak) IBOutlet NSProgressIndicator *bar2;
@property (weak) IBOutlet NSButton *addBtn;
@property (weak) IBOutlet NSButton *remBtn;
@property (weak) IBOutlet NSProgressIndicator *fma;
@property (weak) IBOutlet NSProgressIndicator *fmb;
@property (weak) IBOutlet NSTextField *remainA;
@property (weak) IBOutlet NSTextField *remainB;
- (IBAction)transportButtonClicked:(id)sender;
- (IBAction)transportComChg:(id)sender;

@end
