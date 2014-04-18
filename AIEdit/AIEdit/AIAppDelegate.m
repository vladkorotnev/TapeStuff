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
    for (ORSSerialPort*p in [[ORSSerialPortManager sharedSerialPortManager]availablePorts]) {
        
        [self.portList addItemWithTitle:p.name];
        
    }
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"Transport"]) {
        [self.portList selectItemWithTitle:[[NSUserDefaults standardUserDefaults]objectForKey:@"Transport"]];
        [self transportComChg:self];
    }
 
    
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
    currentIdx=-1;
    currentSide=SideA;
    [self.recBtn setEnabled:false];
    [self.statis setStringValue:@"Recording side A..."];
    [self.tapelen setEnabled:false];
    self->start = [NSDate date];
    [self _timer];
    [self _trackEndReached];
}
- (void) _trackEndReached {
    currentIdx++;
    if(currentIdx >= files.count) {
        [self.recBtn setEnabled:true];
        [self.startBtn setEnabled:true];
        [self.tapelen setEnabled:true];
        [self.statis setStringValue:@"Finished. Enjoy :)"];
        [self.header setStringValue:@"AIEdit"];
        [self notifyWithTitle:@"Copying finished!" andText:@"Finished copying to tape."];
        cur = nil;
        start = nil;
        [self.filetable reloadData];
        return;
    }
    AITapeTrack*t  = files[currentIdx];
    if (t.predictedSide != currentSide) {
        [self.statis setStringValue:@"Waiting for Side B start..."];
        start = nil;
        [self.header setStringValue:@"AIEdit"];
        [self notifyWithTitle:@"Side A finished!" andText:@"Please flip the tape and record the side B"];
        [self.startBtn setEnabled:true];
        return;
    }
    cur = t.player;
    [cur prepareToPlay];
    [cur play];
    [cur setDelegate:self];
    [cur setMeteringEnabled:true];
    [self.filetable reloadData];
    [self _meter];
    
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
- (IBAction)start2:(id)sender {
    currentSide=SideB;
    currentIdx--;
    start = [NSDate date];
    [self _timer];
    [self.statis setStringValue:@"Recording side B..."];
    [self.startBtn setEnabled:false];
    [self _trackEndReached];
}
- (void) _meter {
    if (cur) {
        [cur updateMeters];
        [self.bar1 setDoubleValue:([cur averagePowerForChannel:0]*100)/4];
        [self.bar2 setDoubleValue:([cur averagePowerForChannel:1]*100)/4];
         [self performSelector:@selector(_meter) withObject:nil afterDelay:0.1];
    }
}
- (NSString *)timeFormatted:(int)totalSeconds
{
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
}
- (IBAction)gap:(NSButton *)sender {
    AVAudioGapPlayer*g = [[AVAudioGapPlayer alloc]initWithDelegate:self length:sender.tag];
    [self _addFromAudioPlayer:g file:nil];
}
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // server is running, better cleanup...
    if (cur && [cur isPlaying]) {
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
- (void) _addFromAudioPlayer: (AVAudioPlayer*)p file:(NSURL*)file{
    [p prepareToPlay];
    AITapeTrack*t = [AITapeTrack new];
    if (precalcMinutes + (p.duration/60) > self.tapelen.floatValue) {
        NSAlert* msgBox = [[NSAlert alloc] init] ;
        [msgBox setMessageText: [NSString stringWithFormat:NSLocalizedString(@"Cannot add %@ to tracklist", @"error message"),[file pathComponents].lastObject ]];
        [msgBox setInformativeText:[NSString stringWithFormat:NSLocalizedString(@"It's length is %@, but you only have %@ left.", @"error description"), [self timeFormatted:p.duration], [self timeFormatted:(self.tapelen.integerValue*60 - (precalcMinutes*60))]]];
        [msgBox addButtonWithTitle: @"OK"];
        [msgBox runModal];
    } else {
        [t setPlayer:p];
        if (precalcMinutes + (p.duration/60) > self.tapelen.floatValue/2)
            [t setPredictedSide:SideB];
        else
            [t setPredictedSide:SideA];
        [t setFname: ([p isKindOfClass:[AVAudioGapPlayer class]] ? @"Gap" : [file pathComponents].lastObject)];
        [t setDurStr: [self timeFormatted:p.duration]];
        [files addObject:t];
        precalcMinutes += (p.duration/60);
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
            }
        }
        
    }
}
- (void) _fillMeters {
    float Aside = 0;
    float Bside = 0;
    for (AITapeTrack*t in files) {
        if(t.predictedSide == SideA) Aside += t.player.duration/60;
         if(t.predictedSide == SideB) Bside += t.player.duration/60;
    }
    [self.fma setDoubleValue:MIN(1, Aside / (self.tapelen.floatValue/2))]; [self.fmb setDoubleValue:MIN(1, Bside / (self.tapelen.floatValue/2))];
    [self.remainA setStringValue: [NSString stringWithFormat:@"-%@", [self timeFormatted: ((self.tapelen.floatValue/2) - Aside) * 60]]];
    [self.remainB setStringValue: [NSString stringWithFormat:@"-%@", [self timeFormatted: ((self.tapelen.floatValue/2) - Bside) * 60]]];
    
    
}
- (IBAction)rem:(id)sender {
    if(self.filetable.selectedRow > files.count-1 || self.filetable.selectedRow < 0 || cur == ((AITapeTrack*)files[self.filetable.selectedRow]).player) return;
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
        return (cur == t.player ? @"→" : @"");
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
            
        default:
            break;
    }

}

- (IBAction)transportComChg:(id)sender {
    if (![[self.portList selectedItem].title isEqualToString:@"Select control port"]) {
        for (ORSSerialPort*pt  in [[ORSSerialPortManager sharedSerialPortManager]availablePorts]) {
            if ([pt.name isEqualToString:[self.portList.selectedItem title]]) {
                deck = nil;
                deck = [[AKPioneerTapeRecorder alloc]initWithSerialPort:pt];
                [[NSUserDefaults standardUserDefaults]setObject:[self.portList.selectedItem title] forKey:@"Transport"];
            }
        }
    }
}
@end
