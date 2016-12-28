//
//  AIAppDelegate.m
//  AIEdit
//
//  Created by Akasaka Ryuunosuke on 06/04/14.
//  Copyright (c) 2014 Akasaka Ryuunosuke. All rights reserved.
//

#import "AIAppDelegate.h"
#import "AVAudioGapPlayer.h"



@implementation AIAppDelegate
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    //
    [self.tapelen setDelegate:self];
    NSError *e;
    if([[NSFileManager defaultManager]fileExistsAtPath:TMPDIR])
        [[NSFileManager defaultManager]removeItemAtPath:TMPDIR error:nil];
    
    [[NSFileManager defaultManager]createDirectoryAtPath:TMPDIR withIntermediateDirectories:true attributes:@{} error:&e];
    if (e) {
        NSLog(@"Error making temp folder: %@", e.description);
    }
    
    insp = [[AIInspectorWindow alloc]initWithWindowNibName:@"AIInspectorWindow"];
    files = [NSMutableArray new];
    [self.filetable setDataSource:self]; [self.filetable setDelegate:self];
    for (ORSSerialPort*p in [[ORSSerialPortManager sharedSerialPortManager]availablePorts])
        [self.portList addItemWithTitle:p.name];
    
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"Transport"]) {
        [self.portList selectItemWithTitle:[[NSUserDefaults standardUserDefaults]objectForKey:@"Transport"]];
        [self transportComChg:self];
    }
    
    
    AIAudioOutputPlayer *otp = [AIAudioOutputPlayer sharedAudioFilePlayer];
   mOutputDeviceList = new AudioDeviceList(false);
    AudioObjectPropertyAddress theAddress = { kAudioHardwarePropertyDefaultOutputDevice,
        kAudioObjectPropertyScopeGlobal,
        kAudioObjectPropertyElementMaster };
    

    
    UInt32 propsize = sizeof(AudioDeviceID);
    verify_noerr (AudioObjectGetPropertyData(kAudioObjectSystemObject,
                                             &theAddress,
                                             0,
                                             NULL,
                                             &propsize,
                                             &outputDevice));
    
    [otp BuildDeviceMenuFromList:mOutputDeviceList inMenu:self.outSel initial:outputDevice];
    
    currentIdx=-1;
    
    [self.masterProcProg startAnimation:self];
    [self.filetable setDelegate:self];
    [self.tapelen resignFirstResponder];
    
    dbTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(_dbMeter) userInfo:nil repeats:true];
    
    [self.bar1 rotateByAngle:270.0f];
    self.bar1.frame= CGRectMake(10, 30, 12, 220);
    [self.bar2 rotateByAngle:270.0f];
    self.bar2.frame= CGRectMake(32, 30, 12, 220);
}
double dbamp(double db) { return pow(10., 0.05 * db); }
double ampdb(double amp) { return 20. * log10(amp); }

- (void) _dbMeter {
    double rms = (double)[[AIAudioOutputPlayer sharedAudioFilePlayer]meterForChannel:0];
    self.bar1.doubleValue = dbamp(rms);
    double ph= (double)[[AIAudioOutputPlayer sharedAudioFilePlayer]peakForChannel:0];
    self.bar2.doubleValue = dbamp(ph);
    self.phDisp.stringValue = (ph == -120 ? @"-∞": [NSString stringWithFormat:@"%.0f", ph]);
    self.rmsDisp.stringValue = (rms == -120 ? @"-∞": [NSString stringWithFormat:@"%.0f", rms]);
    self.phDisp.backgroundColor = ph > 0 ? [NSColor redColor] : [NSColor clearColor];
    self.rmsDisp.backgroundColor = rms > 0 ? [NSColor redColor] : [NSColor clearColor];
    
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    if(self.filetable.selectedRow < 0 || self.filetable.selectedRow >= files.count) {
        [insp close];
        return;
    }
    AITapeTrack* nus = files[self.filetable.selectedRow];
    
        [insp show];
        [insp loadTrack:nus];
    
}
- (void) AIInspectorDidChangeTrack {
    [self.filetable reloadData];
}
-(void)panel:(NSPanel*)p {
    [[NSApplication sharedApplication] beginSheet:p
                                   modalForWindow:self.window
                                    modalDelegate:self
                                   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
                                      contextInfo:nil];
}
- (void) noPanel:(NSPanel*)p {
    [[NSApplication sharedApplication] stopModal];
    [p orderOut:self];
    [ NSApp endSheet:p returnCode:0 ] ;
}
- (NSSize)windowWillResize:(NSWindow *)window toSize:(NSSize)proposedFrameSize {
    proposedFrameSize.width = window.frame.size.width;
    return proposedFrameSize;
}

