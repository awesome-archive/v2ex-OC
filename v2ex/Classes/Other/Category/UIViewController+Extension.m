//
//  UIViewController+Extension.m
//  v2ex
//
//  Created by gengjie on 16/8/26.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "UIViewController+Extension.h"

#import "UIImage+Extension.h"

@implementation UIViewController (Extension)

- (void)setTempNavImageView
{
    UIImageView *greeenView = [[UIImageView alloc] init];
    greeenView.image = [UIImage imageWithColor: [UIColor colorWithHexString: WTAppLightColor]];
    [self.view addSubview: greeenView];
    greeenView.frame = CGRectMake(0, 0, WTScreenWidth, 64);
}

/** 设置导航栏的背景图片 */
- (void)setNavBackgroundImage
{
    [self.navigationController.navigationBar setBackgroundImage: [UIImage imageWithColor: [UIColor colorWithHexString: WTAppLightColor]] forBarMetrics:UIBarMetricsDefault];
}

@end
