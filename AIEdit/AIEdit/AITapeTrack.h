//
//  AITapeTrack.h
//  AIEdit
//
//  Created by Akasaka Ryuunosuke on 06/04/14.
//  Copyright (c) 2014 Akasaka Ryuunosuke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
enum TapeSide {
    SideA,
    SideB
};
@interface AITapeTrack : NSObject  <NSCoding>
@property (nonatomic) AVAudioPlayer * player;
@property (nonatomic) enum TapeSide predictedSide;
@property (nonatomic) NSString* durStr;
@property (nonatomic) NSString* fname;
@property (nonatomic) NSMutableArray* equalizer;
@property (nonatomic) NSURL* url;
@property (nonatomic) NSTimeInterval dur;
@property (nonatomic) float pan;
@property (nonatomic) float level;
- (NSArray*) equalizationWithApplyingGlobalValues:(NSArray*)values;
@end
