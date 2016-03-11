//
//  WTUserSettingViewController.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/2/28.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTUserSettingViewController.h"

@interface WTUserSettingViewController ()

@end

@implementation WTUserSettingViewController

- (instancetype)init
{
    return [super initWithStyle: UITableViewStylePlain];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 设置第一组
    [self setupGroup0];
}

#pragma mark  设置第一组
- (void)setupGroup0
{
    // 1、创建组
    WTGroupItem *groupItem = [WTGroupItem new];
    
    // 帖子字体
    WTArrowItem *item0 = [WTArrowItem itemWithTitle: @"帖子字体大小" subTitle: @"小" action:^(NSIndexPath *indexPath) {
        WTLog(@"123")
    }];
    // 清除缓存
    WTSettingItem *item1 = [WTSettingItem itemWithTitle: @"清除缓存" subTitle: @"0.0MB" action:^(NSIndexPath *indexPath) {
        WTLog(@"清除缓存")
    }];
    // 标签页顺序
    WTArrowItem *item2 = [WTArrowItem itemWithTitle: @"标签页顺序" action:^(NSIndexPath *indexPath) {
        WTLog(@"标签页顺序")
    }];
    
    // 3、添加到组模型中
    groupItem.items = @[item0, item1, item2];
    [self.groups addObject: groupItem];
}
@end
