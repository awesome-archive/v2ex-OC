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

#import "WTMemberTopicViewModel.h"
#import "WTTopicDetailViewModel.h"

#import "UIImage+Extension.h"

#import "UIImageView+WebCache.h"

@interface WTMemberDetailViewController ()

@property (nonatomic, strong) WTMemberTopicViewModel *memberTopicVM;

@end

@implementation WTMemberDetailViewController

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initView];
    
    [self initData];
}

- (void)initView
{
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

- (void)initData
{
    self.memberTopicVM = [WTMemberTopicViewModel new];
    
    [self.memberTopicVM getMemberItemWithUsername: self.topicDetailVM.topicDetail.author success:^{
        
        
        
    } failure:^(NSError *error) {
        
    }];
}

@end
