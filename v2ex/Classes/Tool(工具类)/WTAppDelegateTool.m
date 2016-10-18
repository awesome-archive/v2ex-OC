//
//  WTAppDelegateTool.m
//  v2ex
//
//  Created by gengjie on 16/9/24.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTAppDelegateTool.h"
#import <RongIMKit/RongIMKit.h>

#import "WTFPSLabel.h"
#import "WTTopWindow.h"
#import "WTShareSDKTool.h"
#import <Bugly/Bugly.h>
#import "IQKeyboardManager.h"
#import "WTTopicDetailViewController.h"

@implementation WTAppDelegateTool


/**
 初始化第三方SDK
 */
+ (void)initAppSDK
{
    // 1、键盘呼出隐藏
    [IQKeyboardManager sharedManager].enable = YES;
    
    // 2、分享SDK
    [WTShareSDKTool initShareSDK];
    

    
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
    
    
    // 3、初始化融云
    //[WTAppDelegateTool initRCIM];
    
    // 4、腾讯Buglye
    [Bugly startWithAppId:@"adabbd65ef"];
}

/**
 设置3D Touch按钮
 
 @param application application
 */
+ (void)setup3DTouchItems:(UIApplication *)application
{
    UIApplicationShortcutItem *publishTopicItem = [[UIApplicationShortcutItem alloc] initWithType: @"publishTopicItem" localizedTitle: @"发表话题" localizedSubtitle: @"" icon: [UIApplicationShortcutIcon iconWithTemplateImageName: @"3dTouch_Icon_Add"] userInfo: nil];
    UIApplicationShortcutItem *hotTopicItem = [[UIApplicationShortcutItem alloc] initWithType: @"hotTopicItem" localizedTitle: @"热门话题" localizedSubtitle: @"" icon: [UIApplicationShortcutIcon iconWithTemplateImageName: @"3dTouch_Icon_Hot"] userInfo: nil];
    UIApplicationShortcutItem *notificationItem = [[UIApplicationShortcutItem alloc] initWithType: @"notificationItem" localizedTitle: @"消息" localizedSubtitle: @"" icon: [UIApplicationShortcutIcon iconWithTemplateImageName: @"3dTouch_Icon_Notification"] userInfo: nil];
    application.shortcutItems = @[notificationItem, hotTopicItem, publishTopicItem];
}

/**
 *  查找出view里面的所有scrollView
 */
+ (void)searchAllScrollViewsInView:(UIView *)view
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

/**
 *  初始化融云
 */
+ (void)initRCIM
{
    [[RCIM sharedRCIM] initWithAppKey:@"ik1qhw0911lep"];
    
    [[RCIM sharedRCIM] connectWithToken:@"5FVhtz+r/klA0CcIp15yTluDsCLSc3F6u5FW34vAd9UufPHenWZiUmKJ0nx5tPt3/6aC6bJuMVBUIIlf7wppFw==" success:^(NSString *userId) {
        WTLog(@"登陆成功。当前登录的用户ID：%@", userId);
    } error:^(RCConnectErrorCode status) {
        WTLog(@"登陆的错误码为:%ld", status);
    } tokenIncorrect:^{
        //token过期或者不正确。
        //如果设置了token有效期并且token过期，请重新请求您的服务器获取新的token
        //如果没有设置token有效期却提示token错误，请检查您客户端和服务器的appkey是否匹配，还有检查您获取token的流程。
        WTLog(@"token错误");
    }];
}


/**
 openURL

 @param url url
 */
+ (void)openURL:(NSURL *)url
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
            NSString *topicDetailPrefix = @"v2exclient://skip=topicDetail?urlString=";
            WTLog(@"topicDetail");
            NSString *topicDetailUrl = [[url absoluteString] substringFromIndex: topicDetailPrefix.length];
            
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                WTTopicDetailViewController *topicDetailVC = [WTTopicDetailViewController new];
                topicDetailVC.topicDetailUrl = topicDetailUrl;
                [[WTAppDelegateTool currentNavigationController] pushViewController:topicDetailVC animated: YES];
//            });
            
        }
    }
}

/**
 获取当前显示的控制器
 
 */
+ (UIViewController *)currentViewController
{
    UIWindow *keyWindow  = [UIApplication sharedApplication].keyWindow;
    
    UIViewController *currentVC = [self getCurrentVC: keyWindow.rootViewController];
    return currentVC;
}

+ (UIViewController *)getCurrentVC:(UIViewController *)vc
{
    if ([vc isKindOfClass: [UITabBarController class]])
    {
        UITabBarController *tabVC = (UITabBarController *)vc;
        UIViewController *selectVC = tabVC.selectedViewController;
        return [self getCurrentVC: selectVC];
    }
    else if([vc isKindOfClass: [UINavigationController class]])
    {
        UINavigationController *navVC = (UINavigationController *)vc;
        UIViewController *topVC = navVC.topViewController;
        return [self getCurrentVC: topVC];
    }
    else if(vc.presentedViewController)
    {
        UIViewController *presentedVC = vc.presentedViewController;
        return [self getCurrentVC: presentedVC];
    }
    
    return vc;
}

/**
 获取当前显示的导航控制器
 
 */
+ (UINavigationController *)currentNavigationController;
{
    return [self currentViewController].navigationController;
}
@end
