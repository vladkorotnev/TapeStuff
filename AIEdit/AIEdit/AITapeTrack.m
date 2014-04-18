//
//  AITapeTrack.m
//  AIEdit
//
//  Created by Akasaka Ryuunosuke on 06/04/14.
//  Copyright (c) 2014 Akasaka Ryuunosuke. All rights reserved.
//

#import "AITapeTrack.h"

@implementation AITapeTrack
- (NSString*)description {
    return [NSString stringWithFormat:@"<%@ on %@ duration %@>", self.fname,(self.predictedSide == SideB ? @"Side B" : @"Side A"), self.durStr];
}
@end
