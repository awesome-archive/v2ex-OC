//
//  WTHttpTool.m
//  WTNews
//
//  Created by 无头骑士 GJ on 15/12/8.
//  Copyright © 2015年 耿杰. All rights reserved.
//

#import "WTHttpTool.h"
#import "WTHTTPSessionManager.h"
#import "WTURLConst.h"
@implementation WTHttpTool


/**
 *  GET请求
 *
 *  @param urlString  请求的url
 *  @param parameters 请求的参数
 *  @param success    请求成功的回调
 *  @param failure    请求失败的回调
 */
+ (void)GET:(NSString *)urlString parameters:(id)parameters success:(void(^)(id responseObject))success failure:(void(^)(NSError *error))failure
{
    // 创建请求管理者
    WTHTTPSessionManager *manager = [WTHTTPSessionManager manager];

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [manager GET: urlString parameters: parameters progress: nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        if (success)
        {
            success(responseObject);
        }
        
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if (failure)
        {
            failure(error);
        }
    
    }];
}

/**
 *  POST请求
 *
 *  @param urlString  请求的url
 *  @param parameters 请求的参数
 *  @param success    请求成功的回调
 *  @param failure    请求失败的回调
 */
+ (void)POST:(NSString *)urlString parameters:(id)parameters success:(void(^)(id responseObject))success failure:(void(^)(NSError *error))failure
{
    
    WTHTTPSessionManager *manager = [WTHTTPSessionManager manager];
    // 登陆必须要设置请求头的Referer信息
    if ([urlString containsString: WTLoginUrl])
    {
        [manager.requestSerializer setValue: urlString forHTTPHeaderField:@"Referer"];
    }
    else
    {
        [manager.requestSerializer setValue: urlString forHTTPHeaderField: @"Referer"];
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [manager POST: urlString parameters: parameters constructingBodyWithBlock: nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if (success)
        {
            success(responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if (failure)
        {
            failure(error);
        }
        
    }];
}

/**
 *  POST请求
 *
 *  @param urlString  地址
 *  @param parameters 参数
 *  @param success    请求成功的回调
 *  @param failure    请求失败的回调
 */
+ (void)POSTHTML:(NSString *)urlString parameters:(id)parameters success:(void(^)(id responseObject))success failure:(void(^)(NSError *error))failure
{
    
    // 0、设置请求头 以下步骤缺一不可，否则会导致登陆失败
    UIWebView *webView = [[UIWebView alloc]initWithFrame:CGRectZero];
    NSString *userAgentMobile = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    NSDictionary *headers = @{
                              @"Accept": @"text/html,application/xhtml+xml,application/xml",
                              @"Content-Type": @"application/x-www-form-urlencoded,multipart/form-data",
                              @"User-Agent": userAgentMobile,
                              @"Referer": urlString
                              };

    // 1、拼接请求参数
    NSMutableString *tempStr = [NSMutableString string];
    for (NSString *key in parameters)
    {
        [tempStr appendFormat: @"&%@=%@", key, parameters[key]];
    }
    NSString *dataStr = [tempStr substringFromIndex: 1];


    // 2、发起请求
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval: 10.0];
    request.HTTPMethod = @"POST";
    [request setAllHTTPHeaderFields: headers];
    [request setHTTPBody: [dataStr dataUsingEncoding: NSUTF8StringEncoding]];
    
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURLSessionTask *task = [session dataTaskWithRequest: request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            if (error)
            {
                failure(error);
                return;
            }
            if (success)
            {
                success(data);
            }
        });
        WTLog(@"thread:%@", [NSThread currentThread]);
    }];
    
    [task resume];
}

+ (void)GETHTML:(NSString *)urlString parameters:(id)parameters success:(void(^)(id responseObject))success failure:(void(^)(NSError *error))failure
{
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLRequest *request = [NSURLRequest requestWithURL: [NSURL URLWithString: urlString]];
    
    NSURLSessionTask *task = [session dataTaskWithRequest: request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error)
            {
                failure(error);
                return;
            }
            if (success)
            {
                success(data);
            }
        });
        WTLog(@"thread:%@", [NSThread currentThread]);
    }];
    
    [task resume];
}
@end
