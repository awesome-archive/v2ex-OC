//
//  WTUserViewModel.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/3/18.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTUserViewModel.h"
#import "WTURLConst.h"
#import "NetworkTool.h"
#import "TFHpple.h"
@implementation WTUserViewModel
/**
 *  加载用户信息
 *
 *  @param username 用户名
 *  @param success  请求成功的回调
 *  @param failure  请求失败的回调
 */
+ (void)loadUserInfoWithUsername:(NSString *)username success:(void (^)(WTUser *user))success failure:(void (^)(NSError *error))failure
{
    NSString *urlString = [WTUserInfoUrl stringByAppendingPathComponent: username];
    
    [[NetworkTool shareInstance] getHtmlCodeWithUrlString: urlString success:^(NSData *data) {
        
        NSString *html = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
        
        WTUser *user = [self getUserInfoWithData: data];
        
        if(success)
        {
            success(user);
        }
        
    } failure:^(NSError *error) {
        
        if (failure)
        {
            failure(error);
        }
        
    }];
}

+ (WTUser *)getUserInfoWithData:(NSData *)data
{
    TFHpple *doc = [[TFHpple alloc] initWithHTMLData: data];
    
    
    return nil;
}

@end
