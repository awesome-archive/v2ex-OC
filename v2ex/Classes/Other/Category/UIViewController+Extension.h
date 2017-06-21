//
//  UIViewController+Extension.h
//  v2ex
//
//  Created by gengjie on 16/8/26.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/message.h>

@interface UIViewController (Extension)

@property (nonatomic, weak) UILabel *titleLabel;

/** 设置导航栏的imageView */
- (void)setTempNavImageView;

/** 设置导航栏的背景图片 */
- (void)setNavBackgroundImage;

/** 添加导航栏 */
- (void)navViewWithTitle:(NSString *)title;
@end