- (void) sheetDidEnd:(NSWindow *) sheet returnCode:(int)returnCode contextInfo:(void *) contextInfo {
    
}
-(void) notifyWithTitle:(NSString*)title andText:(NSString*)wat {
    if (NSClassFromString(@"NSUserNotification") == nil || NSClassFromString(@"NSUserNotificationCenter") == nil ) {
        return;
    }
    //Initalize new notification
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    //Set the title of the notification
    [notification setTitle:title];
    //Set the text of the notification
    [notification setInformativeText:wat];
    //Set the time and date on which the nofication will be deliverd (for example 20 secons later than the current date and time)
    [notification setDeliveryDate:[NSDate dateWithTimeInterval:0.1 sinceDate:[NSDate date]]];
    //Set the sound, this can be either nil for no sound, NSUserNotificationDefaultSoundName for the default sound (tri-tone) and a string of a .caf file that is in the bundle (filname and extension)
    [notification setSoundName:nil];
    
    //Get the default notification center
    NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
    //Scheldule our NSUserNotification
    [center scheduleNotification:notification];
}

- (IBAction)recStart:(id)sender {
    if (isPreviewing) {
        [self previewStop:nil];
    }
    [self.prevPlay setEnabled:false];
    [self.startBtn setEnabled:false];
    [self.recBtn setEnabled:false];
    [self.statis setStringValue:NSLocalizedString(@"Recording side A...", @"Message")];
    [self.tapelen setEnabled:false];
    [self.outSel setEnabled:false];
    isRecording = true;
    if (sender && self.recauto.state == 1 && deck) {
        [deck record];
        [deck play];
    }
    if (self.leadin.state == 1 && sender) {
        [self.statis setStringValue:NSLocalizedString(@"5 second lead-in skip...", @"Message")];
        [self performSelector:@selector(recStart:) withObject:Nil afterDelay:5.0];
        return;
    }
    currentIdx=-1;
    currentSide=SideA;
    
    self->start = [NSDate date];
    [self _timer];
    [self _trackEndReached];
    [self.emergencyStopBtn setEnabled:true];
}
- (IBAction)start2:(id)sender {
    if (currentIdx == -1) {
        currentIdx = 0;
    }
    while (currentIdx < files.count && ((AITapeTrack*)files[currentIdx]).predictedSide != SideB) {
        currentIdx++;
    }
    [self.statis setStringValue:NSLocalizedString(@"Recording side B...", @"Message")];
    [self.startBtn setEnabled:false];
    [self.recBtn setEnabled:false];
    if (sender && self.recauto.state == 1 && deck) {
        [deck record];
        [deck play];
    }
    if (self.leadin.state == 1 && sender) {
        [self.statis setStringValue:NSLocalizedString(@"5 second lead-in skip...", @"Message")];
        [self performSelector:@selector(start2:) withObject:Nil afterDelay:5.0];
        return;
    }
    currentSide=SideB;
    currentIdx--;
    start = [NSDate date];
    [self _timer];
    [self _trackEndReached];
    [self.emergencyStopBtn setEnabled:true];
}
- (void) _doneAction {
    if (deck) {
        switch (self.sideDoneAction.selectedTag) {
            case 1:
                [deck stop];
                NSLog(@"done action fw");
                [deck forward];
                break;
                
            case 2:
                //[deck stop];
                [deck pause];
                NSLog(@"done action pause");
                break;
            case 3:
                [deck stop];
                NSLog(@"done action rew");
                [deck rewind];
                break;
                
            default:
                break;
        }
    } else NSLog(@"No deck!");
}
- (void) _finalize {
    [self.header setStringValue:@"AIEdit 2"];
    [self.recBtn setEnabled:true];
    [self.outSel setEnabled:true];
    [self.startBtn setEnabled:true];
    [self.tapelen setEnabled:true];
    [self.prevPlay setEnabled:true];
    [self notifyWithTitle:NSLocalizedString(@"Copying finished!", @"Notif title")   andText:NSLocalizedString(@"Finished copying to tape.",@"Notif message")];
    cur = nil;
    isRecording = false;
    start = nil;
    currentIdx = -1;
    [self _doneAction];
    [self.filetable reloadData];
}
NSDate *trkstart;
- (void) _trackEndReached {
    if (currentIdx >= 0 && currentIdx < files.count) {
        AITapeTrack *ot = (AITapeTrack*)files[currentIdx];
        if (ot) {
            @try {
                [ot removeObserver:self forKeyPath:@"equalizer"];
                [ot removeObserver:self forKeyPath:@"level"];
            }
            @catch (NSException *exception) {
                
            }
            @finally {
                
            }
        }
    }

    currentIdx++;
    if(currentIdx >= files.count) {
        [self.statis setStringValue:NSLocalizedString(@"Finished. Enjoy :)", @"Message")];
        [self _finalize];
        return;
    }
    AITapeTrack*t  = files[currentIdx];
    if (t.predictedSide != currentSide) {
        [self.statis setStringValue:NSLocalizedString(@"Waiting for Side B start...",@"Message")];
        start = nil;
        [self.header setStringValue:@"AIEdit 2"];
        [self notifyWithTitle:NSLocalizedString(@"Side A finished!", @"Message") andText:NSLocalizedString(@"Please flip the tape and record the side B",@"Message")];
        [self _doneAction];
        [self.startBtn setEnabled:true];
        
        return;
    }
    if (t.player) {
        if ([t.player isKindOfClass:[AVAudioGapPlayer class]]) {
            [t.player setDelegate:self];
            NSLog(@"GAP %@",t.player    );
            [t.player play];
             [self.filetable reloadData];
            return;
        }
    }
    cur = t.url;
    NSLog(@"Playing %@", t.url.absoluteString);
    [[AIAudioOutputPlayer sharedAudioFilePlayer] setEQFromArray:[t equalizationWithApplyingGlobalValues:[self eqBandsGlobal]]];
    [[AIAudioOutputPlayer sharedAudioFilePlayer] setVol:t.level];
    [t addObserver:self forKeyPath:@"equalizer" options:0 context:NULL];
    [t addObserver:self forKeyPath:@"level" options:0 context:NULL];
    [[AIAudioOutputPlayer sharedAudioFilePlayer]playURL:cur];
    
    [self.filetable reloadData];
   
    [self performSelector:@selector(_trackEndReached) withObject:nil afterDelay:t.dur];
}
- (IBAction)lvlEqGlobal:(id)sender {
    NSMutableArray* src = [[self eqBandsGlobal]mutableCopy];
    float max = -20.0f;
    for (NSNumber*val in src) {
        if (max < [val floatValue]) {
            max = [val floatValue];
        }
    }
    for (int i =0; i < src.count; i++) {
        src[i] = [NSNumber numberWithFloat:([src[i] floatValue] - max)];
    }
    [self writeEqBandsGlobal:src];
}
- (void) _timer {
    if (start) {
        [self.header setStringValue:[NSString stringWithTimeInterval:[[NSDate date] timeIntervalSinceDate:start]]];
       [self performSelector:@selector(_timer) withObject:nil afterDelay:1.0];
    }

    
}
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self _trackEndReached];
}



