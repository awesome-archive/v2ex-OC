//
//  NetworkTool.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/3/3.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "NetworkTool.h"
#import "WTURLConst.h"
#import "WTExtension.h"
#import "WTHttpTool.h"
@implementation NetworkTool

static NetworkTool *_instance;

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[NetworkTool alloc] init];
        
        // 1、设置请求头
        UIWebView *webView = [[UIWebView alloc]initWithFrame:CGRectZero];
        NSString *userAgentMobile = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
        [_instance.requestSerializer setValue: userAgentMobile forHTTPHeaderField: @"User-Agent"];
        
        _instance.responseSerializer = [AFHTTPResponseSerializer serializer];
    });
    _instance.responseSerializer.acceptableContentTypes =  [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/plain", @"image/png",nil];
    return _instance;
}

/**
 *  获取html源码
 *
 *  @param urlString url
 *  @param success   请求成功的回调
 *  @param failure   请求失败的回调
 */
- (void)getHtmlCodeWithUrlString:(NSString *)urlString success:(void (^)(NSData *data))success failure:(void(^)(NSError *error))failure;
{
    [_instance GET: urlString parameters: nil progress: nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (success)
        {
            success(responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (failure)
        {
            failure(error);
        }
        
    }];
}
/**
 *  获取html源码
 *
 *  @param urlString url
 *  @param success   请求成功的回调
 *  @param failure   请求失败的回调
 */
- (void)postHtmlCodeWithUrlString:(NSString *)urlString success:(void (^)(NSData *data))success failure:(void(^)(NSError *error))failure
{
    [_instance POST: urlString parameters: nil progress: nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (success)
        {
            success(responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (failure)
        {
            failure(error);
        }
        
    }];
}

/**
 *  发起请求
 *
 *  @param method  请求方法
 *  @param url     url地址
 *  @param param   参数
 *  @param success 请求成功的回调
 *  @param failure 请求失败的回调
 */
- (void)requestWithMethod:(HTTPMethodType)method url:(NSString *)url param:(NSDictionary *)param success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{

    // 1、成功的回调
    void (^successBlock)(id responseObject) = ^(id responseObject){
        success(responseObject);
    };
    
    // 2、失败的回调
    void (^failureBlock)(NSError *error) = ^(NSError *error){
        failure(error);
    };
    
    [_instance.requestSerializer setValue: url forHTTPHeaderField: @"Referer"];
    
    // 3、发起请求
    if (method == HTTPMethodTypeGET)            // GET请求
    {
        [_instance GET: url parameters: param progress: nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
           
            successBlock(responseObject);
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            failureBlock(error);
        }];
    }
    else if(method == HTTPMethodTypePOST)       // POST请求
    {
        [_instance POST: url parameters: param progress: nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            successBlock(responseObject);
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            failureBlock(error);
        }];
    }
    
}

/**
 *  上传单张图片
 *
 *  @param urlString url地址
 *  @param image     图片对象
 *  @param progress  进度条的回调
 *  @param success   请求成功的回调
 *  @param failure   请求失败的回调
 */
- (void)uploadImageWithUrlString:(NSString *)urlString image:(UIImage *)image progress:(void (^)(NSProgress *uploadProgress))progress success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    // 1、成功的回调
    void (^successBlock)(id responseObject) = ^(id responseObject){
        success(responseObject);
    };
    
    // 2、失败的回调
    void (^failureBlock)(NSError *error) = ^(NSError *error){
        failure(error);
    };
    
    // 3、上传进度的回调
    void (^progressBlock)(NSProgress *uploadProgress) = ^(NSProgress *uploadProgress){
        progress(uploadProgress);
    };
    
    _instance.responseSerializer = [AFJSONResponseSerializer serializer];
    _instance.responseSerializer.acceptableContentTypes =  [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/plain", @"image/png",nil];
    
    // 5、发起请求
    [_instance POST: urlString parameters: nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        NSData *data = UIImageJPEGRepresentation(image,0.5);
        [formData appendPartWithFileData: data name: @"file" fileName: @"photo.png" mimeType: @"image/png"];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        progressBlock(uploadProgress);
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        successBlock(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        failureBlock(error);
        
    }];
}

/**
 *  回复别人的帖子
 *
 *  @param urlString url地址
 *  @param once      回复帖子必须属性
 *  @param content   回复的正文内容
 *  @param success   请求成功的回调
 *  @param failure   请求失败的回调
 */
- (void)replyTopicWithUrlString:(NSString *)urlString once:(NSString *)once content:(NSString *)content success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    // 1、拼接参数
    NSDictionary *param = @{@"once" : once, @"content" : content};
    
    _instance.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    // 2、发起请求
    [_instance requestWithMethod: HTTPMethodTypePOST url: urlString param: param success:^(id responseObject) {
        WTLog(@"responseObject:%@", [[NSString alloc] initWithData: responseObject encoding: NSUTF8StringEncoding])
        if (success)
        {
            success(responseObject);
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
- (void)registerWithUsername:(NSString *)username password:(NSString *)password email:(NSString *)email c:(NSString *)c success:(void (^)(BOOL isSuccess))success failure:(void(^)(NSError *error))failure;
{
    // 1、拼接参数
    NSDictionary *param = @{
                           @"username" : username,
                           @"password" : password,
                           @"email" : email,
                           @"c" : c
                           };
    
    // 2、发起请求
    [_instance requestWithMethod: HTTPMethodTypePOST url: @"http://www.v2ex.com/signup" param: param success:^(id responseObject) {
        
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

/**
 *  获取验证码的URL
 *
 *  @param success 请求成功的回调
 *  @param failure 请求失败的回调
 */
- (void)getVerificationCodeUrlWithSuccess:(void (^)(NSString *codeUrl))success failure:(void (^)(NSError *error))failure
{
    // 1、请求参数
    NSString *url = [WTHTTPBaseUrl stringByAppendingPathComponent: WTRegisterUrl];
    
    // 2、发起请求
    [_instance requestWithMethod: HTTPMethodTypeGET url: url param: nil success:^(id responseObject) {
        
        NSString *codeUrl = [WTExtension getCodeUrlWithData: responseObject];
        
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
    
//    [WTHttpTool GETHTML: url parameters: nil success:^(id responseObject) {
//        NSString *codeUrl = [WTExtension getCodeUrlWithData: responseObject];
//        
//        if (codeUrl != nil)
//        {
//            if (success)
//            {
//                success([WTHTTPBaseUrl stringByAppendingPathComponent: codeUrl]);
//                return;
//            }
//        }
//        
//        if (failure)
//        {
//            failure([[NSError alloc] initWithDomain: @"com.wutouqishi" code: -1011 userInfo: @{@"errorInfo" : @"获取验证码Url失败"}]);
//        }
//    } failure:^(NSError *error) {
//        if (failure)
//        {
//            failure(error);
//        }
//    }];
}

/**
 *  根据url获取二进制数据
 *
 *  @param urlString url
 *  @param success   请求成功的回调
 *  @param failure   请求失败的回调
 */
- (void)getDataWithUrl:(NSString *)urlString success:(void(^)(NSData *data))success failure:(void(^)(NSError *error))failure
{
    [_instance requestWithMethod: HTTPMethodTypeGET url: urlString param: nil success:^(id responseObject) {
        
        if (success)
        {
            success(responseObject);
        }
        
    } failure:^(NSError *error) {
        
        if (failure)
        {
            failure(error);
        }
        
    }];
}

@end
