//
//  WTMemberViewModel.h
//  v2ex
//
//  Created by 无头骑士 GJ on 16/7/29.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WTMemberItem.h"
@interface WTMemberViewModel : NSObject

+ (void)getMemberInfo:(NSString *)username success:(void(^)(WTMemberItem *item))success failure:(void(^)(NSError *error))failure;

@end
