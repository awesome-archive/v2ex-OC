//
//  WTSettingViewController.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/2/27.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTSettingViewController.h"
#import "WTPrivacyStatementViewController.h"
@interface WTSettingViewController ()

@end

@implementation WTSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"设置";
    
    // 设置第一组
    [self setupGroup0];
}

#pragma mark  设置第一组
- (void)setupGroup0
{
    // 1、创建组
    WTGroupItem *groupItem = [WTGroupItem new];

    // 关注项目源代码
    WTArrowItem *item0 = [WTArrowItem itemWithTitle: @"关注项目源代码" action:^(NSIndexPath *indexPath) {
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"https://github.com/misaka14/v2ex"]];
    }];
    
    WTArrowItem *item1 = [WTArrowItem itemWithTitle: @"服务条款与协议" action:^(NSIndexPath *indexPath) {
       
        [self.navigationController pushViewController: [WTPrivacyStatementViewController new] animated: YES];
    }];
    
    // 3、添加到组模型中
    groupItem.items = @[item0, item1];
    [self.groups addObject: groupItem];
}

@end
