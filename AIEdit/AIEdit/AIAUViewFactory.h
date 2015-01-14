//
//  AIAUViewFactory.h
//  AIEdit
//
//  Created by Akasaka Ryuunosuke on 01/01/15.
//  Copyright (c) 2015 Akasaka Ryuunosuke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudio.h>
@interface AIAUViewFactory : NSObject
// dumb drop-in:
- (NSView*)uiViewForAudioUnit:(CAAudioUnit)unit withSize:(NSSize)size;

@end
