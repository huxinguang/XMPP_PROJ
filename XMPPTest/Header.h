//
//  Header.h
//  test
//
//  Created by huxinguang on 16/4/22.
//  Copyright © 2016年 hxg. All rights reserved.
//

#import "AppDelegate.h"

#ifndef Header_h
#define Header_h


#endif /* Header_h */



// 版本
#define SystemVersion               [[[UIDevice currentDevice] systemVersion] floatValue]
#define AppVersion                  [[[NSBundle mainBundle]infoDictionary] objectForKey:@"CFBundleShortVersionString"]
#define IsIOS7                      ([[[UIDevice currentDevice] systemVersion] floatValue] >=7.0 ? YES : NO)
#define IsIOS8                      ([[[UIDevice currentDevice] systemVersion] floatValue] >=8.0 ? YES : NO)
#define IsIOS9                      ([[[UIDevice currentDevice] systemVersion] floatValue] >=9.0 ? YES : NO)

// 系统单例
#define kAppDelegate                ((AppDelegate *)[[UIApplication sharedApplication] delegate])
#define UserDefaults                [NSUserDefaults standardUserDefaults]
#define NotiCenter                  [NSNotificationCenter defaultCenter]
#define SharedApplication           [UIApplication sharedApplication]

// 尺寸
#define ScreenWidth                 [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight                [[UIScreen mainScreen] bounds].size.height
#define NavBarHeight                64

// 颜色
#define ColorA(r, g, b, a)          [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define Color(r, g, b)               ColorA(r, g, b, 1.0f)
#define ClearColor                  [UIColor clearColor]

// 字体
#define DefaultFont(size)           [UIFont systemFontOfSize: size]
#define DefaultFontBold(size)       [UIFont boldSystemFontOfSize: size]

// 图片
#define Image(name)                 [UIImage imageNamed:name]
#define ImageResource(name,type)    [[NSBundle mainBundle] pathForResource:name ofType:type]
