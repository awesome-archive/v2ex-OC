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
#import "WTTopicTool.h"
#import "WTTopicDetailViewController.h"
#import "WTTopic.h"
#import "NSString+YYAdd.h"
// ======
#import "WTNode.h"

NS_ASSUME_NONNULL_BEGIN
@interface WTTopicViewController ()

/** 博客模型数组 */
@property (nonatomic, strong) NSMutableArray           *topics;
/** 当前第几页 */
@property (nonatomic, assign) NSInteger                page;

@end

@implementation WTTopicViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // 初始化页面
    [self setUpView];
}

#pragma mark - Lazy method
#pragma mark blogs
- (NSMutableArray *)topics
{
    if (_topics == nil)
    {
        _topics = [NSMutableArray array];
    }
    return _topics;
}

#pragma mark - 初始化页面
- (void)setUpView
{
    // cell 的高度
    self.tableView.rowHeight = 81;
    
    self.tableView.tableFooterView = [UIView new];
    
    if (![self.urlString containsString: @"my"])
    {
        // 设置内边距
        self.tableView.contentInset = UIEdgeInsetsMake(WTNavigationBarMaxY + WTTitleViewHeight, 0, WTTabBarHeight, 0);
        // 设置滚动条的内边距
        self.tableView.separatorInset = self.tableView.contentInset;
    }
    
    // 添加上拉刷新
    if ([WTTopic isNewestNodeWithUrlSuffix: self.urlString])
    {
        self.tableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingTarget: self refreshingAction: @selector(loadOldData)];
    }
    
    // 下拉刷新
    self.tableView.mj_header = [WTRefreshNormalHeader headerWithRefreshingTarget: self refreshingAction: @selector(loadNewData)];
    
    // 开始下拉刷新
    [self.tableView.mj_header beginRefreshing];
}

#pragma mark 加载最新的数据
- (void)loadNewData
{
    // 每次下拉刷新重置所有数据，从第一页重新请求
    self.page = 1;
    [WTTopicTool getTopicsWithUrlString: [self stitchingUrlParameter] success:^(NSArray *topics) {
        
        [self.tableView.mj_header endRefreshing];
        
        // topics数组中的最后一个对象是保存是否有下一页的
        WTTopic *lastTopic = topics.lastObject;
        if (!lastTopic.isHasNextPage)
        {
            self.tableView.mj_footer = nil;
        }
        
        [self.topics removeAllObjects];
        [self.topics addObjectsFromArray: topics];
        
        // 由于最后一个WTTopic对象只是单纯保存了是否有下一页所以删除最后一个对象
        [self.topics removeLastObject];
        [self.tableView reloadData];
        
        
    } failure:^(NSError *error) {
        [self.tableView.mj_header endRefreshing];
        WTLog(@"error:%@", error);
    }];
}

#pragma mark 加载旧的数据
- (void)loadOldData
{
    // 每次下拉刷新重置所有数据，从第一页重新请求
    self.page ++;

    [WTTopicTool getTopicsWithUrlString: [self stitchingUrlParameter] success:^(NSArray *topics) {
        
        [self.tableView.mj_footer endRefreshing];
        
        // topics数组中的最后一个对象是保存是否有下一页的
        WTTopic *lastTopic = topics.lastObject;
        if (!lastTopic.isHasNextPage)
        {
            self.tableView.mj_footer = nil;
        }
    
        [self.topics addObjectsFromArray: topics];
        // 由于最后一个WTTopic对象只是单纯保存了是否有下一页所以删除最后一个对象
        [self.topics removeLastObject];
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        [self.tableView.mj_footer endRefreshing];
        WTLog(@"error:%@", error)
    }];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.topics.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WTTopicCell *cell = [WTTopicCell cellWithTableView: tableView];
    
    // 设置数据
    cell.topic = self.topics[indexPath.row];
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 取消选中的效果
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
    
    // 跳转至话题详情控制器
    WTTopic *topic = self.topics[indexPath.row];
    WTTopicDetailViewController *detailVC = [WTTopicDetailViewController new];
    detailVC.topic = topic;
    [self.navigationController pushViewController: detailVC animated: YES];
}

/**
 *  拼接urlString的参数
 *
 */
- (NSString *)stitchingUrlParameter
{
    if ([WTTopic isNewestNodeWithUrlSuffix: _urlString])
    {
        return [NSString stringWithFormat: @"%@?p=%ld", self.urlString, self.page];
    }
    return [NSString stringWithFormat: @"%@", self.urlString];
}

@end
NS_ASSUME_NONNULL_END