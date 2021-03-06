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
#import "WTMyFollowingViewController.h"
#import "WTTopicViewController.h"
#import "WTTopicCollectionViewController.h"
#import "WTWebViewController.h"
#import "WTNodeCollectionViewController.h"
#import "WTMyTopicViewController.h"
#import "WTV2GroupViewController.h"

#import "WTMoreNotLoginHeaderView.h"
#import "WTMoreLoginHeaderView.h"
#import "WTMoreCell.h"

#import "WTAccountViewModel.h"
#import "WTSettingItem.h"


NSString * const moreCellIdentifier = @"moreCellIdentifier";

CGFloat const moreHeaderViewH = 150;

@interface WTMoreViewController () <UITableViewDataSource, UITableViewDelegate, WTMoreNotLoginHeaderViewDelegate>

@property (nonatomic, weak) UIView                      *headerContentView;
@property (nonatomic, weak) UIView                      *footerContentView;
@property (nonatomic, weak) UITableView                 *tableView;
@property (nonatomic, weak) WTMoreLoginHeaderView       *moreLoginHeaderView;
@property (nonatomic, weak) WTMoreNotLoginHeaderView    *moreNotLoginHeaderView;
@property (nonatomic, strong) UIAlertController         *loginC;                        // 退出登录的对话框

@property (nonatomic, strong) NSMutableArray            *datas;
@property (nonatomic, strong) NSMutableArray            *titles;

@property (nonatomic, assign) CGFloat                   endY;                           // 记录scrollView的contentOff的Y值

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
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self headerContentView];
    
    // 1、UITableView
    UITableView *tableView = [UITableView new];
    
    {
        self.footerContentView.height = WTScreenHeight -  moreHeaderViewH - WTTabBarHeight;
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
        self.moreLoginHeaderView.account = [WTAccountViewModel shareInstance].account;
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

#pragma mark - Private Method
// 判断是否登陆，如果登录正常跳转转，否则跳转至登陆页面
- (void)checkIsLoginWithViewController:(UIViewController *)vc
{
    if ([WTAccountViewModel shareInstance].isLogin)
    {
        [self.navigationController pushViewController: vc animated: YES];
    }
    else
    {
        [self presentViewController: [WTLoginViewController new] animated: YES completion: nil];
    }
}

#pragma mark - Lazy Method
- (NSMutableArray<NSArray *> *)datas
{
    if (_datas == nil)
    {
        _datas = [NSMutableArray array];
    
        __weak typeof(self) weakSelf = self;
        
        [_datas addObject: @[
                             
                             
                                [WTSettingItem settingItemWithTitle: @"节点收藏" image: [UIImage imageNamed: @"mine_favourite"] operationBlock: ^{
            
                                    [weakSelf checkIsLoginWithViewController: [WTNodeCollectionViewController new]];
                                }],
            
                                [WTSettingItem settingItemWithTitle: @"特别关注" image: [UIImage imageNamed: @"mine_follow"] operationBlock: ^{
            
                                    [weakSelf checkIsLoginWithViewController: [WTMyFollowingViewController new]];
                                }],
                                
                                [WTSettingItem settingItemWithTitle: @"话题收藏" image: [UIImage imageNamed: @"more_collection"] operationBlock: ^{
            
                                    [weakSelf checkIsLoginWithViewController: [WTTopicCollectionViewController new]];
                                }],
                                
                                [WTSettingItem settingItemWithTitle: @"我的话题" image: [UIImage imageNamed: @"mine_topic"] operationBlock: ^{
                                    WTMyTopicViewController *myTopicVC = [WTMyTopicViewController new];
            
                                    [weakSelf checkIsLoginWithViewController: myTopicVC];
                                }],
            
                                [WTSettingItem settingItemWithTitle: @"我的回复" image: [UIImage imageNamed: @"more_systemnoti"] operationBlock: ^{
            
                                    [weakSelf checkIsLoginWithViewController: [WTMyReplyViewController new]];
                                }],
                                
#if Test == 0
                                [WTSettingItem settingItemWithTitle: @"v2小组" image: [UIImage imageNamed: @"more_group"] operationBlock: ^{
            
                                    [weakSelf checkIsLoginWithViewController: [WTV2GroupViewController new]];
                                }],
#else
#endif
                            ]];
        
        [_datas addObject: @[
                                [WTSettingItem settingItemWithTitle: @"广告中心" image: [UIImage imageNamed: @"more_ad"] operationBlock: ^{
            
                                    [weakSelf.navigationController pushViewController: [WTAdvertiseViewController new] animated: YES];
                                }],
                                
                                [WTSettingItem settingItemWithTitle: @"隐私声明" image: [UIImage imageNamed: @"more_privacystatement"] operationBlock: ^{
            
                                    [weakSelf.navigationController pushViewController: [WTPrivacyStatementViewController new] animated: YES];
                                }],
                                
                                [WTSettingItem settingItemWithTitle: @"项目源码" image: [UIImage imageNamed: @"more_project"] operationBlock: ^{
        
                                    WTWebViewController *webVC = [WTWebViewController new];
                                    webVC.url = [NSURL URLWithString: @"https://github.com/misaka14/v2ex-OC"];
                                    [weakSelf.navigationController pushViewController: webVC animated: YES];
                                }],
                                
                                [WTSettingItem settingItemWithTitle: @"关于V2EX" image: [UIImage imageNamed: @"more_about"] operationBlock: ^{
                                        WTWebViewController *webVC = [WTWebViewController new];
                                        webVC.url = [NSURL URLWithString: @"https://www.v2ex.com/about"];
                                        [weakSelf.navigationController pushViewController: webVC animated: YES];
                                }],
                                
                                [WTSettingItem settingItemWithTitle: @"退出帐号" image: [UIImage imageNamed: @"more_logout"] operationBlock: ^{
        
                                    [weakSelf presentViewController: weakSelf.loginC animated: YES completion: nil];
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
        footerContentView.frame = CGRectMake(0, moreHeaderViewH, WTScreenWidth, WTScreenHeight - moreHeaderViewH - WTTabBarHeight);
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

- (UIAlertController *)loginC
{
    if (_loginC == nil)
    {
        
        UIAlertController *loginC = [UIAlertController alertControllerWithTitle: @"提示" message: @"您确定要退出吗?" preferredStyle: UIAlertControllerStyleAlert];
        
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle: @"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
            // 清除帐号
            [[WTAccountViewModel shareInstance] loginOut];
            [self viewWillAppear: YES];
            
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle: @"手滑了" style: UIAlertActionStyleCancel handler: nil];
        
        [loginC addAction: sureAction];
        [loginC addAction: cancelAction];

        _loginC = loginC;
    }
    return _loginC;
}

@end
