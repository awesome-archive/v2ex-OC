//
//  WTURLConst.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/1/14.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTURLConst.h"

/** 协议头 */
NSString * const WTHTTP = @"https:";

/** base URL */
NSString * const WTHTTPBaseUrl = @"https://www.v2ex.com";

/** 最新节点的URL */
NSString * const WTNewestUrl = @"/recent";

/** 登陆的URL */
NSString * const WTLoginUrl = @"/signin";

/** 全部节点的URL */
NSString * const WTAllNodeUrl = @"https://www.v2ex.com/api/nodes/all.json";

/** 收藏话题URL */
NSString * const WTCollectionTopicUrl = @"https://www.v2ex.com/my/topics";



/** 消息URL*/
NSString * const WTNotificationUrl = @"https://www.v2ex.com/notifications";

/** 自己的全部主题 */
NSString * const WTMeTopicUrl = @"https://www.v2ex.com/member/misaka14/topics";

/** 回复别人的话题 */
NSString * const WTReplyTopicUrl = @"https://www.v2ex.com/member/misaka14/replies?p=1";

/** 领取今日奖励 */
NSString * const WTReceiveAwardsUrl = @"https://www.v2ex.com/mission/daily/redeem?once=";
/** 用户信息URL */
NSString * const WTUserInfoUrl = @"https://www.v2ex.com/member";
/** 上传图片 */
NSString * const WTUploadPictureUrl = @"https://pic.xiaojianjian.net/webtools/picbed/upload.htm";

/** 注册 */
NSString * const WTRegisterUrl = @"signup";

/** domain*/
NSString * const WTDomain = @"com.miaska14.com";

/** www.misaka14.com服务器 */
NSString * const WTMisaka14Domain = @"http://172.16.1.45:8080/v2ex";
