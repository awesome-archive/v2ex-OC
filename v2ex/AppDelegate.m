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
#import "IQKeyboardManager.h"
#import "WTFPSLabel.h"
#import "WTTopWindow.h"
#import "WTNodeViewModel.h"
#import <RongIMKit/RongIMKit.h>
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
    
    // 4、全局设置状态栏颜色
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [[UITabBar appearance] setTintColor: [UIColor colorWithHexString: WTAppLightColor]];
   
    // 5、键盘呼出隐藏
    [IQKeyboardManager sharedManager].enable = YES;
    
    // 6、自动登陆
//    [[WTAccountViewModel shareInstance] autoLogin];
    
    // 7、设置3DTouch
    [self setup3DTouchItems: application];
    
    // 8、分享SDK
//    [WTShareSDKTool initShareSDK];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    // 界面 FPS 代码
    #if DEBUG
        WTFPSLabel *fpsLabel = [[WTFPSLabel alloc] initWithFrame: CGRectMake(15, WTScreenHeight - 80, 55, 50)];
        [self.window addSubview: fpsLabel];
    #else
    
    #endif

    
    // 9.显示顶层window
    [WTTopWindow showWithStatusBarClickBlock:^{
        [self searchAllScrollViewsInView: application.keyWindow];
    }];
    
    // 10.打印字体
    //    NSArray *familyNames = [UIFont familyNames];
    //    for( NSString *familyName in familyNames )
    //    {
    //        NSArray *fontNames = [UIFont fontNamesForFamilyName:familyName];
    //        for( NSString *fontName in fontNames )
    //        {
    //            printf( "\tFont: %s \n", [fontName UTF8String] );
    //        }
    //    }

    // 11、初始化融云
    [self initRCIM];
    
    
    
    return YES;
}

/**
 *  初始化融云
 */
- (void)initRCIM
{
    [[RCIM sharedRCIM] initWithAppKey:@"ik1qhw0911lep"];
    
    [[RCIM sharedRCIM] connectWithToken:@"5FVhtz+r/klA0CcIp15yTluDsCLSc3F6u5FW34vAd9UufPHenWZiUmKJ0nx5tPt3/6aC6bJuMVBUIIlf7wppFw==" success:^(NSString *userId) {
        NSLog(@"登陆成功。当前登录的用户ID：%@", userId);
    } error:^(RCConnectErrorCode status) {
        NSLog(@"登陆的错误码为:%ld", status);
    } tokenIncorrect:^{
        //token过期或者不正确。
        //如果设置了token有效期并且token过期，请重新请求您的服务器获取新的token
        //如果没有设置token有效期却提示token错误，请检查您客户端和服务器的appkey是否匹配，还有检查您获取token的流程。
        NSLog(@"token错误");
    }];
}


/**
 *  查找出view里面的所有scrollView
 */
- (void)searchAllScrollViewsInView:(UIView *)view
{
    // 如果不在keyWindow范围内（不跟window重叠），直接返回
    if (![view wt_intersectWithView:nil]) return;
    
    // 遍历所有的子控件
    for (UIView *subview in view.subviews) {
        [self searchAllScrollViewsInView:subview];
    }
    
    // 如果不是scrollView，直接返回
    if (![view isKindOfClass:[UIScrollView class]]) return;
    
    // 滚动scrollView
    UIScrollView *scrollView = (UIScrollView *)view;
    CGPoint offset = scrollView.contentOffset;
    offset.y = - scrollView.contentInset.top;
    [scrollView setContentOffset:offset animated:YES];
    
}

#pragma mark - 设置3DTouch
- (void)setup3DTouchItems:(UIApplication *)application
{
    UIApplicationShortcutItem *publishTopicItem = [[UIApplicationShortcutItem alloc] initWithType: @"publishTopicItem" localizedTitle: @"发表话题" localizedSubtitle: @"" icon: [UIApplicationShortcutIcon iconWithTemplateImageName: @"3dTouch_Icon_Add"] userInfo: nil];
    UIApplicationShortcutItem *hotTopicItem = [[UIApplicationShortcutItem alloc] initWithType: @"hotTopicItem" localizedTitle: @"热门话题" localizedSubtitle: @"" icon: [UIApplicationShortcutIcon iconWithTemplateImageName: @"3dTouch_Icon_Hot"] userInfo: nil];
    UIApplicationShortcutItem *notificationItem = [[UIApplicationShortcutItem alloc] initWithType: @"notificationItem" localizedTitle: @"消息" localizedSubtitle: @"" icon: [UIApplicationShortcutIcon iconWithTemplateImageName: @"3dTouch_Icon_Notification"] userInfo: nil];
    application.shortcutItems = @[notificationItem, hotTopicItem, publishTopicItem];
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

@end
