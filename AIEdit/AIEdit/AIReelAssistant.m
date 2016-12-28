//
//  AIReelAssistant.m
//  AIEdit
//
//  Created by Akasaka Ryuunosuke on 31/07/15.
//  Copyright (c) 2015 Akasaka Ryuunosuke. All rights reserved.
//

#import "AIReelAssistant.h"

@interface AIReelAssistant ()

@end

@implementation AIReelAssistant
- (void)awakeFromNib {
    [super awakeFromNib];
    [self recalc];
    [self.inplen setDelegate:self];
}
- (IBAction)lenChange:(id)sender {
    [self recalc];
}
- (IBAction)speedchange:(id)sender {
    [self recalc];
}

- (void) recalc {
    float total = 0;
    float cmps =9.53f* pow(2, self.inpspeed.selectedRow);
    float metres = self.inplen.floatValue;
    total = (metres*100);
    total /= cmps;
    total /= 60;
    total *= 2;
    [self.total setStringValue:[NSString stringWithFormat:total < 1 ? @"Total: %.02f min." : @"Total: %.00f min.",total]];
}

- (void) controlTextDidChange: (NSNotification *)note {
    [self recalc];
}
@end
