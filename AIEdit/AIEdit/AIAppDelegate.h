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
#include "AIAudioOutputPlayer.h"
#import "AIReelRecorder.h"
#import <CoreAudio/CoreAudio.h>
#import "AIInspectorWindow.h"
#import "AICategories.h"
#import "AIClickableTextField.h"
#define TMPDIR [NSTemporaryDirectory() stringByAppendingPathComponent:@"AIEditReelTMP"]
@interface AIAppDelegate : NSObject <NSApplicationDelegate, AVAudioPlayerDelegate, NSTableViewDataSource, NSTableViewDelegate,NSTextFieldDelegate, AIInspectorDelegate>
{
    NSMutableArray* files;
    float precalcMinutes;
    NSURL* cur;
    int currentIdx;
    enum TapeSide currentSide;
    NSDate *start;
    AKPioneerTapeRecorder* deck;
    AudioDeviceList	*				mOutputDeviceList;
    AudioDeviceID					outputDevice;
    AIInspectorWindow *insp;
    NSTimer *dbTimer;
}
@property (weak) IBOutlet NSTextField *rmsDisp;
@property (weak) IBOutlet NSTextField *phDisp;
- (IBAction)emergencyStop:(id)sender;
@property (weak) IBOutlet NSButton *emergencyStopBtn;
- (IBAction)openReel:(id)sender;
- (IBAction)unpackTape:(id)sender;
@property (weak) IBOutlet NSPopUpButton *outSel;
- (IBAction)outChange:(id)sender;
@property (weak) IBOutlet NSButton *leadin;
@property (weak) IBOutlet NSPopover *reelAssist;
- (IBAction)chkLvl:(id)sender;
- (IBAction)smartAdd:(id)sender;

@property (weak) IBOutlet NSBox *tpbox;
- (IBAction)packTape:(id)sender;
@property (weak) IBOutlet NSProgressIndicator *masterProcProg;
@property (unsafe_unretained) IBOutlet NSPanel *masterProcPanel;
@property (strong) IBOutlet NSButton *globalZero;
@property (weak) IBOutlet NSBox *globalBox;
@property (weak) IBOutlet NSSlider *globLvl;
- (IBAction)eqchange:(id)sender;
@property (weak) IBOutlet NSBox *selbox;
@property (weak) IBOutlet NSTextField *prevStat;
@property (weak) IBOutlet NSSlider *selPan;
@property (weak) IBOutlet NSSlider *globalPan;
@property (weak) IBOutlet NSButton *selZero;
@property (weak) IBOutlet NSButton *prevPlay;
@property (weak) IBOutlet NSButton *recauto;
@property (weak) IBOutlet NSPopUpButton *sideDoneAction;
@property (weak) IBOutlet NSPopUpButton *portList;
@property (weak) IBOutlet NSTextField *header;
@property (weak) IBOutlet AIClickableTextField *tapelen;
@property (weak) IBOutlet NSSlider *selLvl;
@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *statis;
- (IBAction)recStart:(id)sender;
@property (weak) IBOutlet NSButton *recBtn;
@property (weak) IBOutlet NSButton *startBtn;
- (IBAction)start2:(id)sender;
- (IBAction)add:(id)sender;
- (IBAction)gap:(id)sender;
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
@property (weak) IBOutlet NSButton *gapadd;

@end
