//
//  WTSettingCell.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/2/27.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTSettingCell.h"

@implementation WTSettingCell
/**
 *  快速创建cell的类方法
 *
 *  @param tableView tableView
 *  @param style     cell的样式
 *
 *  @return LBBSettingCell
 */
+ (instancetype)cellWithTableView:(UITableView *)tableView style:(UITableViewCellStyle)style
{
    static NSString *ID = @"settingCell";
    
    WTSettingCell *cell = [tableView dequeueReusableCellWithIdentifier: ID];
    
    if (cell == nil)
    {
        cell = [[WTSettingCell alloc] initWithStyle: style reuseIdentifier: ID];
    }
    return cell;
}
- (void)setSettingItem:(WTSettingItem *)settingItem
{
    _settingItem = settingItem;
    
    // 设置数据
    [self setupData];
    
    // 设置视图
    //[self setupView];
}

// 设置数据
- (void)setupData
{
    self.imageView.image = _settingItem.icon;
    
    self.textLabel.text = _settingItem.title;
    
    self.detailTextLabel.text = _settingItem.subTitle;
}

// 设置视图
- (void)setupView
{
    // 设置cell背景颜色
    if (_settingItem.backgroundColor)
    {
        self.backgroundColor = _settingItem.backgroundColor;
    }
    else
    {
        self.backgroundColor = [UIColor whiteColor];
    }
    
    //设置title的标题颜色
    if (_settingItem.titleColor)
    {
        self.textLabel.textColor = _settingItem.titleColor;
    }
    else
    {
        self.textLabel.textColor = [UIColor blackColor];
    }
    // 设置title的字体
    if (_settingItem.titleFont)
    {
        self.textLabel.font = _settingItem.titleFont;
    }
    else
    {
        self.textLabel.font = [UIFont systemFontOfSize: 14];
    }
    // 设置subTitle的文字颜色
    if (_settingItem.subTitleColor)
    {
        self.detailTextLabel.textColor = _settingItem.subTitleColor;
    }
    else
    {
        self.detailTextLabel.textColor = [UIColor grayColor];
    }
    
    // 设置subTitle的字体
    if (_settingItem.subTitleFont)
    {
        self.detailTextLabel.font = _settingItem.subTitleFont;
    }
    else
    {
        self.detailTextLabel.font = [UIFont systemFontOfSize: 14];
    }
    
    // 如果是带箭头的cell模型
    if ([_settingItem isKindOfClass: [WTArrowItem class]])
    {
        // 加上右箭头
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else
    {
        // 取消所有指示器
        self.accessoryType = UITableViewCellAccessoryNone;
    }
}

@end