- (IBAction)gap:(NSControl *)sender {
    AVAudioGapPlayer*g = [[AVAudioGapPlayer alloc]initWithDelegate:self length:sender.tag];
    [self _addFromAudioPlayer:g file:nil];
}
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    if (cur && isRecording) {
        NSAlert* msgBox = [[NSAlert alloc] init] ;
        [msgBox setMessageText: NSLocalizedString(@"The tape is recording!", @"msgbox")];
        [msgBox setInformativeText:NSLocalizedString(@"The tape is recording. Are you sure you want to quit? This will stop playback.",@"Msgbox")];
        [msgBox addButtonWithTitle: NSLocalizedString(@"No",@"Msgbox")]; [msgBox addButtonWithTitle:NSLocalizedString(@"Yes",@"Msgbox")];
        if ([msgBox runModal] == NSAlertSecondButtonReturn) {
            return NSTerminateNow;
        } else return NSTerminateCancel;
        return NSTerminateCancel;
    }
    [[NSFileManager defaultManager]removeItemAtPath:TMPDIR error:nil];
    return NSTerminateNow;
}
- (IBAction)writeProject:(id)sender {
    if(files.count == 0) return;
    NSSavePanel *save = [[NSSavePanel alloc]init];
    [save setAllowedFileTypes:@[@"tape"]];
    [save setAllowsOtherFileTypes:false];
    if ([save runModal] == NSOKButton) {
        NSMutableDictionary * proj = [NSMutableDictionary new];
        [proj setValue:[NSNumber numberWithInt:self.tapelen.intValue] forKey:@"length"];
        NSData*dta = [NSKeyedArchiver archivedDataWithRootObject:files];
        [proj setValue:dta forKey:@"data"];
        [proj setValue:[self eqBandsGlobal] forKey:@"eq"];
        [proj writeToURL:[save URL] atomically:false];
        [[NSWorkspace sharedWorkspace] setIcon:[NSImage imageNamed:@"tapedoc"] forFile:[save URL].path options:0];
    }
}
- (IBAction)readProject:(id)sender {
    if (isRecording) return;
        NSOpenPanel *openPanel = [[NSOpenPanel alloc] init];
    [openPanel setCanChooseFiles:true];
    [openPanel setCanChooseDirectories:false];
    [openPanel setAllowsMultipleSelection:false];
    [openPanel setAllowedFileTypes:[NSArray arrayWithObjects:@"tape", nil]];
    if ([openPanel runModal] == NSOKButton)
    {
        if (files.count > 0) {
            NSAlert* msgBox = [[NSAlert alloc] init] ;
            [msgBox setMessageText: NSLocalizedString(@"Open project?", @"Msgbox")];
            [msgBox setInformativeText:NSLocalizedString(@"This will clear the current project!", @"Msgbox")];
            [msgBox addButtonWithTitle: NSLocalizedString(@"No",@"Msgbox")]; [msgBox addButtonWithTitle:NSLocalizedString(@"Yes",@"Msgbox")];
            if ([msgBox runModal] == NSAlertSecondButtonReturn) {
                [files removeAllObjects];
                [self.filetable reloadData];
                precalcMinutes = 0;
                [self _fillMeters];
                [self.tapelen setStringValue:@"90"];
            } else return;
        }
        NSDictionary* master = [NSDictionary dictionaryWithContentsOfURL:[openPanel URL]];
        [self.tapelen setStringValue:[NSString stringWithFormat:@"%i", [[master objectForKey:@"length"]intValue]]];
        NSArray* list = [NSKeyedUnarchiver unarchiveObjectWithData:[master objectForKey:@"data"]];
        files = [list mutableCopy];
    
       if(master[@"eq"]) [self writeEqBandsGlobal:master[@"eq"]];
        [self.filetable reloadData];
        [self _fillMeters];
    }
}
- (bool) _clearProject {
    if (isRecording) return false;
    NSAlert* msgBox = [[NSAlert alloc] init] ;
    [msgBox setMessageText: NSLocalizedString(@"New project?", @"Msgbox")];
    [msgBox setInformativeText:NSLocalizedString(@"This will clear the current project!", @"Msgbox")];
    [msgBox addButtonWithTitle: NSLocalizedString(@"No",@"Msgbox")]; [msgBox addButtonWithTitle:NSLocalizedString(@"Yes",@"Msgbox")];
    if ([msgBox runModal] == NSAlertSecondButtonReturn) {
        [files removeAllObjects];
        [self.filetable reloadData];
        precalcMinutes = 0;
        [self _fillMeters];
        [self.tapelen setStringValue:@"90"];
        [self zeroEqGlobal:nil];
        // [self zeroEqSel:nil];
        return true;
    }
    return false;
}
- (IBAction)newProject:(id)sender {
    [self _clearProject];
}

