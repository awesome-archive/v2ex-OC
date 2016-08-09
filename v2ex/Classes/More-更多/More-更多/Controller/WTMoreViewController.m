//
//  WTMoreViewController.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/7/25.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//  更多控制器

#import "WTMoreViewController.h"
#import "WTPrivacyStatementViewController.h"
#import "WTLoginViewController.h"
#import "WTRegisterViewController.h"
#import "WTAdvertiseViewController.h"
#import "WTMyReplyViewController.h"

#import "WTTopicViewController.h"
#import "WTMoreNotLoginHeaderView.h"
#import "WTMoreLoginHeaderView.h"
#import "WTMoreCell.h"

#import "WTAccountViewModel.h"
#import "WTSettingItem.h"


NSString * const moreCellIdentifier = @"moreCellIdentifier";

CGFloat const moreHeaderViewH = 150;

@interface WTMoreViewController () <UITableViewDataSource, UITableViewDelegate, WTMoreNotLoginHeaderViewDelegate>

@property (nonatomic, weak) UIView *headerContentView;
@property (nonatomic, weak) UIView *footerContentView;
@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, weak) WTMoreLoginHeaderView *moreLoginHeaderView;
@property (nonatomic, weak) WTMoreNotLoginHeaderView *moreNotLoginHeaderView;

@property (nonatomic, strong) NSMutableArray *datas;
@property (nonatomic, strong) NSMutableArray *titles;

/** 记录scrollView的contentOff的Y值 */
@property (nonatomic, assign) CGFloat endY;

@end

@implementation WTMoreViewController

#pragma mark - LifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 设置View
    [self setupView];
}

// 设置View
- (void)setupView
{
    
    
    [self headerContentView];
    
    // 1、UITableView
    UITableView *tableView = [UITableView new];
    
    {
        tableView.frame = self.footerContentView.bounds;
        [self.footerContentView addSubview: tableView];
        self.tableView = tableView;
        
        tableView.backgroundColor = WTColor(244, 244, 244);
        tableView.tableFooterView = [UIView new];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.rowHeight = 234;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.sectionHeaderHeight = 10;
        tableView.sectionFooterHeight = CGFLOAT_MIN;
        
        [tableView registerClass: [WTMoreCell class] forCellReuseIdentifier: moreCellIdentifier];

    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    [self.navigationController setNavigationBarHidden: YES animated: NO];
    
    // 4、判断是否登录，添加不同的headerView
    if ([[WTAccountViewModel shareInstance] isLogin])
    {
        self.moreLoginHeaderView.hidden = NO;
        self.moreNotLoginHeaderView.hidden = YES;
    }
    else
    {
        self.moreLoginHeaderView.hidden = YES;
        self.moreNotLoginHeaderView.hidden = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];
    
    [self.navigationController setNavigationBarHidden: NO];
}

#pragma mark - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    WTMoreCell *moreCell = [tableView dequeueReusableCellWithIdentifier: moreCellIdentifier];
    
    moreCell.settingItems = self.datas[indexPath.row];
    
    moreCell.title = self.titles[indexPath.row];
    
    return moreCell;
   
}

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    WTSettingItem *item = self.datas[indexPath.section][indexPath.row];
    if (item.operationBlock)
    {
        item.operationBlock();
    }
    
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < 0)
    {
        [UIView animateWithDuration: 0.1 animations:^{
            
            
            self.endY += (-scrollView.contentOffset.y) * 0.3;
            self.footerContentView.y = moreHeaderViewH + self.endY;
            
        }];
        
        scrollView.contentOffset = CGPointMake(0, 0);
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [UIView animateWithDuration: 0.3 animations:^{
        
        self.footerContentView.y = moreHeaderViewH;
        self.endY = 0;
    }];
}

#pragma mark - WTMoreNotLoginHeaderViewDelegate
#pragma mark 登录按钮点击
- (void)moreNotLoginHeaderViewDidClickedLoginBtn:(WTMoreNotLoginHeaderView *)moreNotLoginHeaderView
{
    WTLoginViewController *loginVC = [WTLoginViewController new];
    
    loginVC.loginSuccessBlock = ^{
    
    };
    [self presentViewController: [WTLoginViewController new] animated: YES completion: nil];
}

#pragma mark 注册按钮点击
- (void)moreNotLoginHeaderViewDidClickedRegisterBtn:(WTMoreNotLoginHeaderView *)moreNotLoginHeaderView
{
    [self presentViewController: [WTRegisterViewController new] animated: YES completion: nil];
}

