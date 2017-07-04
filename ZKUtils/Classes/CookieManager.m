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
                               updateVersion:nil
                                        site:nil
                                        hmsr:nil];
}

- (NSString*)cookieStringWithAppVersionStr:(NSString*)versionStr
                                   appName:(NSString*)name
                              buildVersion:(NSNumber*)buildVersion
                             updateVersion:(NSNumber*)updateVersion
                                      site:(NSNumber *)site
                                      hmsr:(NSNumber *)hmsr {
  
  return [self cookieStringWithAppVersionStr:versionStr
                                     appName:name
                                buildVersion:buildVersion
                               updateVersion:updateVersion
                                        site:site
                                        hmsr:hmsr
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
                                      site:(NSNumber*)siteId
                                      hmsr:(NSNumber*)hmsr
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
                                           updateVersion:updateVersion
                                                    site:siteId
                                                    hmsr:hmsr];
  
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
  
  NSString *encoded = [dataString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  
  return [cpsInfo stringByAppendingString:encoded];
  
}

+ (NSDictionary*)cookieWithVersion:(NSString*)versionStr
                           appName:(NSString*)name
                       buildVersion:(NSNumber*)buildVersion
                     updateVersion:(NSNumber*)updateVersion
                              site:(NSNumber*)siteId
                              hmsr:(NSNumber*)hmsrId {
  
  NSString *filePath = [self filePath];
  NSDictionary *ret = [self readCookieFromFile];
  if (ret) {
    return ret;
  }
  
  NSMutableDictionary *newCookie = [NSMutableDictionary dictionary];
  [newCookie setObject:[[NSDate date] UTCDateString] forKey:kFirstTime];
  
  NSString *uuidString = [[NSUUID UUID] UUIDString];
  [newCookie setObject:uuidString forKey:kCookieId];
  
  [newCookie setObject:hmsrId ?: @0 forKey:kHmsr];
  [newCookie setObject:siteId ?: @0 forKey:kSite];
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
