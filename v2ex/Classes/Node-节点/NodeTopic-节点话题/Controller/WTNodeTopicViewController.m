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

#import "WTTopicViewModel.h"
#import "WTNodeItem.h"
#import "WTTopicCell.h"
#import "WTNodeTopicCell.h"

#import "WTRefreshAutoNormalFooter.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "NetworkTool.h"
#import "MJExtension.h"


CGFloat const userCenterHeaderViewH = 150;

NSString * const ID = @"ID";

@interface WTNodeTopicViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) UIView *headerView;
@property (nonatomic, assign) UIView *footerView;

@property (nonatomic, assign) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray<WTTopicViewModel *>  *topicViewModels;
/** 当前第几页 */
@property (nonatomic, assign) NSInteger                           page;
@end

@implementation WTNodeTopicViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 设置View
    [self setupView];
    
    // 加载数据
  //  [self setupData];
}

// 设置View
- (void)setupView
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    UITableView *tableView = [UITableView new];
    
    {
        tableView.frame = self.footerContentView.bounds;
        [self.footerContentView addSubview: tableView];
        self.tableView = tableView;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
    }
    
    [self.tableView registerNib: [UINib nibWithNibName: NSStringFromClass([WTTopicCell class]) bundle: nil] forCellReuseIdentifier: ID];
    
    if ([WTTopicViewModel isNeedNextPage: self.nodeItem.url])
    {
        self.tableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingTarget: self refreshingAction: @selector(loadOldData)];
    }
    
    [self loadNewData];
}

#pragma mark 加载最新的数据
- (void)loadNewData
{
    self.page = 1; // 由于是抓取数据的原因，每次下拉刷新直接重头开始加载
    [[NetworkTool shareInstance] GETWithUrlString: [self stitchingUrlParameter] success:^(NSData *data) {
        
        self.topicViewModels = [WTTopicViewModel hotNodeTopicsWithData: data];
        [self.tableView reloadData];
        [self.tableView.mj_footer endRefreshing];
        
    } failure:^(NSError *error) {
        [self.tableView.mj_footer endRefreshing];
    }];
}

#pragma mark 加载旧的数据
- (void)loadOldData
{
    self.page ++;
    
    [[NetworkTool shareInstance] GETWithUrlString: [self stitchingUrlParameter] success:^(NSData *data) {
        
        [self.topicViewModels addObjectsFromArray: [WTTopicViewModel nodeTopicsWithData: data]];
        [self.tableView reloadData];

        
    } failure:^(NSError *error) {

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
    if ([WTTopicViewModel isNeedNextPage: self.nodeItem.url])
    {
        return [NSString stringWithFormat: @"%@?p=%ld", self.nodeItem.url, self.page];
    }
    return [NSString stringWithFormat: @"%@", self.nodeItem.url];
}

@end
