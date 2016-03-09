//
//  WTNotification.h
//  v2ex
//
//  Created by 无头骑士 GJ on 16/2/26.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WTUser.h"
#import "WTTopic.h"
@interface WTNotification : NSObject

/** 回复用户的模型 */
@property (nonatomic, strong) WTUser    *user;
/** 话题模型 */
@property (nonatomic, strong) WTTopic   *topic;
/** 回复内容*/
@property (nonatomic, strong) NSString  *replyContent;
/** 动作：收藏、回复 */
@property (nonatomic, strong) NSString  *action;
@end
