//
//  WTHTMLExtension.h
//  v2ex
//
//  Created by 无头骑士 GJ on 16/2/26.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TFHpple;
@interface WTHTMLExtension : NSObject
/**
 *  判断是否有下一页
 *
 *  @param htmlNode body的HTMLNode
 *
 *  @return WTTopic
 */
//+ (WTTopic *)getIsNextPageWithData:(HTMLNode *)htmlNode;

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


/**
 *  是否有下一页
 *
 *  @param doc TFHpple
 *
 *  @return YES 有 NO 没有
 */
+ (BOOL)isNextPage:(TFHpple *)doc;


@end
