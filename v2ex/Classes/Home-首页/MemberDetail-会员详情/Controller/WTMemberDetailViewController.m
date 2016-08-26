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
#import "POP.h"

@interface WTMemberDetailViewController ()

@property (nonatomic, strong) WTMemberTopicViewModel *memberTopicVM;

@property (nonatomic, strong) NSString *author;

@property (nonatomic, strong) NSURL    *iconURL;

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
    if (self.topicDetailVM == nil)
    {
        self.author = self.topic.author;
        self.iconURL = self.topic.iconURL;
    }
    else
    {
        self.author = self.topicDetailVM.topicDetail.author;
        self.iconURL = self.topicDetailVM.iconURL;
    }
    
    // 设置个人头像
    [self.personIconView sd_setImageWithURL: self.iconURL];
    self.usernameLabel.text = self.author;
    self.detailLabel.alpha = 0;
    self.personIconView.alpha = 0;
    self.usernameLabel.alpha = 0;
    
    // 1、添加主题控制器
    WTMemberTopicViewController *memberTopicVC = [[WTMemberTopicViewController alloc] init];
    memberTopicVC.title = @"主题";
    memberTopicVC.author = self.author;
    memberTopicVC.iconURL = self.iconURL;
    [self addChildViewController: memberTopicVC];
    
    // 2、添加回复控制器
    WTMemberReplyViewController *memberReplyVC = [[WTMemberReplyViewController alloc] init];
    memberReplyVC.title = @"回复";
    memberReplyVC.author = self.author;
    [self addChildViewController: memberReplyVC];
}

- (void)initData
{
    self.memberTopicVM = [WTMemberTopicViewModel new];
    
    __weak typeof(self) weakSelf = self;
    [self.memberTopicVM getMemberItemWithUsername: self.author success:^{
        
        [weakSelf setMemberDetailInfo];
        
    } failure:^(NSError *error) {
        
    }];
}

// 设置用户详细信息
- (void)setMemberDetailInfo
{
    self.detailLabel.text = self.memberTopicVM.memberItem.detail;
    [self.detailLabel sizeToFit];
    
    [self startAnim];
}

// 添加动画
- (void)startAnim
{
    // 1、缩小动画
    POPSpringAnimation *scaleAnim = [POPSpringAnimation animationWithPropertyNamed: kPOPViewScaleXY];
    scaleAnim.springSpeed = 5;
    scaleAnim.springBounciness = 10;
    scaleAnim.fromValue = [NSValue valueWithCGPoint: CGPointMake(1.5, 1.5)];
    scaleAnim.toValue = [NSValue valueWithCGPoint: CGPointMake(1.0, 1.0)];
    
    // 2、透明动画
    POPBasicAnimation *alphaAnim = [POPBasicAnimation animationWithPropertyNamed: kPOPViewAlpha];
    alphaAnim.duration = 0.5;
    alphaAnim.toValue = @1.0;
    
    
    [self.detailLabel pop_addAnimation: scaleAnim forKey: kPOPViewScaleXY];
    [self.detailLabel pop_addAnimation: alphaAnim forKey: kPOPViewAlpha];
    
    [self.usernameLabel pop_addAnimation: scaleAnim forKey:kPOPViewScaleXY];
    [self.usernameLabel pop_addAnimation: alphaAnim forKey: kPOPViewAlpha];
    
    [self.personIconView pop_addAnimation: scaleAnim forKey: kPOPViewScaleXY];
    [self.personIconView pop_addAnimation: alphaAnim forKey: kPOPViewAlpha];
}

@end
