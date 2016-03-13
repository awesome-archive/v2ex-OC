//
//  WTParseTool.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/3/14.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTParseTool.h"
#import "WTURLConst.h"
@implementation WTParseTool

/**
 *  把小图url解析成大图的Url
 *
 *  @param smallUrl 小图的Url
 *
 *  @return 大图的Url
 */
+ (NSURL *)parseBigImageUrlWithSmallImageUrl: (NSString *)smallImageUrl
{
    // 1、头像 (由于v2ex抓下来的都不是清晰的头像，替换字符串转换成相对清晰的URL)
    NSString *iconStr = smallImageUrl;
    if ([smallImageUrl containsString: @"normal.png"])
    {
        iconStr = [smallImageUrl stringByReplacingOccurrencesOfString: @"normal.png" withString: @"large.png"];
    }
    else if([smallImageUrl containsString: @"s=48"])
    {
        iconStr = [smallImageUrl stringByReplacingOccurrencesOfString: @"s=48" withString: @"s=96"];
    }
    return [NSURL URLWithString: [WTHTTP stringByAppendingString: iconStr]];
}

@end
