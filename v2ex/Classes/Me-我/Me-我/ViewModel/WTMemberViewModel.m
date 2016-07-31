//
//  WTMemberViewModel.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/7/29.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTMemberViewModel.h"
#import "NetworkTool.h"
@implementation WTMemberViewModel

+ (void)getMemberInfo:(NSString *)username success:(void(^)(WTMemberItem *item))success failure:(void(^)(NSError *error))failure
{
    NSString *url = [NSString stringWithFormat: @"http://www.v2ex.com/member/%@", username];
    
    [[NetworkTool shareInstance] GETWithUrlString: url success:^(id data) {
        
    } failure:^(NSError *error) {
        
    }];
}

+ (void)parseMemberInfoWithData:(NSData *)data
{
    
}

@end
