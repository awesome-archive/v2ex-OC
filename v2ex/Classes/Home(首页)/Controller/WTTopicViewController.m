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

NS_ASSUME_NONNULL_BEGIN

static NSString *const ID = @"topicCell";

@interface WTTopicViewController ()

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
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib: [UINib nibWithNibName: NSStringFromClass([WTTopicCell class]) bundle: nil] forCellReuseIdentifier: ID];
    
    // 调整tableView的内边距和滚动条内边距
    if (![self.urlString containsString: @"my"])
    {
        self.tableView.contentInset = UIEdgeInsetsMake(WTNavigationBarMaxY + WTTitleViewHeight, 0, WTTabBarHeight, 0);
        self.tableView.separatorInset = self.tableView.contentInset;
    }
    
    // 只有'最近'节点需要上拉刷新
    if ([WTTopicViewModel isNeedNextPage: self.urlString])
    {
        self.tableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingTarget: self refreshingAction: @selector(loadOldData)];
    }
    self.tableView.mj_header = [WTRefreshNormalHeader headerWithRefreshingTarget: self refreshingAction: @selector(loadNewData)];
    
    [self.tableView.mj_header beginRefreshing];
}

#pragma mark 加载最新的数据
- (void)loadNewData
{
    self.page = 1;
    [[NetworkTool shareInstance] getHtmlCodeWithUrlString: [self stitchingUrlParameter] success:^(NSData *data) {
        
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
    
    [[NetworkTool shareInstance] getHtmlCodeWithUrlString: [self stitchingUrlParameter] success:^(NSData *data) {
        
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

@end
NS_ASSUME_NONNULL_END