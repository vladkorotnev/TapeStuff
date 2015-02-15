//
//  AITapeTrack.m
//  AIEdit
//
//  Created by Akasaka Ryuunosuke on 06/04/14.
//  Copyright (c) 2014 Akasaka Ryuunosuke. All rights reserved.
//

#import "AITapeTrack.h"
#import "AVAudioGapPlayer.h"
@interface AVAudioPlayer (NSCoding) <NSCoding>
- (id) initWithCoder:(NSCoder*)aCoder;
- (void) encodeWithCoder:(NSCoder*)aCoder;
@end
@implementation AVAudioPlayer (NSCoding)

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder setValue:self.url forKey:@"file"];
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [self initWithContentsOfURL:[aDecoder decodeObjectForKey:@"file"] error:nil];
    return  self;
}

@end

@implementation AITapeTrack
- (NSString*)description {
    return [NSString stringWithFormat:@"<%@ on %@ duration %@>", self.fname,(self.predictedSide == SideB ? @"Side B" : @"Side A"), self.durStr];
}
- (id) init {
    self  = [super init];
    if (self) {
        self.equalizer = [@[@0.0f,@0.0f,@0.0f,@0.0f,@0.0f,@0.0f,@0.0f,@0.0f,@0.0f,@0.0f] mutableCopy];
        self.level = 1.0f;
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.url forKey:@"player"];
    [aCoder encodeObject:[NSNumber numberWithInt:self.predictedSide] forKey:@"side"];
    [aCoder encodeObject:self.durStr forKey:@"dur"];
    [aCoder encodeObject:self.fname forKey:@"fname"];
    [aCoder encodeObject:self.equalizer forKey:@"equalizer"];
     [aCoder encodeObject:[NSNumber numberWithFloat:self.dur] forKey:@"duration"];
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super init]) {
        NSURL *uri = [aDecoder decodeObjectForKey:@"player"];
        self.durStr = [aDecoder decodeObjectForKey:@"dur"];
        
        
        self.dur = [[aDecoder decodeObjectForKey:@"duration"]floatValue];
        NSLog(@"Dur %f", self.dur);
        if (self.dur == 0) {
            AVAudioPlayer * sound = [[AVAudioPlayer alloc] initWithContentsOfURL:self.url error:nil];
            self.dur = sound.duration;
            NSLog(@"Neu Dur %f", self.dur);
        }
        
         NSLog(@"Project parser found %@", uri.absoluteString);
        if ([[uri scheme] hasPrefix:@"gap"] || uri == nil) {
           
            self.player = [[AVAudioGapPlayer alloc]initWithDelegate:nil length:self.dur];
        } else {
            self.url = uri;
        }
        NSLog(@"Decoded %@ or %@",self.url, self.player);
        self.predictedSide = [[aDecoder decodeObjectForKey:@"side"]intValue];
        
        
        self.fname = [aDecoder decodeObjectForKey:@"fname"];
        self.equalizer = [[aDecoder decodeObjectForKey:@"equalizer"]mutableCopy];
    }
    return self;
}
- (NSArray*) equalizationWithApplyingGlobalValues:(NSArray*)values {
    NSMutableArray *sas = [NSMutableArray arrayWithCapacity:10];
    for(int i = 0; i <10; i++) {
        sas[i] = [NSNumber numberWithFloat:MIN(15,MAX(-15,[self.equalizer[i] floatValue] + [values[i] floatValue]))];
    }
    return sas;
}
@end
