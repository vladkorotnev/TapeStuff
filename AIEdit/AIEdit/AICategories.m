//
//  AICategories.m
//  AIEdit
//
//  Created by Akasaka Ryuunosuke on 28/12/15.
//  Copyright (c) 2015 Akasaka Ryuunosuke. All rights reserved.
//

#import "AICategories.h"

@implementation NSString (datetime)

+ (NSString*) stringWithTimeInterval:(int)interval
{
    
    int seconds = interval % 60;
    int minutes = (interval / 60) % 60;
    int hours = interval / 3600;
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
}

@end