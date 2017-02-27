//
//  CookieManager.h
//  SmartStudy
//
//  Created by song on 15/9/29.
//  Copyright (c) 2015年 Innobuddy Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CookieManager : NSObject

- (nonnull NSString*)cookieStringWithAppVersionStr:(NSString*)versionStr
                                   appName:(NSString*)name
                              buildVersion:(NSNumber*)versionCode
                             updateVersion:(NSNumber*)updateVersion;

- (NSString*)cookieStringWithAppVersionStr:(NSString*)versionStr
                                appName:(NSString*)name
                            buildVersion:(NSNumber*)buildVersion
                          updateVersion:(NSNumber*)updateVersion
                               deleteCache:(BOOL)deleteCache;

- (NSString*)cookieString;

+ (nullable NSString*)cookieUUID;

+ (nonnull instancetype)sharedCookieManager;

- (BOOL)removeCache:(NSError * _Nullable *_Nullable)error;

@end
