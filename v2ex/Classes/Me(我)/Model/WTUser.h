//
//  WTUser.h
//  v2ex
//
//  Created by 无头骑士 GJ on 16/2/24.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WTUser : NSObject
/** 用户名 */
@property (nonatomic, strong) NSString                                *username;
/** 今日活跃排名  */
@property (nonatomic, strong) NSString                                *activeRank;
/** 加入时间 */
@property (nonatomic, strong) NSString                                *joinTime;
/** 头像 */
@property (nonatomic, strong) NSString                                *icon;
/** 加入排名 */
@property (nonatomic, strong) NSString                                *joinRank;
/** 详情链接 */
@property (nonatomic, strong) NSString                                *detailUrl;

@property (nonatomic, assign, getter = isLoginUser) BOOL              loginUser;
/** 个人签名 */
@property (nonatomic, strong) NSString                                *signature;
/** 是否在线 */
@property (nonatomic, assign, getter=isOnline) BOOL                   online;
@end
