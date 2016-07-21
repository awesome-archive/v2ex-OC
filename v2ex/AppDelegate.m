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
   // [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
   
    // 5、键盘呼出隐藏
    [IQKeyboardManager sharedManager].enable = YES;
    
    // 6、自动登陆
    [[WTAccountViewModel shareInstance] autoLogin];
    
    // 7、设置3DTouch
    [self setup3DTouchItems: application];
    
    // 8、分享SDK
//    [WTShareSDKTool initShareSDK];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    // 界面 FPS 代码
    #if DEBUG
        WTFPSLabel *fpsLabel = [[WTFPSLabel alloc] initWithFrame: CGRectMake(15, WTScreenHeight - 40, 55, 50)];
        [self.window addSubview: fpsLabel];
    #else
    
    #endif
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    // 9.显示顶层window
    [WTTopWindow showWithStatusBarClickBlock:^{
        [self searchAllScrollViewsInView: application.keyWindow];
    }];
    
    return YES;
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
