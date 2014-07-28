//
//  AVAudioGapPlayer.h
//  AIEdit
//
//  Created by Akasaka Ryuunosuke on 08/04/14.
//  Copyright (c) 2014 Akasaka Ryuunosuke. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface AVAudioGapPlayer : AVAudioPlayer <NSCoding> {
    NSTimeInterval length;
    id<AVAudioPlayerDelegate> del;
}


- (AVAudioGapPlayer*) initWithDelegate: (id<AVAudioPlayerDelegate>)delegate length:(NSTimeInterval)length;
- (void) prepareToPlay;
- (void) play;
@end
