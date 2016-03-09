//
//  WTSettingItem.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/2/27.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTSettingItem.h"

@implementation WTSettingItem

/**
 *  快速创建的类方法
 *
 */
+ (instancetype)itemWithTitle:(NSString *)title  action:(void(^)(NSIndexPath *indexPath))myBlock
{
    WTSettingItem *item = [WTSettingItem new];
    item.title = title;
    item.myBlock = myBlock;
    return item;
}

/**
 *  快速创建的类方法
 *
 */
+ (instancetype)itemWithTitle:(NSString *)title subTitle:(NSString *)subTitle action:(void(^)(NSIndexPath *indexPath))myBlock
{
    WTSettingItem *item = [self itemWithTitle: title action: myBlock];
    item.subTitle = subTitle;
    return item;
}
@end
