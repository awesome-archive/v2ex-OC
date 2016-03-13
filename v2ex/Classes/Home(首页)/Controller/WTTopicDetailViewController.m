//
//  WTtopicDetailViewController.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/1/17.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//  话题详情控制器

#import "WTTopicDetailViewController.h"
#import "WTTopicViewModel.h"
#import "WTTopicDetailTableViewController.h"
#import "Masonry.h"
#import "WTToolBarView.h"

NS_ASSUME_NONNULL_BEGIN

@interface WTTopicDetailViewController ()

@property (weak, nonatomic) IBOutlet UIView *normalView;

@property (nonatomic, weak) WTToolBarView   *toolBarView;

@end

@implementation WTTopicDetailViewController

- (instancetype)init
{
    return [UIStoryboard storyboardWithName: NSStringFromClass([self class]) bundle: nil].instantiateInitialViewController;
}

#pragma mark - 初始化
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 设置话题详情数据
    [self setupTopicDetailData];
    
    // 设置工具栏
    [self setupToolBarView];
}

#pragma mark -设置话题详情数据
- (void)setupTopicDetailData
{
    WTTopicDetailTableViewController *topicVC = [WTTopicDetailTableViewController new];
    topicVC.topicDetailUrl = self.topicViewModel.topicDetailUrl;
    [self.normalView addSubview: topicVC.tableView];
    [self addChildViewController: topicVC];
    
    topicVC.tableView.contentInset = UIEdgeInsetsMake(0, 0, WTToolBarHeight, 0);
    topicVC.tableView.separatorInset = topicVC.tableView.contentInset;
    
    [topicVC.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.normalView);
    }];
}

#pragma mark - 设置工具栏
- (void)setupToolBarView
{
    WTToolBarView *toolBarView = [WTToolBarView toolBarView];
    [self.normalView addSubview: toolBarView];
    _toolBarView = toolBarView;
    
    [toolBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.normalView);
        make.height.equalTo(@(WTToolBarHeight));
    }];
}

@end
NS_ASSUME_NONNULL_END