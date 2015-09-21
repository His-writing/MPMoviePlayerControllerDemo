//
//  MacroCommon.m
//  knowZhengzhou
//
//  Created by shuzhenguo on 15/8/5.
//  Copyright (c) 2015年 hongkunpeng. All rights reserved.
//

#import "MacroCommon.h"
#import "Reachability.h"
@implementation MacroCommon

//判断网络类型
+(NSString *)getCurrntNet
{
    NSString *networkType=nil;
    Reachability *reachability = [Reachability reachabilityWithHostName:@"www.apple.com"];
    switch ([reachability currentReachabilityStatus]) {
        case NotReachable:
            
            networkType=@"当前网络不可用，请检查您的网络连接。";
            break;
        case ReachableViaWWAN:
            networkType=@"您当前使用的是蜂窝数据";
            break;
        case ReachableViaWiFi:
            networkType=@"您在使用WiFi网络";
            break;
    }
    return networkType;
}


//密码
+ (BOOL) validatePassword:(NSString *)passWord
{
    NSString *passWordRegex = @"^(?=.*?[a-zA-Z])(?=.*?[0-9])[a-zA-Z0-9]{8,20}$";
    NSPredicate *passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",passWordRegex];
    return [passWordPredicate evaluateWithObject:passWord];
}




@end
