//
//  WTBlogViewController.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/1/14.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//  话题控制器

#import "WTTopicViewController.h"
#import "WTMemberDetailViewController.h"
#import "WTTopicDetailViewController.h"

#import "WTTopicCell.h"

#import "NetworkTool.h"
#import "WTTopicViewModel.h"
#import "WTRefreshNormalHeader.h"
#import "WTRefreshAutoNormalFooter.h"

#import "NSString+YYAdd.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
// ======
#import "WTNode.h"

static NSString *const ID = @"topicCell";

@interface WTTopicViewController () <UIViewControllerPreviewingDelegate, WTTopicCellDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (nonatomic, strong) WTTopicViewModel                    *topicVM;

@end

@implementation WTTopicViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.topicVM = [WTTopicViewModel new];
    
    // 初始化页面
    [self setUpView];
}

#pragma mark - 初始化页面
- (void)setUpView
{
    // 1、设置tableView一些属性
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib: [UINib nibWithNibName: NSStringFromClass([WTTopicCell class]) bundle: nil] forCellReuseIdentifier: ID];

    // 设置内边距
    self.tableView.contentInset = UIEdgeInsetsMake(WTNavigationBarMaxY + WTTitleViewHeight, 0, WTTabBarHeight, 0);
    // 设置滚动条的内边距
    self.tableView.separatorInset = self.tableView.contentInset;
    
    
    // 1.2只有'最近'节点需要上拉刷新
    if ([WTTopicViewModel isNeedNextPage: self.urlString])
    {
        self.tableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingTarget: self refreshingAction: @selector(loadOldData)];
    }
    else
    {
        self.tableView.mj_footer = nil;
    }
    
//    [self.tableView.mj_header beginRefreshing];
    
    // 2、判断3DTouch
    if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable)
    {
        [self registerForPreviewingWithDelegate: self sourceView: self.view];
    }
}

#pragma mark 加载最新的数据
- (void)loadNewData
{
    self.topicVM.page = 1; // 由于是抓取数据的原因，每次下拉刷新直接重头开始加载
    
    [self.topicVM getNodeTopicWithUrlStr: self.urlString topicType: WTTopicTypeNormal success:^{
        
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
        
    } failure:^(NSError *error) {
        
        [self.tableView.mj_header endRefreshing];
    }];
}

#pragma mark 加载旧的数据
- (void)loadOldData
{
    self.topicVM.page ++;
    
    [self.topicVM getNodeTopicWithUrlStr: self.urlString topicType: WTTopicTypeNormal success:^{
        
        [self.tableView reloadData];
        [self.tableView.mj_footer endRefreshing];
        
    } failure:^(NSError *error) {
        
        [self.tableView.mj_footer endRefreshing];
    }];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.topicVM.topics.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WTTopicCell *cell = [tableView dequeueReusableCellWithIdentifier: ID];
    cell.delegate = self;
    // 设置数据
    cell.topic = self.topicVM.topics[indexPath.row];
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 取消选中的效果
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
    
    // 跳转至话题详情控制器
    WTTopic *topic = self.topicVM.topics[indexPath.row];
    WTTopicDetailViewController *detailVC = [WTTopicDetailViewController topicDetailViewController];
    detailVC.topicDetailUrl = topic.detailUrl;
    detailVC.topicTitle = topic.title;
    [self.navigationController pushViewController: detailVC animated: YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView fd_heightForCellWithIdentifier: ID cacheByIndexPath: indexPath configuration:^(WTTopicCell *cell) {
        cell.topic = self.topicVM.topics[indexPath.row];
    }];
}

#pragma mark - WTTopicCellDelegate
- (void)topicCell:(WTTopicCell *)topicCell didClickMemberDetailAreaWithTopic:(WTTopic *)topic
{
    WTMemberDetailViewController *memeberDetailVC = [[WTMemberDetailViewController alloc] initWithTopic: topic];
    [self.navigationController pushViewController: memeberDetailVC animated: YES];
}

#pragma mark - UIViewControllerPreviewingDelegate 测试数据
- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    [self showViewController: viewControllerToCommit sender: self];
}

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: location];
    WTTopicCell *cell = [self.tableView cellForRowAtIndexPath: indexPath];
    if (!cell)
        return nil;
    
    WTTopic *topic = cell.topic;
    WTTopicDetailViewController *topicDetailVC = [WTTopicDetailViewController new];
    topicDetailVC.topicDetailUrl = topic.detailUrl;
    
//    previewingContext.sourceRect = self.view.bounds;/
    return topicDetailVC;
}

- (NSArray<id<UIPreviewActionItem>> *)previewActionItems
{
    // 生成UIPreviewAction
    UIPreviewAction *action1 = [UIPreviewAction actionWithTitle:@"Action 1" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        NSLog(@"Action 1 selected");
    }];
    
    UIPreviewAction *action2 = [UIPreviewAction actionWithTitle:@"Action 2" style:UIPreviewActionStyleDestructive handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        NSLog(@"Action 2 selected");
    }];
    
    UIPreviewAction *action3 = [UIPreviewAction actionWithTitle:@"Action 3" style:UIPreviewActionStyleSelected handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        NSLog(@"Action 3 selected");
    }];
    
    UIPreviewAction *tap1 = [UIPreviewAction actionWithTitle:@"tap 1" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        NSLog(@"tap 1 selected");
    }];
    
    UIPreviewAction *tap2 = [UIPreviewAction actionWithTitle:@"tap 2" style:UIPreviewActionStyleDestructive handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        NSLog(@"tap 2 selected");
    }];
    
    UIPreviewAction *tap3 = [UIPreviewAction actionWithTitle:@"tap 3" style:UIPreviewActionStyleSelected handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        NSLog(@"tap 3 selected");
    }];
    
    // 塞到UIPreviewActionGroup中
    NSArray *actions = @[action1, action2, action3];
    NSArray *taps = @[tap1, tap2, tap3];
    UIPreviewActionGroup *group1 = [UIPreviewActionGroup actionGroupWithTitle:@"Action Group" style:UIPreviewActionStyleDefault actions:actions];
    UIPreviewActionGroup *group2 = [UIPreviewActionGroup actionGroupWithTitle:@"Action Group" style:UIPreviewActionStyleDefault actions:taps];
    NSArray *group = @[group1,group2];
    
    return group;
}

#pragma mark - DZNEmptyDataSetSource
//- (UIView *)customViewForEmptyDataSet:(UIScrollView *)scrollView
//{
//    UIView *view;
//    if (self.tableViewType == WTTableViewTypeLogout)
//    {
//        WTNoDataView *noDataView = [WTNoDataView noDataView];
//        noDataView.tipImageView.image = [UIImage imageNamed:@"no_notification"];
//        noDataView.tipTitleLabel.text = @"快去发表主题吧";
//        view = noDataView;
//    }
//    return view;
//}

@end
