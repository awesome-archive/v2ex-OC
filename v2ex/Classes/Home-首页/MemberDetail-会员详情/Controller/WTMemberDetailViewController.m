//
//  WTMemberDetailViewController.m
//  v2ex
//
//  Created by gengjie on 16/8/23.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//  会员详情控制器

#import "WTMemberDetailViewController.h"
#import "WTMemberTopicViewController.h"
#import "WTMemberReplyViewController.h"

#import "WTTopicDetailViewModel.h"

#import "UIImage+Extension.h"

#import "UIImageView+WebCache.h"

@interface WTMemberDetailViewController ()

@end

@implementation WTMemberDetailViewController

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 设置个人头像
    [self.personIconView sd_setImageWithURL: self.topicDetailVM.iconURL];
    
    // 1、添加主题控制器
    WTMemberTopicViewController *memberTopicVC = [[WTMemberTopicViewController alloc] init];
    memberTopicVC.title = @"主题";
    memberTopicVC.topicDetailVM = self.topicDetailVM;
    [self addChildViewController: memberTopicVC];
    
    // 2、添加回复控制器
    WTMemberReplyViewController *memberReplyVC = [[WTMemberReplyViewController alloc] init];
    memberReplyVC.title = @"回复";
    memberReplyVC.topicDetailVM = self.topicDetailVM;
    [self addChildViewController: memberReplyVC];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];
    
    /*
     navBar.barTintColor = WTColor(42, 183, 103);
     navBar.translucent = NO;
     */
    // 当设置不透明的图片，效果是如上面的代码，会导致View位移，在控制器里面使用 extendedLayoutIncludesOpaqueBars = YES就行了
    [self.navigationController.navigationBar setBackgroundImage: [UIImage imageWithColor: [UIColor colorWithHexString: WTAppLightColor]] forBarMetrics:UIBarMetricsDefault];
}

@end
