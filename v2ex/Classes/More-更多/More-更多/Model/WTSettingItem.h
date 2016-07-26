//
//  WTSettingItem.h
//  v2ex
//
//  Created by 无头骑士 GJ on 16/7/25.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WTSettingItem : NSObject

@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) void(^operationBlock)();

+ (instancetype)settingItemWithTitle:(NSString *)title image:(UIImage *)image operationBlock:(void(^)())operationBlock;

@end
