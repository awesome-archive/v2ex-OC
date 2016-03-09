//
//  WTExtension.h
//  v2ex
//
//  Created by 无头骑士 GJ on 16/2/26.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WTTopic, HTMLNode;
@interface WTExtension : NSObject
/**
 *  判断是否有下一页
 *
 *  @param htmlNode body的HTMLNode
 *
 *  @return WTTopic
 */
+ (WTTopic *)getIsNextPageWithData:(HTMLNode *)htmlNode;

/**
 *  根据二进制获取话题数据
 *
 *  @param data 二进制
 *
 *  @return 话题数组
 */
+ (NSMutableArray<WTTopic *> *)getMeAllTopicsWithData:(NSData *)data;

/**
 *  根据二进制获取回复别人的话题数组
 *
 *  @param data 二进制
 *
 *  @return 话题数组
 */
+ (NSMutableArray<WTTopic *> *)getReplyTopicsWithData:(NSData *)data;

/**
 *  获取用户的once的值
 *
 *  @param html html源码
 */
+ (NSString *)getOnceWithHtml:(NSString *)html;

/**
 *  获取验证码的Url
 *
 *  @param html html源码
 *
 */
+ (NSString *)getCodeUrlWithData:(NSData *)data;
@end
