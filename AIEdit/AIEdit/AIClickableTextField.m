//
//  AIClickableTextField.m
//  AIEdit
//
//  Created by Akasaka Ryuunosuke on 31/07/15.
//  Copyright (c) 2015 Akasaka Ryuunosuke. All rights reserved.
//

#import "AIClickableTextField.h"

@implementation AIClickableTextField

- (void) rightMouseDown:(NSEvent *)theEvent {
    //
    if ([self.delegate respondsToSelector:@selector(textField:didClick:)]) {
        id<AIClickableTextFieldDelegate>d = self.delegate;
        [d textField:self didClick:AIRightClick];
    }
    else [super rightMouseDown:theEvent];
    
}
- (void) mouseDown:(NSEvent *)theEvent {
    if ([self.delegate respondsToSelector:@selector(textField:didClick:)]) {
        id<AIClickableTextFieldDelegate>d = self.delegate;
        [d textField:self didClick:AILeftClick];
    } else [super mouseDown:theEvent];
}

@end
