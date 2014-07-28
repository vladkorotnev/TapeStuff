//
//  AVAudioGapPlayer.m
//  AIEdit
//
//  Created by Akasaka Ryuunosuke on 08/04/14.
//  Copyright (c) 2014 Akasaka Ryuunosuke. All rights reserved.
//

#import "AVAudioGapPlayer.h"

@implementation AVAudioGapPlayer
- (AVAudioGapPlayer*) initWithDelegate: (id<AVAudioPlayerDelegate>)d length:(NSTimeInterval)len {
    self = [self init];
    if (self) {
        self->del= d;
        self->length = len;
    }
    return self ;
}
- (BOOL) isPlaying { return false;}
- (void) setDelegate:(id<AVAudioPlayerDelegate>)delegate {
    self->del = delegate;
}
- (NSTimeInterval) duration {
    return self->length;
}
- (NSURL*) url {
    return [NSURL URLWithString:[NSString stringWithFormat:@"gap://%f",self->length]];
}
- (NSString*)description {
    return [NSString stringWithFormat:@"<GAP player of %f>",self->length ];
}
- (void)prepareToPlay {}
- (void) play{
    [self performSelector:@selector(_fin) withObject:nil afterDelay:self->length];
}
- (void) _fin {
    [self->del audioPlayerDidFinishPlaying:self successfully:true];
}
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[NSNumber numberWithInteger:length] forKey:@"dur"];
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super init]) {
        length = [[aDecoder decodeObjectForKey:@"dur"]intValue];
    }
    return self;
}
- (void) setMeteringEnabled:(BOOL)meteringEnabled {}
- (float) averagePowerForChannel:(NSUInteger)channelNumber { return -96.0;}
- (void)updateMeters{}
@end
