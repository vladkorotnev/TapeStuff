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
    // Insert code here to initialize your application
    
    
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
    [self.recBtn setEnabled:false];
    [self.statis setStringValue:@"Recording side A..."];
    [self.tapelen setEnabled:false];
    [self.outSel setEnabled:false];
    isRecording = true;
    if (sender && self.recauto.state == 1 && deck) {
        [deck record];
        [deck play];
    }
    if (self.leadin.state == 1 && sender) {
        [self.statis setStringValue:@"5 second lead-in skip..."];
        [self performSelector:@selector(recStart:) withObject:Nil afterDelay:5.0];
        return;
    }
    currentIdx=-1;
    currentSide=SideA;
    
    self->start = [NSDate date];
    [self _timer];
    [self _trackEndReached];
}
- (IBAction)start2:(id)sender {
    [self.statis setStringValue:@"Recording side B..."];
    [self.startBtn setEnabled:false];
    if (sender && self.recauto.state == 1 && deck) {
        [deck record];
        [deck play];
    }
    if (self.leadin.state == 1 && sender) {
        [self.statis setStringValue:@"5 second lead-in skip..."];
        [self performSelector:@selector(start2:) withObject:Nil afterDelay:5.0];
        return;
    }
    currentSide=SideB;
    currentIdx--;
    start = [NSDate date];
    [self _timer];
    [self _trackEndReached];
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
NSDate *trkstart;
- (void) _trackEndReached {
    currentIdx++;
    if(currentIdx >= files.count) {
        [self.recBtn setEnabled:true];
        [self.outSel setEnabled:true];
        [self.startBtn setEnabled:false];
        [self.tapelen setEnabled:true];
        [self.statis setStringValue:@"Finished. Enjoy :)"];
        [self.header setStringValue:@"AIEdit 2"];
         [self.prevPlay setEnabled:true];
        [self notifyWithTitle:@"Copying finished!" andText:@"Finished copying to tape."];
        cur = nil;
        isRecording = false;
        start = nil;
        currentIdx = -1;
        [self _doneAction];
        [self.filetable reloadData];
        return;
    }
    AITapeTrack*t  = files[currentIdx];
    if (t.predictedSide != currentSide) {
        [self.statis setStringValue:@"Waiting for Side B start..."];
        start = nil;
        [self.header setStringValue:@"AIEdit 2"];
        [self notifyWithTitle:@"Side A finished!" andText:@"Please flip the tape and record the side B"];
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
        [self.header setStringValue:[self timeFormatted:[[NSDate date] timeIntervalSinceDate:start]]];
       [self performSelector:@selector(_timer) withObject:nil afterDelay:1.0];
    }

    
}
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self _trackEndReached];
}