- (void) _addFromAudioPlayer: (AVAudioPlayer*)p file:(NSURL*)file{
    [p prepareToPlay];
    AITapeTrack*t = [AITapeTrack new];
    if (precalcMinutes + (p.duration/60) > self.tapelen.floatValue) {
        NSAlert* msgBox = [[NSAlert alloc] init] ;
        [msgBox setMessageText: [NSString stringWithFormat:NSLocalizedString(@"Cannot add %@ to tracklist", @"error message"),([p isKindOfClass:[AVAudioGapPlayer class]] ? @"Gap" : [file pathComponents].lastObject) ]];
        [msgBox setInformativeText:[NSString stringWithFormat:NSLocalizedString(@"It's length is %@, but you only have %@ left.", @"error description"), [NSString stringWithTimeInterval:p.duration], [NSString stringWithTimeInterval:(self.tapelen.integerValue*60 - (precalcMinutes*60))]]];
        [msgBox addButtonWithTitle: @"OK"];
        [msgBox runModal];
    } else {
        [t setUrl:file];
        if (precalcMinutes + (p.duration/60) > self.tapelen.floatValue/2)
            [t setPredictedSide:SideB];
        else
            [t setPredictedSide:SideA];
        [t setFname: ([p isKindOfClass:[AVAudioGapPlayer class]] ? @"Gap" : [file pathComponents].lastObject)];
        [t setDurStr: [NSString stringWithTimeInterval:p.duration]];
        [t setDur:p.duration];
        if([p isKindOfClass:[AVAudioGapPlayer class]])[t setPlayer:p];
        [files addObject:t];
        precalcMinutes += (t.dur/60);
        [self.filetable reloadData];
        [self _fillMeters];
    }
    
}
- (IBAction)add:(id)sender {
    if (precalcMinutes < [self.tapelen.stringValue floatValue]) {
        NSOpenPanel *openPanel = [[NSOpenPanel alloc] init];
        [openPanel setCanChooseFiles:true];
        [openPanel setResolvesAliases:true];
        [openPanel setRepresentedFilename:[@"~/Music" stringByExpandingTildeInPath]];
        [openPanel setCanChooseDirectories:false];
        [openPanel setAllowsMultipleSelection:true];
        [openPanel setAllowedFileTypes:[NSArray arrayWithObjects:@"mp3", @"m4a", @"wav", @"", nil]];
        if ([openPanel runModal] == NSOKButton)
        {
            for (NSURL*file in openPanel.URLs) {
                AVAudioPlayer* p = [[AVAudioPlayer alloc]initWithContentsOfURL:file error:nil];
                [self _addFromAudioPlayer:p file:file];
                if (self.gapadd.state == 1) {
                    AVAudioGapPlayer * gap = [[AVAudioGapPlayer alloc]initWithDelegate:self length:3.0];
                    [self _addFromAudioPlayer:gap file:nil];
                }
            }
        }
        
    }
}
- (void) _fillMeters {
    float Aside = 0;
    float Bside = 0;
    precalcMinutes = 0;
    for (AITapeTrack*t in files) {
        if(t.predictedSide == SideA) Aside += t.dur/60;
         if(t.predictedSide == SideB) Bside += t.dur/60;
        precalcMinutes += t.dur/60;
    }
    [self.fma setDoubleValue:MIN(1, Aside / (self.tapelen.floatValue/2))]; [self.fmb setDoubleValue:MIN(1, Bside / (self.tapelen.floatValue/2))];
    [self.remainA setStringValue: [NSString stringWithFormat:@"-%@", [NSString stringWithTimeInterval: ((self.tapelen.floatValue/2) - Aside) * 60]]];
    [self.remainB setStringValue: [NSString stringWithFormat:@"-%@", [NSString stringWithTimeInterval: ((self.tapelen.floatValue/2) - Bside) * 60]]];
    
    
}

