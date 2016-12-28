//
//  AIReelAssistant.h
//  AIEdit
//
//  Created by Akasaka Ryuunosuke on 31/07/15.
//  Copyright (c) 2015 Akasaka Ryuunosuke. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
@interface AIReelAssistant : NSViewController
@property (weak) IBOutlet NSTextField *inplen;
@property (weak) IBOutlet NSMatrix *inpspeed;
@property (weak) IBOutlet NSTextField *total;

@end
