//
//  AHRemoteControlViewController.m
//  RecorderCtl
//
//  Created by Akasaka Ryuunosuke on 15/05/14.
//  Copyright (c) 2014 Akasaka Ryuunosuke. All rights reserved.
//

#import "AHRemoteControlViewController.h"

@interface AHRemoteControlViewController ()

@end

@implementation AHRemoteControlViewController

- (IBAction)ipFieldDeoe:(id)sender {
    [[NSUserDefaults standardUserDefaults]setObject:self.ipField.text forKey:@"IP"];
    
}
- (IBAction)btnPress:(UIButton *)sender {
    NSString*url = [NSString stringWithFormat:@"http://%@:9898/%@", self.ipField.text, @[@"stop",@"power",@"rewind",@"play",@"forward",@"record",@"pause"][sender.tag]];
    NSURLRequest   *r = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSURLConnection * c = [NSURLConnection connectionWithRequest:r delegate:self];
    [c start];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"IP"]) {
        self.ipField.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"IP"];
    } else {
       [self.ipField becomeFirstResponder];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