#pragma mark - Lazy Method
- (NSMutableArray<NSArray *> *)datas
{
    if (_datas == nil)
    {
        _datas = [NSMutableArray array];
    
        __weak typeof(self) weakSelf = self;
        
        [_datas addObject: @[
                             
                                
                                [WTSettingItem settingItemWithTitle: @"节点收藏" image: [UIImage imageNamed: @"mine_favourite"] operationBlock: nil],
                                
                                [WTSettingItem settingItemWithTitle: @"特别关注" image: [UIImage imageNamed: @"mine_follow"] operationBlock: nil],
                                [WTSettingItem settingItemWithTitle: @"我的收藏" image: [UIImage imageNamed: @"more_collection"] operationBlock: ^{
            
            
                                    WTTopicViewController *topicVC = [WTTopicViewController new];
                                    topicVC.urlString = @"http://www.v2ex.com/my/topics";
                                    topicVC.title = @"话题收藏";
                                    topicVC.topicType = WTTopicTypeCollection;
                                    [weakSelf.navigationController pushViewController: topicVC animated: YES];
                                }],
                                
                                [WTSettingItem settingItemWithTitle: @"主题选择" image: [UIImage imageNamed: @"mine_theme"] operationBlock: nil],
                                [WTSettingItem settingItemWithTitle: @"我的回复" image: [UIImage imageNamed: @"more_systemnoti"] operationBlock: ^{
            
                                        [weakSelf.navigationController pushViewController: [WTMyReplyViewController new] animated: YES];
                                    }],
                                ]];
        
        [_datas addObject: @[
                                [WTSettingItem settingItemWithTitle: @"广告投放" image: [UIImage imageNamed: @"more_ad"] operationBlock: ^{
            
                                    [weakSelf.navigationController pushViewController: [WTAdvertiseViewController new] animated: YES];
                                }],
                                
                                [WTSettingItem settingItemWithTitle: @"隐私声明" image: [UIImage imageNamed: @"more_privacystatement"] operationBlock: ^{
            
                                    [weakSelf.navigationController pushViewController: [WTPrivacyStatementViewController new] animated: YES];
                                }],
                                
                                [WTSettingItem settingItemWithTitle: @"项目源码" image: [UIImage imageNamed: @"more_project"] operationBlock: nil],
                                
                                [WTSettingItem settingItemWithTitle: @"关于作者" image: [UIImage imageNamed: @"more_about"] operationBlock: nil],
                                
                                [WTSettingItem settingItemWithTitle: @"退出帐号" image: [UIImage imageNamed: @"more_logout"] operationBlock: ^{
        
                                }],
                                
                            ]];
    }
    return _datas;
}

- (NSMutableArray *)titles
{
    if (_titles == nil)
    {
        _titles = [NSMutableArray array];
        
        [_titles addObjectsFromArray: @[@"个人中心", @"设置"]];
    }
    return _titles;
}

- (UIView *)headerContentView
{
    if (_headerContentView == nil)
    {
        // 1、headerView
        UIView *headerContentView = [UIView new];
        headerContentView.frame = CGRectMake(0, 0, WTScreenWidth, WTScreenHeight - WTTabBarHeight);
        [self.view addSubview: headerContentView];
        
        headerContentView.backgroundColor = [UIColor colorWithHexString: WTAppLightColor];
        
        _headerContentView = headerContentView;
    }
    return _headerContentView;
}

- (UIView *)footerContentView
{
    if(_footerContentView == nil)
    {
        // 2、footerView
        UIView *footerContentView = [UIView new];
        footerContentView.layer.cornerRadius = 5;
        footerContentView.layer.masksToBounds = YES;
        footerContentView.frame = CGRectMake(0, moreHeaderViewH, WTScreenWidth, WTScreenHeight - moreHeaderViewH);
        [self.view addSubview: footerContentView];
        _footerContentView = footerContentView;
    }
    return _footerContentView;
}

- (WTMoreLoginHeaderView *)moreLoginHeaderView
{
    if (_moreLoginHeaderView == nil)
    {
        WTMoreLoginHeaderView *moreLoginHeaderView = [WTMoreLoginHeaderView moreLoginHeaderView];
        [self.headerContentView addSubview: moreLoginHeaderView];
        _moreLoginHeaderView = moreLoginHeaderView;
        
        moreLoginHeaderView.frame = CGRectMake(0, 0, WTScreenWidth, moreHeaderViewH);
    }
    return _moreLoginHeaderView;
}

- (WTMoreNotLoginHeaderView *)moreNotLoginHeaderView
{
    if (_moreNotLoginHeaderView == nil)
    {
        WTMoreNotLoginHeaderView *moreNotLoginHeaderView = [WTMoreNotLoginHeaderView moreNotLoginHeaderView];
        moreNotLoginHeaderView.frame = CGRectMake(0, 0, WTScreenWidth, moreHeaderViewH);
        [self.headerContentView addSubview: moreNotLoginHeaderView];
        moreNotLoginHeaderView.delegate = self;
        _moreNotLoginHeaderView = moreNotLoginHeaderView;
    }
    return _moreNotLoginHeaderView;
}
@end
