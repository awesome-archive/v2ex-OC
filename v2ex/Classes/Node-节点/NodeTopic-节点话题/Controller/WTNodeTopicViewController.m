//
//  WTNodeTopicViewController.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/7/22.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//  节点话题控制器

#import "WTNodeTopicViewController.h"
#import "WTTopicDetailViewController.h"
#import "WTTopicViewController.h"
#import "WTNodeTopicHeaderView.h"

#import "WTTopicViewModel.h"
#import "WTNodeViewModel.h"
#import "WTNodeItem.h"
#import "WTTopicCell.h"
#import "WTNodeTopicCell.h"
#import "WTNodeViewModel.h"
#import "WTNodeTopicHeaderView.h"

#import "WTRefreshAutoNormalFooter.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "NetworkTool.h"
#import "MJExtension.h"


CGFloat const userCenterHeaderViewH = 170;

NSString * const ID = @"ID";

@interface WTNodeTopicViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) UIView                                *headerView;
@property (nonatomic, weak) UIView                                *footerView;

@property (nonatomic, weak) WTNodeTopicHeaderView                 *nodeTopicHeaderView;

@property (nonatomic, assign) UITableView                         *tableView;

@property (nonatomic, strong) WTTopicViewModel                    *topicVM;
/** 当前第几页 */
@property (nonatomic, assign) NSInteger                           page;
@end

@implementation WTNodeTopicViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.topicVM = [WTTopicViewModel new];
    
    // 设置View
    [self setupView];
    
    // 加载数据
    [self setupData];
}

// 设置View
- (void)setupView
{
    self.headerViewH = 195;
    self.view.backgroundColor = [UIColor whiteColor];
    
    UITableView *tableView = [UITableView new];
    
    {
        tableView.frame = self.footerContentView.bounds;
        [self.footerContentView addSubview: tableView];
        self.tableView = tableView;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        UIView *footerView = [UIView new];
        footerView.backgroundColor = WTColor(242, 243, 245);
        self.tableView.tableFooterView = footerView;
    }
    
    [self.tableView registerNib: [UINib nibWithNibName: NSStringFromClass([WTTopicCell class]) bundle: nil] forCellReuseIdentifier: ID];
    
    
    
    self.tableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingTarget: self refreshingAction: @selector(loadOldData)];
    
    
    [self loadNewData];
}

#pragma mark 加载最新的数据
- (void)loadNewData
{
    self.topicVM.page = 1; // 由于是抓取数据的原因，每次下拉刷新直接重头开始加载
    [self.topicVM getNodeTopicWithUrlStr: self.nodeItem.url topicType: WTTopicTypeHot success:^{
        
        if (!self.topicVM.nextPage)
        {
            self.tableView.mj_footer = nil;
        }
        
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
    
    [self.topicVM getNodeTopicWithUrlStr: self.nodeItem.url topicType: WTTopicTypeHot success:^{
        
        [self.tableView reloadData];
        [self.tableView.mj_footer endRefreshing];
        
    } failure:^(NSError *error) {
        
        [self.tableView.mj_footer endRefreshing];
    }];
}

- (void)setupData
{
    self.nodeTopicHeaderView.nodeItem = self.nodeItem;
    self.nodeItem = [WTNodeViewModel queryNodeItemsWithNodeName: self.nodeItem.title];
    
    [WTNodeViewModel getNodeItemWithNodeId: self.nodeItem.uid success:^(WTNodeItem *nodeItem) {
        
        self.nodeTopicHeaderView.nodeItem = nodeItem;
        
    } failure:^(NSError *error) {
        
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
    WTTopicDetailViewController *detailVC = [WTTopicDetailViewController new];
    detailVC.topicDetailUrl = topic.detailUrl;
    [self.navigationController pushViewController: detailVC animated: YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView fd_heightForCellWithIdentifier: ID cacheByIndexPath: indexPath configuration:^(WTTopicCell *cell) {
        cell.topic = self.topicVM.topics[indexPath.row];
    }];
}

/**
 *  拼接urlString的参数
 *
 */
- (NSString *)stitchingUrlParameter
{
    if ([WTTopicViewModel isNeedNextPage: self.nodeItem.url])
    {
        return [NSString stringWithFormat: @"%@?p=%ld", self.nodeItem.url, self.page];
    }
    return [NSString stringWithFormat: @"%@", self.nodeItem.url];
}

#pragma mark - Lazy Method
- (WTNodeTopicHeaderView *)nodeTopicHeaderView
{
    if (_nodeTopicHeaderView == nil)
    {
        WTNodeTopicHeaderView *nodeTopicHeaderView = [WTNodeTopicHeaderView nodeTopicHeaderView];
        nodeTopicHeaderView.frame = CGRectMake(0, 64, WTScreenWidth, 182);
        [self.headerContentView addSubview: nodeTopicHeaderView];
        _nodeTopicHeaderView = nodeTopicHeaderView;
    }
    return _nodeTopicHeaderView;
}

@end