- (NSString *)timeFormatted:(int)totalSeconds
{
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
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
        [msgBox setMessageText: @"The tape is recording!"];
        [msgBox setInformativeText:@"The tape is recording. Are you sure you want to quit? This will stop playback."];
        [msgBox addButtonWithTitle: @"No"]; [msgBox addButtonWithTitle:@"Yes"];
        if ([msgBox runModal] == NSAlertSecondButtonReturn) {
            return NSTerminateNow;
        } else return NSTerminateCancel;
        return NSTerminateCancel;
    }
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
            [msgBox setMessageText: @"Open project?"];
            [msgBox setInformativeText:@"This will clear the current project!"];
            [msgBox addButtonWithTitle: @"No"];
            [msgBox addButtonWithTitle:@"Yes"];
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
- (IBAction)newProject:(id)sender {
    if (isRecording) return;
    NSAlert* msgBox = [[NSAlert alloc] init] ;
    [msgBox setMessageText: @"New project?"];
    [msgBox setInformativeText:@"This will clear the current project!"];
    [msgBox addButtonWithTitle: @"No"];
    [msgBox addButtonWithTitle:@"Yes"];
    if ([msgBox runModal] == NSAlertSecondButtonReturn) {
        [files removeAllObjects];
        [self.filetable reloadData];
        precalcMinutes = 0;
        [self _fillMeters];
        [self.tapelen setStringValue:@"90"];
        [self zeroEqGlobal:nil];
       // [self zeroEqSel:nil];
    }
}
- (void) _addFromAudioPlayer: (AVAudioPlayer*)p file:(NSURL*)file{
    [p prepareToPlay];
    AITapeTrack*t = [AITapeTrack new];
    if (precalcMinutes + (p.duration/60) > self.tapelen.floatValue) {
        NSAlert* msgBox = [[NSAlert alloc] init] ;
        [msgBox setMessageText: [NSString stringWithFormat:NSLocalizedString(@"Cannot add %@ to tracklist", @"error message"),([p isKindOfClass:[AVAudioGapPlayer class]] ? @"Gap" : [file pathComponents].lastObject) ]];
        [msgBox setInformativeText:[NSString stringWithFormat:NSLocalizedString(@"It's length is %@, but you only have %@ left.", @"error description"), [self timeFormatted:p.duration], [self timeFormatted:(self.tapelen.integerValue*60 - (precalcMinutes*60))]]];
        [msgBox addButtonWithTitle: @"OK"];
        [msgBox runModal];
    } else {
        [t setUrl:file];
        if (precalcMinutes + (p.duration/60) > self.tapelen.floatValue/2)
            [t setPredictedSide:SideB];
        else
            [t setPredictedSide:SideA];
        [t setFname: ([p isKindOfClass:[AVAudioGapPlayer class]] ? @"Gap" : [file pathComponents].lastObject)];
        [t setDurStr: [self timeFormatted:p.duration]];
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
    [self.remainA setStringValue: [NSString stringWithFormat:@"-%@", [self timeFormatted: ((self.tapelen.floatValue/2) - Aside) * 60]]];
    [self.remainB setStringValue: [NSString stringWithFormat:@"-%@", [self timeFormatted: ((self.tapelen.floatValue/2) - Bside) * 60]]];
    
    
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
        return (t.predictedSide == SideA ? @"Side A" : @"Side B");
    } else {
        if (isPreviewing && previewCur == row) {
            return @"Pre";
        }
        return (currentIdx == row ? @"→" : @"");
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
#warning TOFIX when adding per-track eq
    [[AIAudioOutputPlayer sharedAudioFilePlayer] setEQFromArray:[self eqBandsGlobal]];
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
#warning TOFIX when adding per-track eq
    [[AIAudioOutputPlayer sharedAudioFilePlayer] setEQFromArray:[self eqBandsGlobal]];
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
#warning TOFIX when adding per-track eq
    [[AIAudioOutputPlayer sharedAudioFilePlayer] setEQFromArray:[self eqBandsGlobal]];
}

NSInteger previewCur;
bool isPreviewing, isRecording;
- (IBAction)previewPrev:(id)sender {
    if(!isPreviewing || isRecording) return;
    [[AIAudioOutputPlayer sharedAudioFilePlayer] stop];
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
    [[AIAudioOutputPlayer sharedAudioFilePlayer] playURL: tt.url];
    [self.filetable reloadData];
}

- (IBAction)previewNext:(id)sender {
     if(!isPreviewing || isRecording) return;
     [[AIAudioOutputPlayer sharedAudioFilePlayer] stop];
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
    [[AIAudioOutputPlayer sharedAudioFilePlayer] playURL: tt.url];
    [self.filetable reloadData];
}
- (IBAction)previewStop:(id)sender {
    if(!isPreviewing || isRecording) return;
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
    [[AIAudioOutputPlayer sharedAudioFilePlayer] playURL: tt.url];
    [self.filetable reloadData];
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
            [msgBox setMessageText: @"Open tape master?"];
            [msgBox setInformativeText:@"This will clear the current project!"];
            [msgBox addButtonWithTitle: @"No"];
            [msgBox addButtonWithTitle:@"Yes"];
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
        [dir setTitle:@"Select extraction folder"];
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
@end
