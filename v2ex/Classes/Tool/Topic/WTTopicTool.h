//
//  WTHomeTool.h
//  v2ex
//
//  Created by 无头骑士 GJ on 16/1/14.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WTTopicDetail;
@interface WTTopicTool : NSObject


/**
 *  根据页数获取topic数组
 *
 *  @param page    页数
 *  @param success 请求成功的回调
 *  @param failure 请求失败的回调
 */
+ (void)getTopicsWithUrlString:(NSString *)urlString success:(void(^)(NSArray *topics))success failure:(void(^)(NSError *error))failure;

/**
 *  根据urlString获取topic详情
 *
 *  @param urlString url地址
 *  @param success   请求成功的回调
 *  @param failure   请求失败的回调
 */
+ (void)getTopicDetailWithUrlString:(NSString *)urlString success:(void(^)(NSArray *topicDetailArray))success failure:(void(^)(NSError *error))failure;

/**
 *  加入收藏或取消收藏
 *
 *  @param urlString      url地址
 *  @param topicDetailUrl 话题详情的url地址
 *  @param success        请求成功的回调
 *  @param failure        请求失败的回调
 */
+ (void)addOrCancelCollectionTopicWithUrlString:(NSString *)urlString topicDetailUrl:(NSString *)topicDetailUrl success:(void(^)(WTTopicDetail *authorTopicDetail))success failure:(void(^)(NSError *error))failure;
/**
 *  感谢作者
 *
 *  @param urlString      url地址
 *  @param topicDetailUrl 话题详情的url地址
 *  @param success        请求成功的回调
 *  @param failure        请求失败的回调
 */
+ (void)loveTopicWithUrlString:(NSString *)urlString topicDetailUrl:(NSString *)topicDetailUrl success:(void(^)(WTTopicDetail *authorTopicDetail))success failure:(void(^)(NSError *error))failure;
@end
