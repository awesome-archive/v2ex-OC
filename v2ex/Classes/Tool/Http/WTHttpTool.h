//
//  WTHttpTool.h
//  WTNews
//
//  Created by 无头骑士 GJ on 15/12/8.
//  Copyright © 2015年 耿杰. All rights reserved.
//  处理网络请求

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WTHTTPUrlType) {
    WTHTTPUrlTypeNormal = 0,    // 默认
    WTHTTPUrlTypeLogin          // 登陆
};

@interface WTHttpTool : NSObject

/**
 *  GET请求
 *
 *  @param urlString  请求的url
 *  @param parameters 请求的参数
 *  @param success    请求成功的回调
 *  @param failure    请求失败的回调
 */
+ (void)GET:(NSString *)urlString parameters:(id)parameters success:(void(^)(id responseObject))success failure:(void(^)(NSError *error))failure;


/**
 *  POST请求
 *
 *  @param urlString  请求的url
 *  @param parameters 请求的参数
 *  @param success    请求成功的回调
 *  @param failure    请求失败的回调
 */
+ (void)POST:(NSString *)urlString parameters:(id)parameters success:(void(^)(id responseObject))success failure:(void(^)(NSError *error))failure;


/**
 *  POST请求
 *
 *  @param urlString  地址
 *  @param parameters 参数
 *  @param success    请求成功的回调
 *  @param failure    请求失败的回调
 */
+ (void)POSTHTML:(NSString *)urlString parameters:(id)parameters success:(void(^)(id responseObject))success failure:(void(^)(NSError *error))failure;


+ (void)GETHTML:(NSString *)urlString parameters:(id)parameters success:(void(^)(id responseObject))success failure:(void(^)(NSError *error))failure;


@end
