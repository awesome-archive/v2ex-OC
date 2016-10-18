//
//  AppDelegate.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/1/13.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "AppDelegate.h"

#import "WTTabBarController.h"
#import "WTAccountViewModel.h"
#import "WTFPSLabel.h"
#import "WTTopWindow.h"
#import "WTAppDelegateTool.h"
#import "SVProgressHUD.h"
#import "WTTopicDetailViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // 4、自动登录
    [[WTAccountViewModel shareInstance] autoLogin];
    
    // 1、创建窗口
    self.window = [[UIWindow alloc] initWithFrame: [UIScreen mainScreen].bounds];
    
    // 2、设置根控制器
    self.window.rootViewController = [WTTabBarController new];
    
    // 3、显示窗口
    [self.window makeKeyAndVisible];
    
    
    
    // 5、全局设置状态栏颜色
    application.statusBarStyle = UIStatusBarStyleLightContent;
    application.applicationIconBadgeNumber = 0;
    [UITabBar appearance].tintColor = WTLightColor;
    
    // 6、界面 FPS 代码
#if DEBUG
    WTFPSLabel *fpsLabel = [[WTFPSLabel alloc] initWithFrame: CGRectMake(15, WTScreenHeight - 80, 55, 50)];
    [self.window addSubview: fpsLabel];
#else
    
#endif

    // 7、显示顶层window
    [WTTopWindow showWithStatusBarClickBlock:^{
        
        [WTAppDelegateTool searchAllScrollViewsInView: application.keyWindow];
    }];
    
    // 8、设置3DTouch 按钮
    [WTAppDelegateTool setup3DTouchItems: application];
    
    // 9、初始化第三方SDK
    [WTAppDelegateTool initAppSDK];
    
    return YES;
}

#pragma mark - 处理3DTouch点击事件
- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler
{
    NSString *type = shortcutItem.type;
    if ([type isEqualToString: @"publishTopicItem"])
    {
        WTLog(@"发表话题")
    }
    else if([type isEqualToString: @"hotTopicItem"])
    {
        WTLog(@"热门话题")
    }
    else
    {
        WTLog(@"消息")
    }
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    NSString *prefix = @"v2exclient://skip=";
    NSString *urlStr = [url absoluteString];
    
    // 跳转的URL
    if ([urlStr rangeOfString: prefix].location != NSNotFound)
    {
        
        NSString *skip = [urlStr substringFromIndex: prefix.length];
        
        // 跳转至话题详情
        if ([skip containsString: @"topicDetail"])
        {
            [SVProgressHUD showSuccessWithStatus: @"成功进入啦"];
            NSString *topicDetailPrefix = @"v2exclient://skip=topicDetail?urlString=";
            WTLog(@"topicDetail");
            NSString *topicDetailUrl = [[url absoluteString] substringFromIndex: topicDetailPrefix.length];

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                WTTopicDetailViewController *topicDetailVC = [WTTopicDetailViewController new];
                topicDetailVC.topicDetailUrl = topicDetailUrl;
                [[WTAppDelegateTool currentNavigationController] pushViewController:topicDetailVC animated: YES];
            });
            
        }
    }
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSString *action = url.relativePath;
    [SVProgressHUD showSuccessWithStatus: @"openURL下面"];
    WTLog(@"sourceApplication");
    
    return YES;
}



@end
