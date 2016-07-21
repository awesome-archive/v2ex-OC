//
//  WTUserViewModel.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/3/18.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTUserViewModel.h"
#import "WTURLConst.h"
#import "WTParseTool.h"
#import "NetworkTool.h"
#import "TFHpple.h"
#import "WTUser.h"
@implementation WTUserViewModel

#pragma mark - 加载用户信息
+ (void)loadUserInfoWithUsername:(NSString *)username success:(void (^)(WTUserViewModel *userViewModel))success failure:(void (^)(NSError *error))failure
{
    NSString *urlString = [WTUserInfoUrl stringByAppendingPathComponent: username];
    
    [[NetworkTool shareInstance] getHtmlCodeWithUrlString: urlString success:^(NSData *data) {
        
        //NSString *html = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
        
        WTUserViewModel *userViewModel = [self getUserInfoWithData: data];
        
        if(success)
        {
            success(userViewModel);
        }
        
    } failure:^(NSError *error) {
        
        if (failure)
        {
            failure(error);
        }
        
    }];
}

/**
 *  根据二进制加载用户信息
 *
 *  @param data 二进制
 *
 *  @return WTUserViewModel用户信息
 */
+ (WTUserViewModel *)getUserInfoWithData:(NSData *)data
{
    TFHpple *doc = [[TFHpple alloc] initWithHTMLData: data];
    
    TFHppleElement *innerE = [doc peekAtSearchWithXPathQuery: @"//div[@class='inner']"];
    // 头像
    NSArray<TFHppleElement *> *avatarEs = [innerE searchWithXPathQuery: @"//img[@class='avatar']"];
    // 个性签名
    NSArray<TFHppleElement *> *signatureEs = [innerE searchWithXPathQuery: @"//span[@class='bigger']"];
    // 是否在线
    NSArray<TFHppleElement *> *onlineEs = [innerE searchWithXPathQuery: @"//strong[@class='online']"];
    
    // 用户模型
    WTUserViewModel *userViewModel = [WTUserViewModel new];
    {
        WTUser *user = [WTUser new];
        
        if (avatarEs.count > 0)
        {
            user.icon = avatarEs[0][@"src"];
            userViewModel.iconURL = [WTParseTool parseBigImageUrlWithSmallImageUrl: user.icon isNormalPic: YES];
        }
        
        user.signature = signatureEs.count > 0 ? signatureEs[0].content : nil;
        
        user.online = onlineEs.count > 0 ? YES : NO;
        
        userViewModel.user = user;
    }
    
    return userViewModel;
}

@end
