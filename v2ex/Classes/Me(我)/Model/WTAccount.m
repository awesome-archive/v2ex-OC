//
//  WTAccount.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/2/23.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTAccount.h"

#define WTUsernameOrEmail @"usernameOrEmail"
#define WTPassword @"password"
@implementation WTAccount

static WTAccount *_account;

+ (instancetype)shareAccount
{
    return [[self alloc] init];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _account = [super allocWithZone: zone];
        _account.usernameOrEmail = [[NSUserDefaults standardUserDefaults] objectForKey: WTUsernameOrEmail];
        _account.password = [[NSUserDefaults standardUserDefaults] objectForKey: WTPassword];
    });
    return _account;
}
/**
 *  保存帐号到偏好设置
 */
- (void)saveAccount
{
    NSParameterAssert(_account.usernameOrEmail);
    NSParameterAssert(_account.password);
    [[NSUserDefaults standardUserDefaults] setObject: _account.usernameOrEmail forKey: WTUsernameOrEmail];
    [[NSUserDefaults standardUserDefaults] setObject: _account.password forKey: WTPassword];
}

- (void)removeAccount
{
    _account.usernameOrEmail = @"";
    _account.password = @"";
}

/**
 *  是否已经登陆过
 *
 */
- (BOOL)isLogin
{
    if(_account.usernameOrEmail.length > 0)
        return true;
    return false;
}

@end
