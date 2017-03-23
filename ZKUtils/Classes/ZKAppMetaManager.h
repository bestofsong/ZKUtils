//
//  ZKAppMetaManager.h
//  SmartStudy
//
//  Created by wansong.mbp.work on 7/19/16.
//  Copyright © 2016 Innobuddy Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZKAppMetaManager : NSObject

+ (NSString *) appVersion;
+ (NSString *) build;
+ (NSString *)appName;
+ (NSString*)bundleName;

+ (instancetype)sharedInstance;
- (BOOL)newInstalled;

@end
