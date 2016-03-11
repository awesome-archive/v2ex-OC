//
//  WTSettingCell.h
//  v2ex
//
//  Created by 无头骑士 GJ on 16/2/27.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WTSettingItem.h"
#import "WTArrowItem.h"
@interface WTSettingCell : UITableViewCell
/** cell的数据模型 */
@property (nonatomic, strong) WTSettingItem            *settingItem;
/**
 *  快速创建cell的类方法
 *
 *  @param tableView tableView
 *  @param style     cell的样式
 *
 *  @return LBBSettingCell
 */
+ (instancetype)cellWithTableView:(UITableView *)tableView style:(UITableViewCellStyle)style;
@end