- (IBAction)rem:(id)sender {
    if(self.filetable.selectedRow >= files.count || self.filetable.selectedRow < 0 || currentIdx == self.filetable.selectedRow) return;
    precalcMinutes -= ((AITapeTrack*)files[self.filetable.selectedRow]).player.duration/60;
    [files removeObjectAtIndex:[self.filetable selectedRow]];
    [self.filetable reloadData];
    [self _fillMeters];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return  files.count;
}

/* This method is required for the "Cell Based" TableView, and is optional for the "View Based" TableView. If implemented in the latter case, the value will be set to the view at a given row/column if the view responds to -setObjectValue: (such as NSControl and NSTableCellView).
 */
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
 
    AITapeTrack*t= files[row];
    if ([[[tableColumn headerCell]title]isEqualToString:@"File"] ) {
        return t.fname;
    } else  if ([[[tableColumn headerCell]title]isEqualToString:@"Duration"] ) {
        return t.durStr;
    } else  if ([[[tableColumn headerCell]title]isEqualToString:@"Side"] ) {
        return (t.predictedSide == SideA ? NSLocalizedString(@"A", @"Table") : NSLocalizedString(@"B", @"Table"));
    } else {
        if (isPreviewing && previewCur == row) {
            return NSLocalizedString(@"P→",@"Indicator Preview");
        }
        if (currentIdx == row ) {
            return NSLocalizedString(@"R→",@"Indicator Record");
        }
        return [NSString stringWithFormat:@"%li", row+1];
    }
    return @"";
}
- (IBAction)transportButtonClicked:(NSButton*)sender {
    if(!deck)return;
    switch (sender.tag) {
        case 0:
            [deck stop];
            break;
        case 1:
            [deck power];
            break;
            
        case 2:
            [deck rewind];
            break;
            
        case 3:
            [deck play];
            break;
            
        case 4:
            [deck forward];
            break  ;
        case 5:
            [deck record];
            break;
        case 6:
            [deck pause];
            break;
        case 7:
            [deck record];
            sleep(1);
            [deck play];
            
        default:
            break;
    }

}
- (IBAction)eqchange:(id)sender {
    [self _eqUpd];
}

- (IBAction)transportComChg:(id)sender {
    if (![[self.portList selectedItem].title isEqualToString:@"Select control port"]) {
        for (ORSSerialPort*pt  in [[ORSSerialPortManager sharedSerialPortManager]availablePorts]) {
            if ([pt.name isEqualToString:[self.portList.selectedItem title]]) {
                deck = nil;
                deck = [[AKPioneerTapeRecorder alloc]initWithSerialPort:pt];
                
            }
        }
    }
    [[NSUserDefaults standardUserDefaults]setObject:[self.portList.selectedItem title] forKey:@"Transport"];
}


- (IBAction)zeroEqGlobal:(id)sender {
    for (NSSlider*slide in [self.globalBox.subviews[0] subviews]) {
        if([slide isKindOfClass:[NSSlider class]] && slide.tag < 111) {
            NSLog(@"%@",slide);
            [slide setFloatValue:0.0f];
        }
    }
    [self _eqUpd];
}

- (NSArray*) eqBandsGlobal {
    NSMutableArray* bands = [NSMutableArray arrayWithCapacity:10];
    for (NSSlider*slide in [self.globalBox.subviews[0] subviews]) {
        if([slide isKindOfClass:[NSSlider class]] && slide.tag < 111) {
            bands[slide.tag] = [NSNumber numberWithFloat:slide.floatValue];
        }
    }
    return bands;
}


