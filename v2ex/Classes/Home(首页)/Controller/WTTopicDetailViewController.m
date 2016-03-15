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

@property (weak, nonatomic) IBOutlet UIView *tipView;

@property (nonatomic, weak) UITableView     *tableView;
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
    // 1、创建话题详情数据控制器
    WTTopicDetailTableViewController *topicVC = [WTTopicDetailTableViewController new];
    topicVC.topicDetailUrl = self.topicViewModel.topicDetailUrl;
    [self.normalView addSubview: topicVC.tableView];
    _tableView = topicVC.tableView;
    [self addChildViewController: topicVC];
    
    // 2、设置属性
    topicVC.tableView.contentInset = UIEdgeInsetsMake(0, 0, WTToolBarHeight, 0);
    topicVC.tableView.separatorInset = topicVC.tableView.contentInset;
    
    // 3、设置布局
    [topicVC.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.normalView);
    }];
    
    __weak typeof(self) weakSelf = self;
    topicVC.updateTopicDetailComplection = ^(WTTopicDetailViewModel *topicDetailVM, NSError *error){
        
        if (error != nil)
        {
            weakSelf.tipView.hidden = NO;
            return;
        }
        weakSelf.tipView.hidden = YES;
        weakSelf.toolBarView.topicDetailVM = topicDetailVM;
    };
}

#pragma mark - 设置工具栏
- (void)setupToolBarView
{
    // 1、创建工具栏View
    WTToolBarView *toolBarView = [WTToolBarView toolBarView];
    [self.normalView addSubview: toolBarView];
    _toolBarView = toolBarView;
    
    // 3、布局
    [toolBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.normalView);
        make.height.equalTo(@(WTToolBarHeight));
    }];
}

#pragma mark - 事件
- (IBAction)goLoginVCBtnClick
{
    WTLoginViewController *loginVC = [WTLoginViewController new];
    loginVC.loginSuccessBlock = ^{
        WTTopicDetailTableViewController *vc = self.childViewControllers.firstObject;
        [vc setupData];
    };
    [self presentViewController: loginVC animated: YES completion: nil];
}

- (void)dealloc
{
    WTLog(@"WTTopicDetailViewController dealloc")
}

@end
NS_ASSUME_NONNULL_END