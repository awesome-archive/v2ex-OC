//
//  AppDelegate.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/1/13.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "AppDelegate.h"
#import "WTTabBarController.h"
#import "WTAccount.h"
#import "NSString+Regex.h"
// =============
#import "WTAccountTool.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // 1、创建窗口
    self.window = [[UIWindow alloc] initWithFrame: [UIScreen mainScreen].bounds];
    
    // 2、设置根控制器
    self.window.rootViewController = [WTTabBarController new];
    // 3、显示窗口
    [self.window makeKeyAndVisible];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
   
    
    // 如果之前登陆过，就自动登录
    if ([[WTAccount shareAccount] isLogin])
    {
        WTAccountParam *param = [WTAccountParam new];
        {
            param.u = [WTAccount shareAccount].usernameOrEmail;
            param.p = [WTAccount shareAccount].password;
        }
        [WTAccountTool loginWithParam: param success:^{
            
        } failure:^(NSError *error) {
            
        }];
    }
    return YES;
}

@end
