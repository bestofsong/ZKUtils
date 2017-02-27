//
//  ZKAppMetaManger.m
//  SmartStudy
//
//  Created by wansong.mbp.work on 7/19/16.
//  Copyright © 2016 Innobuddy Inc. All rights reserved.
//

#import "ZKAppMetaManger.h"
#import <UIKit/UIKit.h>

@interface ZKAppMetaManger ()

@end

@implementation ZKAppMetaManger

+ (instancetype)sharedInstance {
  static dispatch_once_t onceToken;
  static ZKAppMetaManger *ret = nil;
  dispatch_once(&onceToken, ^{
    ret = [[ZKAppMetaManger alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:ret selector:@selector(handleAppQuit:) name:UIApplicationWillTerminateNotification object:nil];
  });
  return ret;
}

- (void)handleAppQuit:(NSNotification*)notification {
  [[NSUserDefaults standardUserDefaults] setObject:[[self class] appVersion] forKey:@"last-app-ver"];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *) appVersion
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
}

+ (NSString *) build
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
}

+ (NSString *)appName {
  NSString *ret = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleExecutable"];
  if (!ret) {
    ret = [self bundleName];
  }
  if (!ret) {
    ret = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
  }
  return ret ?: @"";
}

+ (NSString*)bundleName {
  NSBundle *bundle = [NSBundle mainBundle];
  return [bundle objectForInfoDictionaryKey:@"CFBundleName"];
}

- (BOOL)newInstalled {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSString *lastVer = [defaults stringForKey:@"last-app-ver"];
  NSString *currentVew = [[self class] appVersion];
  if ([currentVew isEqualToString:lastVer]) {
    return NO;
  }else {
    return YES;
  }
}

@end
