//
//  AIReelRecorder.h
//  AIEdit
//
//  Created by Akasaka Ryuunosuke on 24/07/14.
//  Copyright (c) 2014 Akasaka Ryuunosuke. All rights reserved.
//

#import <Foundation/Foundation.h>
#define TMPDIR [NSTemporaryDirectory() stringByAppendingPathComponent:@"AIEditReelTMP"]
@interface AIReelRecorder : NSObject
+ (AIReelRecorder *)sharedInstance;
- (NSDictionary*) openReelFromFile:(NSURL*)file extractedTo:(NSURL*)folder;
- (NSDictionary*) openReelFromFile:(NSURL*)file;
- (void) createReel:(NSURL*)reel fromTracks:(NSArray*)tracks pData:(NSDictionary*)project;
@end
