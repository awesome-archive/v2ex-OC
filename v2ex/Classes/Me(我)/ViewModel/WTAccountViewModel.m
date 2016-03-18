//
//  WTAccountViewModel.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/3/16.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTAccountViewModel.h"
#import "WTAccount.h"
#import "TFHpple.h"
#import "NetworkTool.h"
#import "WTURLConst.h"

#define WTFilePath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent: @"account.plist"]

@implementation WTAccountViewModel

static WTAccountViewModel *_instance;

+ (instancetype)shareInstance
{
    return [[self alloc] init];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone: zone];
        _instance.account = [NSKeyedUnarchiver unarchiveObjectWithFile: WTFilePath];
        if (_instance.account == nil)
        {
            _instance.account = [WTAccount new];
        }
    });
    return _instance;
}

/**
 *  自动登陆
 */
- (void)autoLogin
{
    if (self.isLogin)
    {
        NSString *username = self.account.usernameOrEmail;
        NSString *password = self.account.password;
        [[WTAccountViewModel shareInstance] getOnceWithUsername: username password: password success:^{
            
        } failure:^(NSError *error) {
            
        }];
    }
}

/**
 *  是否登陆过
 *
 */
- (BOOL)isLogin
{
    return [WTAccountViewModel shareInstance].account.usernameOrEmail.length > 0;
}

/**
 *  登陆
 *
 *  @param username 用户名
 *  @param password 密码
 *  @param success  请求成功的回调
 *  @param failure  请求失败的回调
 */
- (void)getOnceWithUsername:(NSString *)username password:(NSString *)password success:(void (^)())success failure:(void (^)(NSError *error))failure
{
    void (^errorBlock)(NSError *error) = ^(NSError *error){
        if (failure)
        {
            failure(error);
        }
    };
    
    
    // 1、切换帐号有缓存问题
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies])
    {
        [storage deleteCookie:cookie];
    }
    
    // 2、获取网页中once的值
    NSString *urlString = [WTHTTPBaseUrl stringByAppendingPathComponent: WTLoginUrl];
    [[NetworkTool shareInstance] requestWithMethod: HTTPMethodTypeGET url: urlString param: nil success:^(id responseObject) {
        
        // 2.1、获取网页中once的值
        NSString *once = [WTAccountViewModel getOnceWithData: responseObject];
        
        if (once == nil)
        {
            WTLog(@"once获取不到")
            return;
        }
        
        // 2.2、请求参数
        NSDictionary *param = @{
                                @"u" : username,
                                @"p" : password,
                                @"once" : once,
                                @"next" : @"/"
                                };
        
        // 2.3、发起请求
        [[WTAccountViewModel shareInstance] loginWithUrlString: urlString param: param success:^{
            
            if (success)
            {
                success();
            }
            
        } failure: errorBlock];
        
    } failure: errorBlock];
}

/**
 *  登陆
 *
 *  @param urlString url
 *  @param param     请求请求参数
 *  @param success   请求成功的回调
 *  @param failure   请求失败的回调
 */
- (void)loginWithUrlString:(NSString *)urlString param:(NSDictionary *)param success:(void (^)())success failure:(void (^)(NSError *error))failure
{
    [[NetworkTool shareInstance] requestWithMethod: HTTPMethodTypePOST url: urlString param: param success:^(id responseObject) {
        
        NSString *html = [[NSString alloc] initWithData: responseObject encoding: NSUTF8StringEncoding];
        
        // 判断是否登陆成功
        if ([html containsString: @"notifications"])        // 登陆成功
        {
            WTLog(@"登陆成功")
            [NSKeyedArchiver archiveRootObject: self.account toFile: WTFilePath];
            
            // 是否已经领取过奖励
            if ([html containsString: @"领取今日的登录奖励"])
            {
                
            }
            self.account.usernameOrEmail = param[@"u"];
            self.account.password = param[@"p"];
            [NSKeyedArchiver archiveRootObject: self.account toFile: WTFilePath];
            
            if (success)
            {
                success();
            }
            return;
        }
        
        NSError *error = nil;
        if([html containsString: @"用户名和密码无法匹配"])
        {
            error = [NSError errorWithDomain: WTDomain code: -1011 userInfo: @{@"message" : @"用户名和密码无法匹配"}];
            WTLog(@"用户名和密码无法匹配")
        }
        else
        {
            WTLog(@"登陆未知错误")
            WTLog(@"html:%@", [[NSString alloc] initWithData: responseObject encoding: NSUTF8StringEncoding])
            error = [NSError errorWithDomain: WTDomain code: -1011 userInfo: @{@"message" : @"未知错误"}];
        }
        
        if (failure)
        {
            failure(error);
        }
        
    } failure:^(NSError *error) {
        if (error)
        {
            failure(error);
        }
    }];
}

