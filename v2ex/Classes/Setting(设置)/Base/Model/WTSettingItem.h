//
//  WTSettingItem.h
//  v2ex
//
//  Created by 无头骑士 GJ on 16/2/27.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WTSettingItem : NSObject

/** 图标 */
@property (nonatomic, strong) UIImage           *icon;

/** 标题 */
@property (nonatomic, strong) NSString          *title;

/** 标题颜色 */
@property (nonatomic, strong) UIColor           *titleColor;

/** 标题字体 */
@property (nonatomic, strong) UIFont            *titleFont;

/** 子标题 */
@property (nonatomic, strong) NSString          *subTitle;

/** 子标题颜色 */
@property (nonatomic, strong) UIColor           *subTitleColor;

/** 子标题字体 */
@property (nonatomic, strong) UIFont            *subTitleFont;

/** cell的背景颜色 */
@property (nonatomic, strong) UIColor           *backgroundColor;

/** 点击cell的事件 */
@property (nonatomic, strong) void(^myBlock)(NSIndexPath *indexPath);

/**
 *  快速创建的类方法
 *
 */
+ (instancetype)itemWithTitle:(NSString *)title  action:(void(^)(NSIndexPath *indexPath))myBlock;

/**
 *  快速创建的类方法
 *
 */
+ (instancetype)itemWithTitle:(NSString *)title subTitle:(NSString *)subTitle action:(void(^)(NSIndexPath *indexPath))myBlock;

@end
