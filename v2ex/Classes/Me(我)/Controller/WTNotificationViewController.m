//
//  WTNotificationViewController.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/2/26.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTNotificationViewController.h"
#import "NetworkTool.h"
#import "WTRefreshAutoNormalFooter.h"
#import "WTRefreshNormalHeader.h"
#import "WTNotificationCell.h"
#import "WTTopicViewModel.h"
#import "WTTopicDetailViewController.h"
static NSString * const ID = @"notificationCell";

@interface WTNotificationViewController ()
/** 回复消息模型 */
@property (nonatomic, strong) NSMutableArray<WTTopicViewModel *> *topicVMs;
/** 请求地址 */
@property (nonatomic, strong) NSString                         *urlString;
/** 页数*/
@property (nonatomic, assign) NSInteger                        page;
@end

@implementation WTNotificationViewController

#pragma mark - 初始化
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"提醒";
    
    self.tableView.tableFooterView = [UIView new];
    
    // iOS8 以后 self-sizing
    self.tableView.estimatedRowHeight = 96;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    // 注册cell
    [self.tableView registerNib: [UINib nibWithNibName: NSStringFromClass([WTNotificationCell class]) bundle: nil] forCellReuseIdentifier: ID];
    
    // 1、添加下拉刷新、上拉刷新
    self.tableView.mj_header = [WTRefreshNormalHeader headerWithRefreshingTarget: self refreshingAction: @selector(loadNewData)];
    self.tableView.mj_footer = [WTRefreshAutoNormalFooter footerWithRefreshingTarget: self refreshingAction: @selector(loadOldData)];
    
    // 2、开始下拉刷新
    [self.tableView.mj_header beginRefreshing];
}

#pragma mark - 加载数据
#pragma mark 加载最新的数据
- (void)loadNewData
{
    self.urlString = @"http://www.v2ex.com/notifications?p=1";
    self.page = 1;
//    [WTAccountTool getNotificationWithUrlString: self.urlString success:^(NSMutableArray<WTNotification *> *notifications){
//        
//        // 取出最后一个模型判断是有下一页
//        [self isHasNextPage: notifications.lastObject];
//        
//        self.notifications = notifications;
//        // 移除最后一个模型
//        [self.notifications removeLastObject];
//        
//        [self.tableView.mj_header endRefreshing];
//        [self.tableView reloadData];
//        
//    } failure:^(NSError *error) {
//        [self.tableView.mj_header endRefreshing];
//    }];

    [[NetworkTool shareInstance] getHtmlCodeWithUrlString: self.urlString success:^(NSData *data) {
        
        self.topicVMs = [WTTopicViewModel userNotificationsWithData: data];
        
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
    
    NSRange range = [self.urlString rangeOfString: @"="];
    self.urlString = [NSString stringWithFormat: @"%@%ld", [self.urlString substringWithRange: NSMakeRange(0, range.location + range.length)], self.page];
    
//    [WTAccountTool getNotificationWithUrlString: self.urlString success:^(NSMutableArray<WTNotification *> *notifications){
//        
//        // 取出最后一个模型判断是有下一页
//        [self isHasNextPage: notifications.lastObject];
//        
//        [self.notifications addObjectsFromArray: notifications];
//        // 移除最后一个模型
//        [self.notifications removeLastObject];
//        
//        [self.tableView.mj_footer endRefreshing];
//        [self.tableView reloadData];
//        
//    } failure:^(NSError *error) {
//        [self.tableView.mj_header endRefreshing];
//    }];

    
}

///**
// *  是否有下一页
// *
// */
//- (void)isHasNextPage:(WTNotification *)lastNotification
//{
//    // 取出最后一个模型判断是有下一页
//    if (!lastNotification.topic.isHasNextPage)
//    {
//        self.tableView.mj_footer = nil;
//    }
//    else
//    {
//        self.tableView.mj_footer = [WTRefreshAutoNormalFooter footerWithRefreshingTarget: self refreshingAction: @selector(loadOldData)];
//    }
//}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.topicVMs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    WTNotificationCell *cell = [tableView dequeueReusableCellWithIdentifier: ID];
    
    cell.topicViewModel = self.topicVMs[indexPath.row];
    
    return cell;
}

#pragma mark - Table view data source
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WTTopicDetailViewController *topDetailVC = [WTTopicDetailViewController new];
    topDetailVC.topicViewModel = self.topicVMs[indexPath.row];
    [self.navigationController pushViewController: topDetailVC animated: YES];
}

@end
