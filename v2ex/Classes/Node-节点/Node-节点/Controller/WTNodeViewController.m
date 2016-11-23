//
//  WTNodeViewController.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/7/21.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//  节点控制器

#import "WTNodeViewController.h"
#import "WTNodeViewModel.h"
#import "WTHotNodeViewController.h"
#import "WTHotNodeFlowLayout.h"
#import "WTAllNodeViewController.h"
#import "WTConst.h"
#import "NetworkTool.h"

@interface WTNodeViewController ()
/** 热门节点View */
@property (nonatomic, weak) UICollectionView *hotNodeCollectionView;
/** 所有节点View */
@property (nonatomic, weak) UITableView *allNodeTableView;

@end

@implementation WTNodeViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    // 设置View
    [self setupView];
    
    // 加载数据
    [self setupData];
}

/**
 *  设置View
 */
- (void)setupView
{
    // 0、设置nav的titleView
    UISegmentedControl *control = [[UISegmentedControl alloc] initWithItems: @[@"最热", @"全部"]];
    control.selectedSegmentIndex = 0;
    control.width = 150;
    control.tintColor = [UIColor whiteColor];
    
    [control setTitleTextAttributes: @{NSForegroundColorAttributeName : [UIColor whiteColor]} forState: UIControlStateNormal];
    [control setTitleTextAttributes: @{NSForegroundColorAttributeName : [UIColor colorWithHexString: WTAppLightColor]} forState:UIControlStateSelected];
    
    [control addTarget: self action: @selector(segmentedControlValueChanged:) forControlEvents: UIControlEventValueChanged];
    
    self.navigationItem.titleView = control;
    
    // 1、添加热点节点控制器
    WTHotNodeViewController *hotNodeVC = [[WTHotNodeViewController alloc] initWithCollectionViewLayout: [WTHotNodeFlowLayout new]];
    [self addChildViewController: hotNodeVC];
    self.hotNodeCollectionView = hotNodeVC.collectionView;
    [self.view addSubview: self.hotNodeCollectionView];
    self.hotNodeCollectionView.frame = self.view.bounds;
}

/**
 *  加载数据
 */
- (void)setupData
{
    
}

#pragma mark - 事件
/**
 *  segmentedControl 事件
 *
 *  @param control segmentedControl
 */
- (void)segmentedControlValueChanged:(UISegmentedControl *)control
{
    if (control.selectedSegmentIndex == 0)
    {
        [self.allNodeTableView removeFromSuperview];
        [self.view addSubview: self.hotNodeCollectionView];
    }
    else
    {
        [self.hotNodeCollectionView removeFromSuperview];
        [self.view addSubview: self.allNodeTableView];

    }
}

#pragma mark - Layz Method
- (UITableView *)allNodeTableView
{
    if (_allNodeTableView == nil)
    {
        WTAllNodeViewController *allNodeVC = [[WTAllNodeViewController alloc] init];
        [self addChildViewController: allNodeVC];
        
        _allNodeTableView = allNodeVC.tableView;
        _allNodeTableView.frame = CGRectMake(0, WTNavigationBarMaxY, WTScreenWidth, WTScreenHeight - WTNavigationBarMaxY - WTTabBarHeight);
        [self.view addSubview: _allNodeTableView];
    }
    return _allNodeTableView;
}
@end