- (void) writeEqBandsGlobal: (NSArray*)vals {
    for (NSSlider*slide in [self.globalBox.subviews[0] subviews]) {
        if([slide isKindOfClass:[NSSlider class]] && slide.tag < 111) {
            [slide setFloatValue:[vals[slide.tag] floatValue]];
        }
    }
    [self _eqUpd];
}
- (void) _eqUpd {
    if (isPreviewing) {
        AITapeTrack *tt = files[previewCur];
        [[AIAudioOutputPlayer sharedAudioFilePlayer] setEQFromArray:[tt equalizationWithApplyingGlobalValues:[self eqBandsGlobal]]];
        [[AIAudioOutputPlayer sharedAudioFilePlayer] setVol:tt.level];
    } else if(isRecording) {
        AITapeTrack*t  = files[currentIdx];
        [[AIAudioOutputPlayer sharedAudioFilePlayer] setEQFromArray:[t equalizationWithApplyingGlobalValues:[self eqBandsGlobal]]];
        [[AIAudioOutputPlayer sharedAudioFilePlayer] setVol:t.level];
    } else {
        [[AIAudioOutputPlayer sharedAudioFilePlayer] setEQFromArray:[self eqBandsGlobal]];
        [[AIAudioOutputPlayer sharedAudioFilePlayer] setVol:1.0f];
    }
}
NSInteger previewCur;
bool isPreviewing, isRecording;
- (IBAction)previewPrev:(id)sender {
    if(!isPreviewing || isRecording) return;
    if(previewCur == 0) return;
    [[AIAudioOutputPlayer sharedAudioFilePlayer] stop];
    
    AITapeTrack *ot = (AITapeTrack*)files[previewCur];
    [ot removeObserver:self forKeyPath:@"equalizer"];
    [ot removeObserver:self forKeyPath:@"level"];
    
    previewCur--;
    while( (! ((AITapeTrack*)files[previewCur]).url) && previewCur >=0) {
        previewCur--;
        if (previewCur <0) {
            [self previewStop:sender];
            return;
        }
    }
    if (previewCur <0) {
        [self previewStop:sender];
        return;
    }
    AITapeTrack *tt =  (AITapeTrack*)files[previewCur];
    [[AIAudioOutputPlayer sharedAudioFilePlayer] setEQFromArray:[tt equalizationWithApplyingGlobalValues:[self eqBandsGlobal]]];
    [[AIAudioOutputPlayer sharedAudioFilePlayer] setVol:tt.level];
    
    [tt addObserver:self forKeyPath:@"equalizer" options:0 context:NULL];
    [tt addObserver:self forKeyPath:@"level" options:0 context:NULL];
    
    [[AIAudioOutputPlayer sharedAudioFilePlayer] playURL: tt.url];
    [self.filetable reloadData];
}
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self _eqUpd];
}
- (IBAction)previewNext:(id)sender {
     if(!isPreviewing || isRecording) return;
    if(previewCur == files.count-1) return;
     [[AIAudioOutputPlayer sharedAudioFilePlayer] stop];
    
    AITapeTrack *ot = (AITapeTrack*)files[previewCur];
    [ot removeObserver:self forKeyPath:@"equalizer"];
    [ot removeObserver:self forKeyPath:@"level"];
    
    previewCur++;
    while((!((AITapeTrack*)files[previewCur]).url) && !(previewCur >= files.count)) {
        previewCur++;
        if (previewCur >= files.count) {
            [self previewStop:sender];
            return;
        }
    }
    if (previewCur >= files.count) {
        [self previewStop:sender];
        return;
    }
    AITapeTrack *tt =  (AITapeTrack*)files[previewCur];
    [[AIAudioOutputPlayer sharedAudioFilePlayer] setEQFromArray:[tt equalizationWithApplyingGlobalValues:[self eqBandsGlobal]]];
    [[AIAudioOutputPlayer sharedAudioFilePlayer] setVol:tt.level];
    
    [tt addObserver:self forKeyPath:@"equalizer" options:0 context:NULL];
    [tt addObserver:self forKeyPath:@"level" options:0 context:NULL];
    
    [[AIAudioOutputPlayer sharedAudioFilePlayer] playURL: tt.url];
    [self.filetable reloadData];
}
- (IBAction)previewStop:(id)sender {
    if(!isPreviewing || isRecording) return;
    AITapeTrack *ot = (AITapeTrack*)files[previewCur];
    [ot removeObserver:self forKeyPath:@"equalizer"];
    [ot removeObserver:self forKeyPath:@"level"];
    isPreviewing = false;
    [[AIAudioOutputPlayer sharedAudioFilePlayer] stop];
    previewCur = 0;
    [self.filetable reloadData];
}
- (IBAction)previewPlay:(id)sender {
    if(files.count == 0) return;
    if (isPreviewing || isRecording) return;
    isPreviewing = true;
    while((!((AITapeTrack*)files[previewCur]).url) && !(previewCur >= files.count)) {
        previewCur++;
        if (previewCur >= files.count) {
            [self previewStop:sender];
            return;
        }
    }
    AITapeTrack *tt =  (AITapeTrack*)files[previewCur];
    [[AIAudioOutputPlayer sharedAudioFilePlayer] setEQFromArray:[tt equalizationWithApplyingGlobalValues:[self eqBandsGlobal]]];
    [[AIAudioOutputPlayer sharedAudioFilePlayer] setVol:tt.level];
    
    [tt addObserver:self forKeyPath:@"equalizer" options:0 context:NULL];
    [tt addObserver:self forKeyPath:@"level" options:0 context:NULL];
    
    [[AIAudioOutputPlayer sharedAudioFilePlayer] playURL: tt.url];
    [self.filetable reloadData];
}
- (IBAction)openReel:(id)sender {
    if (isRecording) return;
    [self panel:self.masterProcPanel];
    NSOpenPanel *openPanel = [[NSOpenPanel alloc] init];
    [openPanel setCanChooseFiles:true];
    [openPanel setCanChooseDirectories:false];
    [openPanel setAllowsMultipleSelection:false];
    [openPanel setAllowedFileTypes:[NSArray arrayWithObjects:@"reel", nil]];
    if ([openPanel runModal] == NSOKButton)
    {
        if (files.count > 0) {
            NSAlert* msgBox = [[NSAlert alloc] init] ;
            [msgBox setMessageText: NSLocalizedString(@"Open tape master?",@"MSGBOX")];
            [msgBox setInformativeText:NSLocalizedString(@"This will clear the current project!",@"Msgbox")];
            [msgBox addButtonWithTitle: NSLocalizedString(@"No",@"Msgbox")];
            [msgBox addButtonWithTitle: NSLocalizedString(@"Yes",@"Msgbox")];
            if ([msgBox runModal] == NSAlertSecondButtonReturn) {
                [files removeAllObjects];
                [self.filetable reloadData];
                precalcMinutes = 0;
                [self _fillMeters];
                [self.tapelen setStringValue:@"90"];
            } else return;
        }
        {

            NSDictionary* master = [[AIReelRecorder sharedInstance]openReelFromFile:[openPanel URL]];
            [self.tapelen setStringValue:[NSString stringWithFormat:@"%i", [[master objectForKey:@"length"]intValue]]];
            NSArray* list = [NSKeyedUnarchiver unarchiveObjectWithData:[master objectForKey:@"data"]];
            files = [list mutableCopy];
            
            if(master[@"eq"]) [self writeEqBandsGlobal:master[@"eq"]];
            [self.filetable reloadData];
            [self _fillMeters];
            
        }
    }
    [self noPanel:self.masterProcPanel];
}

