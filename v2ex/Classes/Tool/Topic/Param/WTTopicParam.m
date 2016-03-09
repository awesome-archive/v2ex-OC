//
//  WTBlogParam.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/1/15.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTTopicParam.h"
#import "WTURLConst.h"
#import "WTTopic.h"
@implementation WTTopicParam

/**
 *  快速创建的类方法
 *
 *  @param urlSuffix    url后缀
 *  @param page         第几页
 *
 *  @return             WTBlogParam
 */
+ (instancetype)topicParamWithUrlString:(NSString *)urlString page:(NSInteger)page
{
    WTTopicParam *param = [[self alloc] init];
    param.urlString = urlString;
    param.page = page;
    return param;
}


/**
 *  获取完整的路径
 *
 *  @return 路径
 */
- (NSString *)url
{
    NSParameterAssert(_urlString);
    NSParameterAssert(_page);
    if ([WTTopic isNewestNodeWithUrlSuffix: _urlString])
    {
        _urlString = [NSString stringWithFormat: @"%@?p=%ld", _urlString, _page];
    }
    else
    {
        _urlString = [NSString stringWithFormat: @"%@", _urlString];
    }
    
    return [WTHTTPBaseUrl stringByAppendingPathComponent: _urlString];
}

@end
