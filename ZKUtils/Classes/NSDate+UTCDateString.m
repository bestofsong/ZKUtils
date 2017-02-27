//
//  NSDate+UTCDateString.m
//  SmartStudy
//
//  Created by song on 15/9/29.
//  Copyright (c) 2015年 Innobuddy Inc. All rights reserved.
//

#import "NSDate+UTCDateString.h"

#define UTCDateFormat @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"

@implementation NSDate (UTCDateString)

-(NSString *)UTCDateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:UTCDateFormat];
    NSString *dateString = [dateFormatter stringFromDate:self];
    return dateString;
}

+ (NSDate*)dateWithUTCDateString:(NSString*)dateString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:UTCDateFormat];
    
    return [dateFormatter dateFromString:dateString];
}

@end