- (IBAction)unpackTape:(id)sender {
    if (isRecording) return;
    [self panel:self.masterProcPanel];
    NSOpenPanel *openPanel = [[NSOpenPanel alloc] init];
    [openPanel setCanChooseFiles:true];
    [openPanel setCanChooseDirectories:false];
    [openPanel setAllowsMultipleSelection:false];
    [openPanel setAllowedFileTypes:[NSArray arrayWithObjects:@"reel", nil]];
    if ([openPanel runModal] == NSOKButton)
    {
        if (files.count > 0) {
            NSAlert* msgBox = [[NSAlert alloc] init] ;
            [msgBox setMessageText: NSLocalizedString(@"Open tape master?",@"MSGBOX")];
            [msgBox setInformativeText:NSLocalizedString(@"This will clear the current project!",@"Msgbox")];
            [msgBox addButtonWithTitle: NSLocalizedString(@"No",@"Msgbox")];
            [msgBox addButtonWithTitle: NSLocalizedString(@"Yes",@"Msgbox")];
            if ([msgBox runModal] == NSAlertSecondButtonReturn) {
                [files removeAllObjects];
                [self.filetable reloadData];
                precalcMinutes = 0;
                [self _fillMeters];
                [self.tapelen setStringValue:@"90"];
            } else return;
        }
        NSOpenPanel *dir = [[NSOpenPanel alloc] init];
        [dir setCanChooseFiles:false];
        [dir setCanChooseDirectories:true];
        [dir setAllowsMultipleSelection:false];
        [dir setTitle:NSLocalizedString(@"Select extraction folder", @"Msgbox")];
        if ([dir runModal] == NSOKButton)
        {
            NSURL *dest = [dir URL];
            
            NSDictionary* master = [[AIReelRecorder sharedInstance]openReelFromFile:[openPanel URL] extractedTo:dest];
            [self.tapelen setStringValue:[NSString stringWithFormat:@"%i", [[master objectForKey:@"length"]intValue]]];
            NSArray* list = [NSKeyedUnarchiver unarchiveObjectWithData:[master objectForKey:@"data"]];
            files = [list mutableCopy];
            
            if(master[@"eq"]) [self writeEqBandsGlobal:master[@"eq"]];
            [self.filetable reloadData];
            [self _fillMeters];

        }
    }
    [self noPanel:self.masterProcPanel];
}
- (IBAction)mvUp:(id)sender {
}
- (IBAction)mvDn:(id)sender {
}


-(void)textField:(AIClickableTextField*)textField didClick:(AIClickType)click {
    if (textField == self.tapelen) {
        if (click == AIRightClick) {
            [self.reelAssist showRelativeToRect:self.tapelen.frame ofView:self.tpbox preferredEdge:NSMaxYEdge];
        }
    }
}

- (IBAction)outChange:(id)sender {
    NSInteger val = [self.outSel indexOfSelectedItem];
    AudioDeviceID newDevice = (mOutputDeviceList->GetList())[val].mID;
    
    if(newDevice != outputDevice)
    {
       
        outputDevice = newDevice;
        [[AIAudioOutputPlayer sharedAudioFilePlayer]setAudioOutputDevice:outputDevice];
    }
}

