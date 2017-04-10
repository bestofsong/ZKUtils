//
//  CookieManager.m
//  SmartStudy
//
//  Created by song on 15/9/29.
//  Copyright (c) 2015年 Innobuddy Inc. All rights reserved.
//

#import "CookieManager.h"
#import "NSDate+UTCDateString.h"
#import "ZKAppMetaManager.h"

#define kCookieId @"cookie_id"
#define kFirstTime @"first_time"
#define kHmsr @"hmsr"
#define kSite @"site"

#define kCookieLongevity (3.0 * 24.0 * 3600.0)
@implementation CookieManager

+ (instancetype)sharedCookieManager {
  static dispatch_once_t onceToken;
  static CookieManager *ret = nil;
  dispatch_once(&onceToken, ^{
    ret = [CookieManager new];
    if ([[ZKAppMetaManager sharedInstance] newInstalled]) {
      [ret removeCache:NULL];
    }
  });
  return ret;
}

- (NSString*)cookieString {
  return [self cookieStringWithAppVersionStr:[ZKAppMetaManager appVersion]
                                  appName:@"zhike"
                              buildVersion:@([ZKAppMetaManager build].integerValue)
                            updateVersion:nil];
}

- (NSString*)cookieStringWithAppVersionStr:(NSString*)versionStr
                                appName:(NSString*)name
                            buildVersion:(NSNumber*)buildVersion
                          updateVersion:(NSNumber*)updateVersion {
  
  return [self cookieStringWithAppVersionStr:versionStr
                                     appName:name
                                buildVersion:buildVersion
                               updateVersion:updateVersion
                                 deleteCache:NO];
}

- (BOOL)removeCache:(NSError**)error {
  NSFileManager *fm = [NSFileManager defaultManager];
  NSString *filePath = [[self class] filePath];
  if ([fm fileExistsAtPath:filePath] && ![fm removeItemAtPath:filePath error:error]) {
    NSLog(@"failed to remove cookie cache at(%@), error: %@", [[self class] filePath], error ? *error : @"");
    return NO;
  } else {
    return YES;
  }
}

- (NSString*)cookieStringWithAppVersionStr:(NSString*)versionStr
                                appName:(NSString*)name
                            buildVersion:(NSNumber*)buildVersion
                          updateVersion:(NSNumber*)updateVersion
                               deleteCache:(BOOL)deleteCache {
  if (deleteCache) {
    [self removeCache:NULL];
  }
  
  if (!versionStr) {
    versionStr = [ZKAppMetaManager appVersion];
  }
  
  if (!buildVersion) {
    buildVersion = @([ZKAppMetaManager build].integerValue);
  }
  
  NSString *cpsInfo = @"cpsInfo=";
  NSDictionary *cokkie = [[self class] cookieWithVersion:versionStr
                                                 appName:name
                                             buildVersion:buildVersion
                                           updateVersion:updateVersion];
  
  NSError *error = nil;
  NSData *data = [NSJSONSerialization dataWithJSONObject:cokkie
                                                 options:0
                                                   error:&error];
  if (error) {
    NSLog(@"无法json序列化该对象: %@", cokkie);
    return nil;
  }
  
  NSString *dataString = [[NSString alloc] initWithData:data
                                               encoding:NSUTF8StringEncoding];
  
  return [cpsInfo stringByAppendingString:dataString];
  
}

+ (NSDictionary*)cookieWithVersion:(NSString*)versionStr
                           appName:(NSString*)name
                       buildVersion:(NSNumber*)buildVersion
                     updateVersion:(NSNumber*)updateVersion {
  
  NSString *filePath = [self filePath];
  NSDictionary *ret = [self readCookieFromFile];
  if (ret) {
    return ret;
  }
  
  NSMutableDictionary *newCookie = [NSMutableDictionary dictionary];
  [newCookie setObject:[[NSDate date] UTCDateString] forKey:kFirstTime];
  
  NSString *uuidString = [[NSUUID UUID] UUIDString];
  
  [newCookie setObject:uuidString forKey:kCookieId];
  
  [newCookie setObject:[self getHmsr] forKey:kHmsr];
  
  [newCookie setObject:
   [self getSiteWithVersion:versionStr
                    appName:name
               buildVersion:buildVersion
              updateVersion:updateVersion]
                forKey:kSite];
  
  [newCookie setObject:updateVersion ?: buildVersion forKey:@"versionCode"];
  
  BOOL saveRet = [newCookie writeToFile:filePath atomically:YES];
  if (!saveRet) {
    NSAssert(false, @"");
  }
  
  return newCookie;
}

+ (NSDictionary*)readCookieFromFile {
  NSString *filePath = [self filePath];
  NSFileManager *fm = [NSFileManager defaultManager];
  NSDictionary *ret = nil;
  
  if ([fm fileExistsAtPath:filePath]) {
    ret = [NSDictionary dictionaryWithContentsOfFile:filePath];
    if (ret && ret[kFirstTime] && ![self isExpired:ret[kFirstTime]]) {
      return ret;
    }
  }
  return nil;
}

+ (nullable NSString*)cookieUUID {
  NSDictionary *cookieObj = [self readCookieFromFile];
  return cookieObj[kCookieId];
}

+ (NSString*)getSiteWithVersion:(NSString*)versionStr
                        appName:(NSString*)name
                   buildVersion:(NSNumber*)build
                  updateVersion:(NSNumber*)updateVersion {
  if (updateVersion) {
    return [NSString stringWithFormat:@"%@_ios_v%@build%@update%@",
            name, versionStr, build, updateVersion];
  }else {
    return [NSString stringWithFormat:@"%@_ios_v%@build%@",
            name, versionStr, build];
  }
}

+ (NSString*)getHmsr {
    return @"AppStore";
}

+ (BOOL)isExpired:(NSString*)dateString {
    NSDate *createDate = [NSDate dateWithUTCDateString:dateString];
    NSTimeInterval age = [[NSDate date] timeIntervalSinceDate:createDate];
    return age > kCookieLongevity;
}

+ (NSString*)filePath {
    NSArray *libFolder = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSAssert(libFolder.count > 0, @"");
    NSString *folder = libFolder[0];
    return [folder stringByAppendingPathComponent:@"zhike.cookie"];
}
@end
