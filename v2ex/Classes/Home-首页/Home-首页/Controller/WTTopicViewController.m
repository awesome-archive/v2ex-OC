//
//  WTBlogViewController.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/1/14.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//  话题控制器

#import "WTTopicViewController.h"
#import "WTTopicCell.h"
#import "WTRefreshNormalHeader.h"
#import "WTRefreshAutoNormalFooter.h"
#import "WTTopicDetailViewController.h"
#import "NSString+YYAdd.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "NetworkTool.h"
#import "WTTopicViewModel.h"
// ======
#import "WTNode.h"



static NSString *const ID = @"topicCell";

@interface WTTopicViewController () <UIViewControllerPreviewingDelegate>

@property (nonatomic, strong) NSMutableArray<WTTopicViewModel *>  *topicViewModels;
/** 当前第几页 */
@property (nonatomic, assign) NSInteger                           page;

@end

@implementation WTTopicViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // 初始化页面
    [self setUpView];
}

#pragma mark - 初始化页面
- (void)setUpView
{
    // 1、设置tableView一些属性
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib: [UINib nibWithNibName: NSStringFromClass([WTTopicCell class]) bundle: nil] forCellReuseIdentifier: ID];

    if (self.topicType != WTTopicTypeCollection)
    {
        // 设置内边距
        self.tableView.contentInset = UIEdgeInsetsMake(WTNavigationBarMaxY + WTTitleViewHeight, 0, WTTabBarHeight, 0);
        // 设置滚动条的内边距
        self.tableView.separatorInset = self.tableView.contentInset;
    }
    
    
    
    // 1.2只有'最近'节点需要上拉刷新
    if ([WTTopicViewModel isNeedNextPage: self.urlString])
    {
        self.tableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingTarget: self refreshingAction: @selector(loadOldData)];
    }
    self.tableView.mj_header = [WTRefreshNormalHeader headerWithRefreshingTarget: self refreshingAction: @selector(loadNewData)];
    
    [self.tableView.mj_header beginRefreshing];
    
    // 2、判断3DTouch
    if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable)
    {
        [self registerForPreviewingWithDelegate: self sourceView: self.view];
    }
}

#pragma mark 加载最新的数据
- (void)loadNewData
{
    self.page = 1; // 由于是抓取数据的原因，每次下拉刷新直接重头开始加载
    [[NetworkTool shareInstance] GETWithUrlString: [self stitchingUrlParameter] success:^(NSData *data) {
        
        self.topicViewModels = [WTTopicViewModel nodeTopicsWithData: data];
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
        
    } failure:^(NSError *error) {
        [self.tableView.mj_header endRefreshing];
    }];
}

#pragma mark 加载旧的数据
- (void)loadOldData
{
    self.page ++;
    
    [[NetworkTool shareInstance] GETWithUrlString: [self stitchingUrlParameter] success:^(NSData *data) {
        
        [self.topicViewModels addObjectsFromArray: [WTTopicViewModel nodeTopicsWithData: data]];
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
               
    } failure:^(NSError *error) {
        [self.tableView.mj_header endRefreshing];
    }];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.topicViewModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WTTopicCell *cell = [tableView dequeueReusableCellWithIdentifier: ID];
    
    // 设置数据
    cell.topicViewModel = self.topicViewModels[indexPath.row];
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 取消选中的效果
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
    
    // 跳转至话题详情控制器
    WTTopicViewModel *topicViewModel = self.topicViewModels[indexPath.row];
    WTTopicDetailViewController *detailVC = [WTTopicDetailViewController new];
    detailVC.topicViewModel = topicViewModel;
    [self.navigationController pushViewController: detailVC animated: YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView fd_heightForCellWithIdentifier: ID cacheByIndexPath: indexPath configuration:^(WTTopicCell *cell) {
        cell.topicViewModel = self.topicViewModels[indexPath.row];
    }];
}

/**
 *  拼接urlString的参数
 *
 */
- (NSString *)stitchingUrlParameter
{
    if ([WTTopicViewModel isNeedNextPage: _urlString])
    {
        return [NSString stringWithFormat: @"%@?p=%ld", self.urlString, self.page];
    }
    return [NSString stringWithFormat: @"%@", self.urlString];
}

#pragma mark - UIViewControllerPreviewingDelegate 测试数据
- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
//    [self.navigationController pushViewController: viewControllerToCommit animated: YES];
    [self showViewController: viewControllerToCommit sender: self];
}

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: location];
    WTTopicCell *cell = [self.tableView cellForRowAtIndexPath: indexPath];
    if (!cell)
        return nil;
    
    WTTopicViewModel *topicViewModel = cell.topicViewModel;
    WTTopicDetailViewController *topicDetailVC = [WTTopicDetailViewController new];
    topicDetailVC.topicViewModel = topicViewModel;
    
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


@end
