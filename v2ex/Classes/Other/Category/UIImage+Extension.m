//
//  UIImage+Extension.m
//  WTNews
//
//  Created by 无头骑士 GJ on 15/12/8.
//  Copyright © 2015年 耿杰. All rights reserved.
//

#import "UIImage+Extension.h"

@implementation UIImage (Extension)


/**
 *  加载原始图片，没有系统渲染
 *
 *  @param imageName 图片名称
 *
 *  @return 返回原始图片对象
 */
+ (instancetype)imageWithOriginalName:(NSString *)imageName
{
    UIImage *image = [UIImage imageNamed: imageName];
    return [image imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
}

/**
 *  图片拉伸
 *
 *  @param imageName 图片名
 */
+ (UIImage *)resizingImageWithImageName:(NSString *)imageName
{
    UIImage *image = [UIImage imageNamed: imageName];
    image = [image resizableImageWithCapInsets: UIEdgeInsetsMake(image.size.height * 0.5, image.size.width * 0.5, image.size.height * 0.5 - 1,  image.size.width * 0.5 - 1)];
    
    return image;
}

// 根据颜色生成一张尺寸为1*1的相同颜色图片
+ (UIImage *)imageWithColor:(UIColor *)color
{
    // 描述矩形
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    
    // 开启位图上下文
    UIGraphicsBeginImageContext(rect.size);
    // 获取位图上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 使用color演示填充上下文
    CGContextSetFillColorWithColor(context, [color CGColor]);
    // 渲染上下文
    CGContextFillRect(context, rect);
    // 从上下文中获取图片
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    // 结束上下文
    UIGraphicsEndImageContext();
    
    return theImage;
}
/**
 *  生成带边框的圆形图片
 *
 *  @param borderW 边框宽度
 *  @param color   边框颜色
 *  @param image   图片
 *
 *  @return 新的图片对象
 */
+ (UIImage *)imageWithBorderW:(CGFloat)borderW color:(UIColor *)color image:(UIImage *)image;
{
    
    CGSize imageSize = CGSizeMake(image.size.width + 2 * borderW, image.size.height + 2 * borderW);
    
    // 1、开启上下文
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, YES);
    
    // 2、绘制一个大圆
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(0, 0, imageSize.width, imageSize.height)];
    
    [color set];
    // 3、填充
    [path fill];
    
    // 4、设置裁剪路径
    path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(borderW, borderW, image.size.width, image.size.height)];
    
    // 5、裁剪
    [path addClip];
    
    // 6、把圆绘制到上下文中
    [image drawInRect: CGRectMake(borderW, borderW, image.size.width, image.size.height)];
    
    // 7、获取新的图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 8、关闭上下文
    UIGraphicsEndImageContext();
    
    // 9、返回新的图片
    return newImage;
    
}


/**
 *  返回一个圆角图片
 *
 *  @return 圆角图片
 */
- (instancetype)roundImage
{
    // 开启位图上下文
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0);
    
    // 添加路径
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(0, 0, self.size.width, self.size.height)];
    
    // 剪裁路径
    [path addClip];
    
    // 绘图
    [self drawAtPoint: CGPointZero];
    
    // 新图
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 关闭位图上下文
    UIGraphicsEndImageContext();
    
    return newImage;
}


/**
 *  根据cornerRadius返回圆角图片
 *
 *  @return 圆角图片
 */
- (instancetype)roundImageWithCornerRadius:(CGFloat)cornerRadius
{
    // 开启位图上下文
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0);
    
    // 添加路径
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(0, 0, self.size.width, self.size.height) cornerRadius: cornerRadius];
    
    // 剪裁路径
    [path addClip];
    
    // 绘图
    [self drawAtPoint: CGPointZero];
    
    // 新图
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 关闭位图上下文
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
