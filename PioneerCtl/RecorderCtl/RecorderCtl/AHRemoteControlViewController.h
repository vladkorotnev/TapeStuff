//
//  AHRemoteControlViewController.h
//  RecorderCtl
//
//  Created by Akasaka Ryuunosuke on 15/05/14.
//  Copyright (c) 2014 Akasaka Ryuunosuke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AHRemoteControlViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *ipField;
- (IBAction)btnPress:(UIButton *)sender;
@end
