//
//  WTMoreViewController.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/7/25.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTMoreViewController.h"
#import "WTPrivacyStatementViewController.h"
#import "WTLoginViewController.h"
#import "WTRegisterViewController.h"
#import "WTMoreCell.h"
#import "WTMorePhotoCell.h"
#import "WTSettingItem.h"
#import "WTAdvertiseViewController.h"

NSString * const moreCellIdentifier = @"moreCellIdentifier";

NSString * const morePhotoCellIdentifier = @"morePhotoCellIdentifier";

@interface WTMoreViewController ()

@property (nonatomic, strong) NSMutableArray<NSArray *> *datas;

@end

@implementation WTMoreViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.sectionHeaderHeight = 10;
    self.tableView.sectionFooterHeight = CGFLOAT_MIN;
    
    [self.tableView registerClass: [WTMoreCell class] forCellReuseIdentifier: moreCellIdentifier];
    
    [self.tableView registerClass: [WTMorePhotoCell class] forCellReuseIdentifier: morePhotoCellIdentifier];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datas[section].count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        WTMorePhotoCell *morePhotoCell = [tableView dequeueReusableCellWithIdentifier: morePhotoCellIdentifier];
        
        return morePhotoCell;
    }
    else
    {
        WTMoreCell *moreCell = [tableView dequeueReusableCellWithIdentifier: moreCellIdentifier];
        
        WTSettingItem *item = self.datas[indexPath.section][indexPath.row];
        
        moreCell.imageView.image = item.image;
        
        moreCell.textLabel.text = item.title;
        
        return moreCell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        
    }
    else
    {
        WTSettingItem *item = self.datas[indexPath.section][indexPath.row];
        if (item.operationBlock)
        {
            item.operationBlock();
        }
    }
}

- (NSMutableArray<NSArray *> *)datas
{
    if (_datas == nil)
    {
        _datas = [NSMutableArray array];
    
        
        __weak typeof(self) weakSelf = self;
        
        [_datas addObject: @[@"123"]];
        
        
        [_datas addObject: @[
                                [WTSettingItem settingItemWithTitle: @"我的收藏" image: [UIImage imageNamed: @"ZHProfileListCellCollect_iOS7"] operationBlock: nil],
                            ]];
        
        [_datas addObject: @[
                                [WTSettingItem settingItemWithTitle: @"鸣谢" image: [UIImage imageNamed: @"ZHProfileListCellCollect_iOS7"] operationBlock: ^{
            
                                    [weakSelf.navigationController pushViewController: [WTAdvertiseViewController new] animated: YES];
                                }],
                                
                                [WTSettingItem settingItemWithTitle: @"隐私声明" image: [UIImage imageNamed: @"ZHProfileListCellCollect_iOS7"] operationBlock: ^{
            
                                    [weakSelf.navigationController pushViewController: [WTPrivacyStatementViewController new] animated: YES];
                                }],
                                
                                [WTSettingItem settingItemWithTitle: @"项目源代码" image: [UIImage imageNamed: @"ZHProfileListCellCollect_iOS7"] operationBlock: nil],
                                
                                [WTSettingItem settingItemWithTitle: @"关于作者" image: [UIImage imageNamed: @"ZHProfileListCellCollect_iOS7"] operationBlock: nil]
                                
                            ]];
    }
    return _datas;
}

@end
