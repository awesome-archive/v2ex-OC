//
//  WTUserInfoViewController.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/3/18.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//  用户主题控制器

#import "WTUserInfoViewController.h"
#import "WTURLConst.h"
#import "WTUser.h"
#import "WTAccountViewModel.h"
#import "WTUserViewModel.h"
#import "UIImage+Extension.h"
#import "WTReplyTopicViewController.h"
#import "WTUserTopicViewController.h"
#import "WTHomePageViewController.h"
#import "UIImageView+WebCache.h"
@interface WTUserInfoViewController ()

@end

@implementation WTUserInfoViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 加载用户信息
    [self loadUserInfo];
    
    // 添加子控件器
    [self addChildViewControllers];;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];
    [self.navigationController.navigationBar setBackgroundImage: [UIImage imageNamed:@"nav_background"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
}

#pragma mark - 添加子控制器
- (void)addChildViewControllers
{
    // 0、用户主页控制器
//    WTHomePageViewController *homePageVC = [WTHomePageViewController new];
//    {
//        homePageVC.title = @"主页";
//        [self addChildViewController: homePageVC];
//    }
    
    // 1、用户主题控制器
    WTUserTopicViewController *userTopicVC = [WTUserTopicViewController new];
    {
        userTopicVC.title = @"主题";
        [self addChildViewController: userTopicVC];
        userTopicVC.urlString = [WTMeTopicUrl stringByReplacingOccurrencesOfString: @"misaka14" withString: self.username];
    }
    
    // 2、回复主题控制器
    WTReplyTopicViewController *replyTopicVC = [WTReplyTopicViewController new];
    {
        replyTopicVC.title = @"回复";
        [self addChildViewController: replyTopicVC];
        replyTopicVC.username = self.username;
    }
}

#pragma mark - 加载用户信息
- (void)loadUserInfo
{
    // 设置个人头像
   // self.personIconImage = [UIImage imageNamed:@"icon"];
    
    // 设置个人明信片
    self.personCardImage = [UIImage imageNamed:@"111"];
    
    // 判断是本人信息还是别人的信息
    self.username = self.username ? self.username : [WTAccountViewModel shareInstance].account.usernameOrEmail;
    
    // 用户名
    self.personName = self.username;
    
    // 设置导航条标题
    self.navigationController.title = self.username;
    
    self.title = self.username;
    
    // 加载用户信息
    [WTUserViewModel loadUserInfoWithUsername: self.username success:^(WTUserViewModel *userViewModel) {
        
        // 加载头像
        [self.personIconView sd_setImageWithURL: userViewModel.iconURL placeholderImage: [UIImage imageNamed: @"icon"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            self.personIconView.image = [image roundImage];
        }];
        
        
    } failure:^(NSError *error) {
        WTLog(@"error:%@", error)
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    [super setUpNav];
}

@end
