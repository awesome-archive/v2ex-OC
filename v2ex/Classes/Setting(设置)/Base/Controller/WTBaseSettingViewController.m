//
//  WTBaseSettingViewController.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/2/27.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTBaseSettingViewController.h"

@interface WTBaseSettingViewController ()

@end

@implementation WTBaseSettingViewController

// 重写初始化方法
- (instancetype)init
{
    return [super initWithStyle: UITableViewStyleGrouped];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.showsVerticalScrollIndicator = NO;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.groups.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    WTGroupItem *groupItem = self.groups[section];
    return groupItem.items.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    WTSettingCell *cell = [WTSettingCell cellWithTableView: tableView style: UITableViewCellStyleValue1];
    
    // 取出组模型
    WTGroupItem *groupItem = self.groups[indexPath.section];
    
    // 取出对应的行模型
    WTSettingItem *settingItem = groupItem.items[indexPath.row];
    
    // 设置行模型
    cell.settingItem = settingItem;
    
    return cell;
}

#pragma mark - Table View delegate
#pragma mark 点击cell事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WTGroupItem *groupItem = self.groups[indexPath.section];
    WTSettingItem *settingItem = groupItem.items[indexPath.row];
    
    if (settingItem.myBlock)
    {
        settingItem.myBlock(indexPath);
    }
    else
    {
        if ([settingItem isKindOfClass: [WTArrowItem class]])
        {
            WTArrowItem *arrowItem = (WTArrowItem *)settingItem;
            
            if (arrowItem.targetClass == nil)
                return;
            
            UIViewController *vc = [[arrowItem.targetClass alloc] init];
            [self.navigationController pushViewController: vc animated: YES];
        }
    }
    
    // 取消cell选中的效果
    [self.tableView deselectRowAtIndexPath: indexPath animated: YES];
}

#pragma mark - lazy load
#pragma mark groups
- (NSMutableArray *)groups
{
    if (_groups == nil)
    {
        _groups = [NSMutableArray array];
    }
    return _groups;
}
@end
