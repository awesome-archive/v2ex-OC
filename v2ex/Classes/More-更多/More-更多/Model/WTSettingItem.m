//
//  WTSettingItem.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/7/25.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTSettingItem.h"

@implementation WTSettingItem

+ (instancetype)settingItemWithTitle:(NSString *)title image:(UIImage *)image operationBlock:(void(^)())operationBlock
{
    WTSettingItem *item = [WTSettingItem new];
    
    item.title = title;
    item.image = image;
    item.operationBlock = operationBlock;
    
    return item;
}

@end
