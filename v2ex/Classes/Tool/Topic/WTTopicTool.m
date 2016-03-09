//
//  WTHomeTool.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/1/14.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTTopicTool.h"
#import "WTHttpTool.h"
#import "WTTopic.h"
#import "WTTopicDetail.h"
#import "WTURLConst.h"
#import "WTHttpTool.h"

@implementation WTTopicTool
/**
 *  根据页数获取topic数组
 *
 *  @param page    页数
 *  @param success 请求成功的回调
 *  @param failure 请求失败的回调
 */
+ (void)getTopicsWithUrlString:(NSString *)urlString success:(void(^)(NSArray *topics))success failure:(void(^)(NSError *error))failure
{    
    [WTHttpTool GET: urlString parameters: nil success:^(id responseObject) {
        
        NSArray *topics = [WTTopic topicWithData: responseObject];
        if (success)
        {
            success(topics);
        }
        
    } failure:^(NSError *error) {
        
        if (failure)
        {
            failure(error);
        }
        
    }];
}

/**
 *  根据urlString获取topic详情
 *
 *  @param urlString url地址
 *  @param success   请求成功的回调
 *  @param failure   请求失败的回调
 */
+ (void)getTopicDetailWithUrlString:(NSString *)urlString success:(void(^)(NSArray *topicDetailArray))success failure:(void(^)(NSError *error))failure
{    
    [WTHttpTool GET: urlString parameters: nil success:^(id responseObject) {
        
        NSArray *topicDetailArray = [WTTopicDetail topicDetailWithData: responseObject];
        if (success)
        {
            success(topicDetailArray);
        }
        
    } failure:^(NSError *error) {
        if (failure)
        {
            failure(error);
        }
    }];
}

/**
 *  加入收藏或取消收藏
 *
 *  @param urlString url地址
 *  @param success   请求成功的回调
 *  @param failure   请求失败的回调
 */
+ (void)addOrCancelCollectionTopicWithUrlString:(NSString *)urlString topicDetailUrl:(NSString *)topicDetailUrl success:(void(^)(WTTopicDetail *authorTopicDetail))success failure:(void(^)(NSError *error))failure;
{
    urlString = [WTHTTPBaseUrl stringByAppendingPathComponent: urlString];
    
    [WTHttpTool GET: urlString parameters: nil success:^(id responseObject) {
        
        // 重新请求
        [WTHttpTool GET: topicDetailUrl parameters: nil success:^(id responseObject) {
            WTTopicDetail *authorTopicDetail = [WTTopicDetail authorTopicDetailWithData: responseObject];
            if (success)
            {
                success(authorTopicDetail);
            }
            
        } failure:^(NSError *error) {
            WTLog(@"addOrCancelCollectionTopicWithUrlString2:%@", error);
        }];
        
    } failure:^(NSError *error) {
        WTLog(@"addOrCancelCollectionTopicWithUrlString1:%@", error);
    }];
}

/**
 *  感谢作者
 *
 *  @param urlString      url地址
 *  @param topicDetailUrl 话题详情的url地址
 *  @param success        请求成功的回调
 *  @param failure        请求失败的回调
 */
+ (void)loveTopicWithUrlString:(NSString *)urlString topicDetailUrl:(NSString *)topicDetailUrl success:(void(^)(WTTopicDetail *authorTopicDetail))success failure:(void(^)(NSError *error))failure
{
    urlString = [WTHTTPBaseUrl stringByAppendingPathComponent: urlString];
    
    [WTHttpTool POST: urlString parameters: nil success:^(id responseObject) {
        
        // 重新请求
        [WTHttpTool GET: topicDetailUrl parameters: nil success:^(id responseObject) {
            WTTopicDetail *authorTopicDetail = [WTTopicDetail authorTopicDetailWithData: responseObject];
            if (success)
            {
                success(authorTopicDetail);
            }
            
        } failure:^(NSError *error) {
            WTLog(@"addOrCancelCollectionTopicWithUrlString2:%@", error);
        }];
        
    } failure:^(NSError *error) {
        WTLog(@"addOrCancelCollectionTopicWithUrlString1:%@", error);
    }];
}


@end
