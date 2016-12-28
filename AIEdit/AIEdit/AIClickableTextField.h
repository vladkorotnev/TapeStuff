//
//  AIClickableTextField.h
//  AIEdit
//
//  Created by Akasaka Ryuunosuke on 31/07/15.
//  Copyright (c) 2015 Akasaka Ryuunosuke. All rights reserved.
//

#import <Cocoa/Cocoa.h>
typedef enum  {
    AILeftClick, AIRightClick
} AIClickType;
@interface AIClickableTextField : NSTextField

@end

@protocol AIClickableTextFieldDelegate <NSObject>

-(void)textField:(AIClickableTextField*)textField didClick:(AIClickType)click;

@end