//
//  WTHTTPSessionManager.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/2/20.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTHTTPSessionManager.h"

@implementation WTHTTPSessionManager

+ (instancetype)manager
{
    WTHTTPSessionManager *manager = [super manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];
    
    // 以下步骤缺一不可，否则会导致登陆失败
    UIWebView *webView = [[UIWebView alloc]initWithFrame:CGRectZero];
    NSString *userAgentMobile = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    [manager.requestSerializer setValue: userAgentMobile forHTTPHeaderField: @"User-Agent"];
    
    return manager;
}

@end