/**
 *  获取验证码图片的url
 *
 *  @param success 请求成功的回调
 *  @param failure 请求失败的回调
 */
- (void)getVerificationCodeUrlWithSuccess:(void (^)(NSString *codeUrl))success failure:(void (^)(NSError *error))failure
{
    NSString *url = [WTHTTPBaseUrl stringByAppendingPathComponent: WTRegisterUrl];
    
    [[NetworkTool shareInstance] requestWithMethod: HTTPMethodTypeGET url: url param: nil success:^(id responseObject) {
       
        NSString *codeUrl = [self getVerificationCodeUrlWithData: responseObject];
        if (codeUrl != nil)
        {
            if (success)
            {
                success([WTHTTPBaseUrl stringByAppendingPathComponent: codeUrl]);
                return;
            }
        }
        
        if (failure)
        {
            failure([[NSError alloc] initWithDomain: @"com.wutouqishi" code: -1011 userInfo: @{@"errorInfo" : @"获取验证码Url失败"}]);
        }
        
    } failure:^(NSError *error) {
        if (failure)
        {
            failure(error);
        }
    }];
}

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
- (void)registerWithUsername:(NSString *)username password:(NSString *)password email:(NSString *)email c:(NSString *)c success:(void (^)(BOOL isSuccess))success failure:(void(^)(NSError *error))failure
{
    // 1、拼接参数
    NSDictionary *param = @{
                            @"username" : username,
                            @"password" : password,
                            @"email" : email,
                            @"c" : c
                            };
    
    NSString *url = [WTHTTPBaseUrl stringByAppendingPathComponent: WTRegisterUrl];

    [[NetworkTool shareInstance] requestWithMethod: HTTPMethodTypePOST url: url param: param success:^(id responseObject) {
        
        NSString *html = [[NSString alloc] initWithData: responseObject encoding: NSUTF8StringEncoding];
        
        if ([html containsString: @"账户余额"]) // 注册成功
        {
            if (success)
            {
                success(YES);
            }
            return;
        }
        
        if (failure)
        {
            failure([[NSError alloc] initWithDomain: WTDomain code: -1011 userInfo: @{@"errorInfo" : @"未知错误"}]);
        }
        
    } failure:^(NSError *error) {
        WTLog(@"registerWithUrlString Error:%@", error)
        if (failure)
        {
            failure(error);
        }
    }];
}

#pragma mark - 根据二进制获取once的值
+ (NSString *)getOnceWithData:(NSData *)data
{
    TFHpple *doc = [[TFHpple alloc] initWithHTMLData: data];
    return [[doc peekAtSearchWithXPathQuery: @"//input[@name='once']"] objectForKey: @"value"];
}

#pragma mark - 根据二进制获取验证码url
- (NSString *)getVerificationCodeUrlWithData:(NSData *)data
{
    TFHpple *doc = [[TFHpple alloc] initWithHTMLData: data];
    
    NSArray<TFHppleElement *> *trE = [doc searchWithXPathQuery: @"//form[@action='/signup']//table//tr"];
    
    if (trE.count > 3)
    {
        NSArray *imgEs = [trE[3] searchWithXPathQuery: @"//img"];
        return imgEs.count > 0 ? [imgEs[0] objectForKey: @"src"] : nil;
    }
    
    return nil;
}
@end
