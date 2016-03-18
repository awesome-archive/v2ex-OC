//
//  WTUserViewModel.h
//  v2ex
//
//  Created by 无头骑士 GJ on 16/3/18.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WTUser;
@interface WTUserViewModel : NSObject

/**
 *  加载用户信息
 *
 *  @param username 用户名
 *  @param success  请求成功的回调
 *  @param failure  请求失败的回调
 */
+ (void)loadUserInfoWithUsername:(NSString *)username success:(void (^)(WTUser *user))success failure:(void (^)(NSError *error))failure;


@end
