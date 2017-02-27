//
//  NSDate+UTCDateString.h
//  SmartStudy
//
//  Created by song on 15/9/29.
//  Copyright (c) 2015年 Innobuddy Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (UTCDateString)
-(NSString *)UTCDateString;
+ (NSDate*)dateWithUTCDateString:(NSString*)dateString;
@end
