//
//  WTUserTopicViewController.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/3/21.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//  回复主题控制器

#import "WTUserTopicViewController.h"
#import "WTTopicCell.h"
#import "NetworkTool.h"
#import "WTRefreshNormalHeader.h"
#import "WTRefreshAutoNormalFooter.h"
#import "WTTopicDetailViewController.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "WTTopicViewModel.h"

static NSString *const ID = @"topicCell";

@interface WTUserTopicViewController ()
@property (nonatomic, strong) NSMutableArray<WTTopicViewModel *>  *topicViewModels;
/** 当前第几页 */
@property (nonatomic, assign) NSInteger                           page;
@end

@implementation WTUserTopicViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 1、设置tableView一些属性
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib: [UINib nibWithNibName: NSStringFromClass([WTTopicCell class]) bundle: nil] forCellReuseIdentifier: ID];
    
   // self.tableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingTarget: self refreshingAction: @selector(loadNewData)];

    [self loadOldData];

    //[self.tableView.mj_header beginRefreshing];
}

#pragma mark 加载最新的数据
- (void)loadOldData
{
    if (self.urlString.length == 0)
    {
        return;
    }
    
    self.page = 1;
    [[NetworkTool shareInstance] GETWithUrlString: [self stitchingUrlParameter] success:^(NSData *data) {
        
        self.topicViewModels = [WTTopicViewModel nodeTopicsWithData: data iconURL: [NSURL URLWithString: @"http://cdn.v2ex.co/gravatar/10db33f071127b63efd6ce14dfac3ac9?s=48&d=retro"]];
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
        
        if (self.completionBlock) {
            self.completionBlock();
        }
        
    } failure:^(NSError *error) {
        [self.tableView.mj_header endRefreshing];
    }];
}

#pragma mark 加载旧的数据
- (void)loadNewData
{
    self.page ++;
    
    [[NetworkTool shareInstance] GETWithUrlString: [self stitchingUrlParameter] success:^(NSData *data) {
        
        [self.topicViewModels addObjectsFromArray: [WTTopicViewModel nodeTopicsWithData: data iconURL: [NSURL URLWithString: @"http://cdn.v2ex.co/gravatar/10db33f071127b63efd6ce14dfac3ac9?s=48&d=retro"]]];
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
        
        if (self.completionBlock) {
            self.completionBlock();
        }
        
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