- (IBAction)packTape:(id)sender {
    if (isRecording) return;
    if(files.count == 0) return;
    [self panel:self.masterProcPanel];
    NSSavePanel *save = [[NSSavePanel alloc]init];
    [save setAllowedFileTypes:@[@"reel"]];
    [save setAllowsOtherFileTypes:false];
    if ([save runModal] == NSOKButton) {
        NSMutableDictionary * proj = [NSMutableDictionary new];
        [proj setValue:[NSNumber numberWithInt:self.tapelen.intValue] forKey:@"length"];
        [proj setValue:[self eqBandsGlobal] forKey:@"eq"];
        [[AIReelRecorder sharedInstance]createReel:[save URL] fromTracks:files pData:proj];
    }
    [self noPanel:self.masterProcPanel];
}
- (IBAction)emergencyStop:(id)sender {
    NSAlert* msgBox = [[NSAlert alloc] init];
    [msgBox setMessageText: @"Abort recording"];
    [msgBox setInformativeText:@"Are you sure you want to stop recording?"];
    
    [msgBox addButtonWithTitle: @"Continue"];
    [msgBox addButtonWithTitle: @"Stop"];
    
    if ([msgBox runModal] == 1001) {
        [[AIAudioOutputPlayer sharedAudioFilePlayer]stop];
        [self _finalize];
    }
    
    
}
- (IBAction)chkLvl:(NSButton*)sender {
    if (sender.state > 0) {
         dbTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(_dbMeter) userInfo:nil repeats:true];
    } else {
        [dbTimer invalidate];
        self.bar1.doubleValue = 0.0;
        self.bar2.doubleValue = 0.0;
        self.rmsDisp.stringValue = @"off";
        self.phDisp.stringValue = @"off";
    }
}

- (IBAction)smartAdd:(id)sender {
    if ([self _clearProject]) {
            NSOpenPanel *openPanel = [[NSOpenPanel alloc] init];
            [openPanel setCanChooseFiles:true];
            [openPanel setResolvesAliases:true];
            [openPanel setRepresentedFilename:[@"~/Music" stringByExpandingTildeInPath]];
            [openPanel setCanChooseDirectories:false];
            [openPanel setAllowsMultipleSelection:true];
            [openPanel setAllowedFileTypes:[NSArray arrayWithObjects:@"mp3", @"m4a", @"wav", @"", nil]];
            if ([openPanel runModal] == NSOKButton)
            {
                NSMutableArray *sourceBin = [NSMutableArray new];
                NSMutableArray *sideABin = [NSMutableArray new];
                NSMutableArray *sideBBin = [NSMutableArray new];
                float sideARemains =  _tapelen.stringValue.floatValue/2.0f;
                float sideBRemains =  _tapelen.stringValue.floatValue/2.0f;
                float totalRemains = _tapelen.stringValue.floatValue;
                
                for (NSURL*file in openPanel.URLs) {
                    AVAudioPlayer* p = [[AVAudioPlayer alloc]initWithContentsOfURL:file error:nil];
                    totalRemains -= p.duration/60.0f;
                    [sourceBin addObject:p];
                }
                
                
                // now sort the source bin, largest file first
                sourceBin = [sourceBin sortedArrayUsingComparator:^NSComparisonResult(AVAudioPlayer* obj1, AVAudioPlayer* obj2) {
                    if (obj1.duration < obj2.duration) {
                        return NSOrderedDescending;
                    } else if (obj1.duration > obj2.duration) {
                        return NSOrderedAscending;
                    }
                    return NSOrderedSame;
                }].mutableCopy;
                
                // we could use a bin solving task there but we need to have at least *something like* a control over sides, nothing beats a manual compilation tho
                
                // first fill the A bin
                for(int i = 0; i < sourceBin.count; i++) {
                    AVAudioPlayer *p = sourceBin[i];
                    if (p.duration/60.0f <= sideARemains) {
                        [sideABin addObject:p];
                        sideARemains -= p.duration/60.0f;
                        [sourceBin removeObject:p];
                        i--;
                    }
                }
                
                // next fill the B bin
                for(int i = 0; i < sourceBin.count; i++) {
                    AVAudioPlayer *p = sourceBin[i];
                    if (p.duration/60.0f <= sideBRemains) {
                        [sideBBin addObject:p];
                        sideBRemains -= p.duration/60.0f;
                        [sourceBin removeObject:p];
                        i--;
                    }
                }
                
                if (sourceBin.count > 0) {
                    NSAlert* msgBox = [[NSAlert alloc] init];
                    [msgBox setMessageText: NSLocalizedString(@"Oops, that won't fit", @"Smart Add Error")];
                    NSMutableString *inf = [NSMutableString stringWithFormat:NSLocalizedString(@"Terribly sorry about this, but your total content length is more than your total tape length (need %g minute long cassette/reel). \n\nThese tracks were left out: ", @"Smart Add Error"),round(_tapelen.stringValue.floatValue+(totalRemains*-1))];
                    for (AVAudioPlayer*p  in sourceBin) {
                        [inf appendFormat:@"    • %@\n",[[[p.url absoluteString] lastPathComponent]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                    }
                    [msgBox setInformativeText:inf];
                    [msgBox addButtonWithTitle: @"OK"];
                    [msgBox runModal];
                }
                
                for (AVAudioPlayer*p in sideABin) {
                    [self _addFromAudioPlayer:p file:p.url];
                }
                for (AVAudioPlayer*p in sideBBin) {
                    [self _addFromAudioPlayer:p file:p.url];
                }
            }
    }
}
@end
