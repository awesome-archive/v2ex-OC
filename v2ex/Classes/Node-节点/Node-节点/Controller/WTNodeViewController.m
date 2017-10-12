//
//  WTNodeViewController.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/7/21.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//  节点控制器

#import "WTNodeViewController.h"
#import "UIViewController+Extension.h"
#import "WTHotNodeViewController.h"
#import "WTAllNodeViewController.h"

#import "WTHotNodeFlowLayout.h"

#import "WTNodeViewModel.h"

#import "WTConst.h"

#import "NetworkTool.h"

@interface WTNodeViewController ()
/** 热门节点View */
@property (nonatomic, weak) UICollectionView *hotNodeCollectionView;
/** 所有节点View */
@property (nonatomic, weak) UIView *allNodeView;

@property (weak, nonatomic) IBOutlet UIView *contentView;
@end

@implementation WTNodeViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    //self.navigationController.navigationBar.hidden = YES;
}

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
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 0、设置nav的titleView
    UISegmentedControl *control = [[UISegmentedControl alloc] initWithItems: @[@"最热", @"全部"]];
    control.selectedSegmentIndex = 0;
    control.width = 150;
    control.x = (WTScreenWidth - control.width) * 0.5;
    control.y = (WTTitleViewHeight - control.height) * 0.5 + WTNavigationBarCenterY;
    control.tintColor = WTSelectedColor;
    
    [control setTitleTextAttributes: @{NSForegroundColorAttributeName : WTSelectedColor} forState: UIControlStateNormal];
    [control setTitleTextAttributes: @{NSForegroundColorAttributeName : [UIColor whiteColor]} forState:UIControlStateSelected];
    
    [control addTarget: self action: @selector(segmentedControlValueChanged:) forControlEvents: UIControlEventValueChanged];
    
    
    [self navView];
    [self.nav_View addSubview: control];
    
    // 1、添加热点节点控制器
    WTHotNodeViewController *hotNodeVC = [[WTHotNodeViewController alloc] initWithCollectionViewLayout: [WTHotNodeFlowLayout new]];
    [self addChildViewController: hotNodeVC];
    self.hotNodeCollectionView = hotNodeVC.collectionView;
    [self.contentView addSubview: self.hotNodeCollectionView];
    self.hotNodeCollectionView.frame = self.contentView.bounds;
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
        
        [self.contentView bringSubviewToFront: self.hotNodeCollectionView];
    }
    else
    {
        [self.contentView bringSubviewToFront: self.allNodeView];
        
    }
}

#pragma mark - Layz Method
- (UIView *)allNodeView
{
    if (_allNodeView == nil)
    {
        WTAllNodeViewController *allNodeVC = [[WTAllNodeViewController alloc] init];
        [self addChildViewController: allNodeVC];
        
        _allNodeView = allNodeVC.view;
        _allNodeView.frame = self.contentView.bounds;
        [self.contentView addSubview: _allNodeView];
    }
    return _allNodeView;
}
@end
