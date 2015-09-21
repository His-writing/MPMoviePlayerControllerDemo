//
//  MacroCommon.h
//  knowZhengzhou
//
//  Created by shuzhenguo on 15/8/5.
//  Copyright (c) 2015年 hongkunpeng. All rights reserved.
//

#import <Foundation/Foundation.h>


#define kDeviceHeight [UIScreen mainScreen].bounds.size.height
#define kDeviceWidth  [UIScreen mainScreen].bounds.size.width

#define UIColorFromRGBWithAlpha(rgbValue,a) [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:a]

#define blackRGB UIColorFromRGBWithAlpha(0x22292c,1)

#define RGB(R,G,B) [UIColor colorWithRed:R/255.0f green:G/255.0f blue:B/255.0f alpha:1.0f]

#define grayRGB   [UIColor colorWithRed:208/255.0 green:208/255.0 blue:208/255.0 alpha:0.7]

#define grayRGBO   [UIColor colorWithRed:208/255.0 green:208/255.0 blue:208/255.0 alpha:1.0]

#define grayShareRGB  [UIColor colorWithRed:223/255.0 green:223/255.0 blue:223/255.0 alpha:1.0]

#define grayClickRGB   [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.5]


#define grayCommentsRGB [UIColor colorWithRed:228/255.0 green:228/255.0 blue:228/255.0 alpha:1.0]


//远程推送yes 删除  no 添加
#define REMOTEPUSH  @"REMOTEPUSH"
//Token
#define DEVICETOKENUISWITCH @"DEVICETOKENUISwitch"

//存账户的SESSION
#define SESSIONUSERDEFAULTSION @"SESSIONUSERDEFAULTSION"

#define kWBAppKey  @"3676860592"

#define kWBRedirectURL @"http://zhengzhou.app.china.com/"

#define kQQAppkey  @"1104790224"



#define kWeixinSDKAppKey  @"wxec3a1fcde0f4afa2"
#define kWeixinSDKDescription @"4f3e96a9a98af87ccdb95edb1f42979d"


//通知

#define WEIBORETURNTHEDATA @"WEIBORETURNTHEDATA"
#define isPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define IS_IPHONE_4 (fabs((double)[[UIScreen mainScreen]bounds].size.height-(double)480)< DBL_EPSILON)
#define  IPhone4   [[UIScreen mainScreen] bounds].size.height==480 &&[[UIScreen mainScreen] bounds].size.width==320||[[UIScreen mainScreen] bounds].size.height==320 &&[[UIScreen mainScreen] bounds].size.width==480
#define IS_IPHONE_5 (fabs((double)[[UIScreen mainScreen]bounds].size.height-(double)568)< DBL_EPSILON)
#define IS_IPHONE_6 (fabs((double)[[UIScreen mainScreen]bounds].size.height-(double)667)< DBL_EPSILON)
#define IS_IPHONE_6_Plus (fabs((double)[[UIScreen mainScreen]bounds].size.height-(double)736)< DBL_EPSILON)



#define VERSION [[UIDevice currentDevice].systemVersion doubleValue]


//缓存路径
#define STORAGE_PATH [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]

#define ConfFile(x) [STORAGE_PATH stringByAppendingPathComponent:x]
@interface MacroCommon : NSObject

+(NSString *)getCurrntNet;

+ (BOOL) validatePassword:(NSString *)passWord;


@end
