//
//  UIColor+Extension.h
//  驴宝宝
//
//  Created by 无头骑士 GJ on 15/8/8.
//  Copyright (c) 2015年 无头骑士 GJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Extension)
+ (UIColor *)colorWithHexString:(NSString *)color;

//从十六进制字符串获取颜色，
//color:支持@“#123456”、 @“0X123456”、 @“123456”三种格式
+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;
@end
