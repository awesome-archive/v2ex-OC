//
//  WTUserNotificationViewController.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/7/25.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//  通知控制器

#import "WTUserNotificationViewController.h"
#import "WTLoginViewController.h"
#import "WTTopicDetailViewController.h"

#import "WTNoDataView.h"
#import "WTNotificationCell.h"
#import "WTRefreshNormalHeader.h"
#import "WTRefreshAutoNormalFooter.h"

#import "WTConst.h"
#import "NetworkTool.h"
#import "WTTopicViewModel.h"
#import "WTAccountViewModel.h"
#import "WTNotificationViewModel.h"

#import "UITableView+FDTemplateLayoutCell.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

static NSString * const ID = @"notificationCell";

@interface WTUserNotificationViewController () <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, WTNotificationCellDelegate>
/** 回复消息ViewModel */
@property (nonatomic, strong) WTNotificationViewModel          *notificationVM;
/** 请求地址 */
@property (nonatomic, strong) NSString                         *urlString;
/** 页数*/
@property (nonatomic, assign) NSInteger                        page;

@property (nonatomic, assign) WTTableViewType                  tableViewType;
/** 记录第一次进入APP登录的状态 */
@property (nonatomic, assign, getter=isLogin) BOOL             login;

@end

@implementation WTUserNotificationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.title = @"提醒";
    
    self.tableView.tableFooterView = [UIView new];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // iOS8 以后 self-sizing
    self.tableView.estimatedRowHeight = 96;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    // 注册cell
    [self.tableView registerNib: [UINib nibWithNibName: NSStringFromClass([WTNotificationCell class]) bundle: nil] forCellReuseIdentifier: ID];
    
    self.notificationVM = [WTNotificationViewModel new];
    
    // 1、添加下拉刷新、上拉刷新
    self.tableView.mj_header = [WTRefreshNormalHeader headerWithRefreshingTarget: self refreshingAction: @selector(loadNewData)];
    self.tableView.mj_footer = [WTRefreshAutoNormalFooter footerWithRefreshingTarget: self refreshingAction: @selector(loadOldData)];
    
    
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    // 2、登陆过
    if ([[WTAccountViewModel shareInstance] isLogin] && self.login == NO)
    {
        self.login = YES;
        // 2、开始下拉刷新
        [self.tableView.mj_header beginRefreshing];
        
    }
    else
    {
        self.tableViewType = WTTableViewTypeLogout;
        self.login = NO;
        [self.notificationVM.notificationItems removeAllObjects];
        [self.tableView reloadData];
    }
}

#pragma mark - 加载数据
#pragma mark 加载最新的数据
- (void)loadNewData
{
    
    self.notificationVM.page = 1;
    
    [self.notificationVM getUserNotificationsSuccess:^{
        
        [self.tableView reloadData];
        
        [self.tableView.mj_header endRefreshing];
        
    } failure:^(NSError *error) {
        [self.tableView.mj_header endRefreshing];
    }];
}

#pragma mark 加载旧的数据
- (void)loadOldData
{
    if (self.notificationVM.isNextPage)
    {
        self.notificationVM.page ++;
        
        [self.notificationVM getUserNotificationsSuccess:^{
            
            [self.tableView reloadData];
            
            [self.tableView.mj_footer endRefreshing];
            
        } failure:^(NSError *error) {
            [self.tableView.mj_footer endRefreshing];
        }];
    }
    else
    {
        [self.tableView.mj_footer endRefreshing];
    }
}
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.notificationVM.notificationItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WTNotificationCell *cell = [tableView dequeueReusableCellWithIdentifier: ID];
    
    cell.noticationItem = self.notificationVM.notificationItems[indexPath.row];
    
    cell.delegate = self;
    
    return cell;
}

#pragma mark - Table view data source
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WTTopicDetailViewController *topDetailVC = [WTTopicDetailViewController new];
    topDetailVC.topicDetailUrl = self.notificationVM.notificationItems[indexPath.row].detailUrl;
    [self.navigationController pushViewController: topDetailVC animated: YES];
}

#pragma mark - WTNotificationCellDelegate
- (void)notificationCell:(WTNotificationCell *)notificationCell didClickWithNoticationItem:(WTNotificationItem *)noticationItem
{
    __weak typeof(self) weakSelf = self;
    // 删除通知
    [self.notificationVM deleteNotificationByNoticationItem: noticationItem success:^{
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow: [weakSelf.notificationVM.notificationItems indexOfObject: noticationItem] inSection: 0];
        
        [weakSelf.notificationVM.notificationItems removeObject: noticationItem];
        [weakSelf.tableView deleteRowsAtIndexPaths: @[indexPath] withRowAnimation: UITableViewRowAnimationMiddle];
        
//        if (weakSelf.notificationVM.notificationItems.count == 0)
//        {
//            [weakSelf.tableView reloadData];
//        }
        
    } failure:^(NSError *error) {
        
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView fd_heightForCellWithIdentifier: ID cacheByIndexPath: indexPath configuration:^(WTNotificationCell *cell) {
        cell.noticationItem = self.notificationVM.notificationItems[indexPath.row];
    }];
}

#pragma mark - DZNEmptyDataSetSource
- (UIView *)customViewForEmptyDataSet:(UIScrollView *)scrollView
{
    UIView *view;
    if (self.tableViewType == WTTableViewTypeLogout)
    {
        WTNoDataView *noDataView = [WTNoDataView noDataView];
        noDataView.tipImageView.image = [UIImage imageNamed:@"no_notification"];
        noDataView.tipTitleLabel.text = @"快去发表主题吧";
        view = noDataView;
    }
    else if(self.tableViewType == WTTableViewTypeNoData)
    {
        UIButton *loginBtn = [UIButton new];
        loginBtn.width = 100;
        loginBtn.height = 30;
        [loginBtn setTitle: @"登陆" forState: UIControlStateNormal];
        view = loginBtn;
    }
    return view;
}
@end
