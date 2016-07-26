//
//  WTUserInfoHeadView.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/3/21.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTUserInfoHeadView.h"

@implementation WTUserInfoHeadView

+ (instancetype)userInfoHeadView
{
    return [[NSBundle mainBundle] loadNibNamed: NSStringFromClass([self class]) owner: nil options: nil].firstObject;
}

@end
