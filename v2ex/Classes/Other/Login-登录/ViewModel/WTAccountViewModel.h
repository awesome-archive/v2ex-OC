//
//  WTAccountViewModel.h
//  v2ex
//
//  Created by 无头骑士 GJ on 16/3/16.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WTAccount.h"
@interface WTAccountViewModel : NSObject

@property (nonatomic, strong) WTAccount *account;

/**
 *  单例
 *
 */
+ (instancetype)shareInstance;

/**
 *  自动登陆
 */
- (void)autoLogin;

/**
 *  是否登陆过
 *
 */
- (BOOL)isLogin;

- (void)saveUsernameAndPassword;

/**
 *  登陆
 *
 *  @param username 用户名
 *  @param password 密码
 *  @param success  请求成功的回调
 *  @param failure  请求失败的回调
 */
- (void)getOnceWithUsername:(NSString *)username password:(NSString *)password success:(void (^)())success failure:(void (^)(NSError *error))failure;

/**
 *  获取验证码图片的url
 *
 *  @param success 请求成功的回调
 *  @param failure 请求失败的回调
 */
- (void)getVerificationCodeUrlWithSuccess:(void (^)(NSString *codeUrl))success failure:(void (^)(NSError *error))failure;
/**
 *  注册
 *
 *  @param username 用户名
 *  @param password 密码
 *  @param email    邮箱
 *  @param c        验证码
 *  @param success  请求成功的回调
 *  @param failure  请求失败的回调
 */
- (void)registerWithUsername:(NSString *)username password:(NSString *)password email:(NSString *)email c:(NSString *)c success:(void (^)(BOOL isSuccess))success failure:(void(^)(NSError *error))failure;
@end
