//
//  WTTabBarController.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/1/30.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTTabBarController.h"
#import "WTHomeViewController.h"
#import "WTNavigationController.h"
#import "WTNodeViewController.h"
#import "WTMeViewController.h"
#import "WTSettingViewController.h"
#import "WTUserInfoViewController.h"

@interface WTTabBarController ()

@end

@implementation WTTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 添加所有的子控制器
    [self addChildViewControllers];
}

#pragma mark - 添加所有的子控制器
- (void)addChildViewControllers
{
        // 节点
    //WTNodeViewController *nodeVC = [[WTNodeViewController alloc] init];
    //[self addOneChildViewController: nodeVC title: @"节点" imageName: @"tabbar_node_normal" selectedImageName: @"tabbar_node_selected"];
    
    // 首页
    WTHomeViewController *homeVC = [WTHomeViewController new];
    [self addOneChildViewController: homeVC title: @"首页" imageName: @"tabbar_home_normal" selectedImageName: @"tabbar_home_selected"];
    

    
    // 我
    WTUserInfoViewController *meVC = [WTUserInfoViewController new];
    [self addOneChildViewController: meVC title: @"我" imageName: @"tabbar_wo_normal" selectedImageName : @"tabbar_wo_selected"];
    
    // 设置
    WTSettingViewController *settingVC = [WTSettingViewController new];
    [self addOneChildViewController: settingVC title: @"设置" imageName: @"tabbar_setting_normal" selectedImageName: @"tabbar_setting_selected"];
}

#pragma mark - 添加单个子控制器
- (void)addOneChildViewController:(UIViewController *)vc title:(NSString *)title imageName:(NSString *)imageName selectedImageName:(NSString *)selectedImageName
{
    
    vc.tabBarItem.title = title;
    vc.tabBarItem.image = [UIImage imageNamed: imageName];
    vc.tabBarItem.selectedImage = [UIImage imageNamed: selectedImageName];
    
    // 设置文字正常状态属性
    NSDictionary *textAttrNormal = @{NSForegroundColorAttributeName : [UIColor colorWithHexString: WTNormalColor]};
    [vc.tabBarItem setTitleTextAttributes: textAttrNormal forState: UIControlStateNormal];
    
    // 设置文字选中状态下属性
    NSDictionary *textAttrSelected = @{NSForegroundColorAttributeName : [UIColor colorWithHexString: WTNoNormalColor]};
    [vc.tabBarItem setTitleTextAttributes: textAttrSelected forState: UIControlStateSelected];
    
    WTNavigationController *nav = [[WTNavigationController alloc] initWithRootViewController: vc];
    [self addChildViewController: nav];
}

@end
