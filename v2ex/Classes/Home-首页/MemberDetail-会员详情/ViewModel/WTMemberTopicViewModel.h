//
//  WTMemberTopicViewModel.h
//  v2ex
//
//  Created by gengjie on 16/8/24.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WTTopic.h"
@interface WTMemberTopicViewModel : NSObject

@property (nonatomic, strong) NSMutableArray<WTTopic *> *topics;

@property (nonatomic, assign, getter=isNextPage)BOOL nextPage;

@property (nonatomic, assign) NSUInteger page;

/** 是否有权限 */
@property (nonatomic, assign, getter=isPermissions) BOOL permissions;

/**
 *  根据用户名获取发表的主题
 *
 *  @param username 用户名
 *  @param iconURL  头像URL
 *  @param success  请求成功的回调
 *  @param failure  请求失败的回调
 */
- (void)getMemberTopicsWithUsername:(NSString *)username iconURL:(NSURL *)iconURL success:(void(^)())success failure:(void(^)(NSError *error))failure;
@end
