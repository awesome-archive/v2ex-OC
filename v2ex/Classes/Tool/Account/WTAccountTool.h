//
//  WTAccountTool.h
//  v2ex
//
//  Created by 无头骑士 GJ on 16/2/20.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WTAccountParam.h"
#import "WTUser.h"

#import "WTTopic.h"
@interface WTAccountTool : NSObject

/**
 *  登陆
 *
 *  @param param   请求参数
 *  @param success 请求成功的回调
 *  @param failure 请求失败的回调
 */
+ (void)loginWithParam:(WTAccountParam *)param success:(void(^)())success failure:(void(^)(NSError *error))failure;

/**
 *  获取某个节点的话题数据
 *
 *  @param urlString url
 *  @param success   请求成功的回调
 *  @param failure   请求失败的回调
 */
+ (void)getTopicsWithUrlString:(NSString *)urlString success:(void (^)(NSMutableArray *topics))success failure:(void(^)(NSError *error))failure;

/**
 *  获取用户信息
 *
 *  @param urlString 网址
 *  @param success   请求成功的回调
 *  @param failure   请求失败的回调
 */
+ (void)getUserInfoWithUrlString:(NSString *)urlString success:(void(^)(WTUser *user))success failure:(void(^)(NSError *error))failure;


/**
 *  获取用户的全部话题
 *
 *  @param urlString url
 *  @param success   请求成功的回调
 *  @param failure   请求失败的回调
 */
+ (void)getMeAllTopicWithUrlString:(NSString *)urlString success:(void(^)(NSMutableArray<WTTopic *> *topics))success failure:(void(^)(NSError *error))failure;
/**
 *  获取用户的回复话题
 *
 *  @param urlString url
 *  @param success   请求成功的回调
 *  @param failure   请求失败的回调
 */
+ (void)getReplyTopicsWithUrlString:(NSString *)urlString success:(void(^)(NSMutableArray<WTTopic *> *topics))success failure:(void(^)(NSError *error))failure;

/**
 *  领取今日奖励
 *
 *  @param urlString url
 *  @param success   请求成功的回调
 *  @param failure   请求失败的回调
 */
+ (void)signWithUrlString:(NSString *)urlString success:(void(^)())success failure:(void(^)(NSError *error))failure;


@end
