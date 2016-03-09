//
//  WTBlog.h
//  v2ex
//
//  Created by 无头骑士 GJ on 16/1/14.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTBaseTopic.h"

@interface WTTopic : WTBaseTopic

/** 最后评论人 */
@property (nonatomic, strong) NSString                     *lastCommentsPeople;
/** 详情链接 */
@property (nonatomic, strong) NSString                     *detailUrl;
/** 回复数量 */
@property (nonatomic, assign) NSInteger                    replyCount;
/** 最后回复时间 */
@property (nonatomic, strong) NSString                     *lastReplyTime;

// 额外属性
/** 是否有下一页 */
@property (nonatomic, assign, getter=isHasNextPage)BOOL    hasNextPage;
/**
 *  是否是 `最近`节点
 *
 *  @param urlSuffix url后缀
 *
 *  @return YES 是 NO 否
 */
+ (BOOL)isNewestNodeWithUrlSuffix:(NSString *)urlSuffix;

/**
 *  根据二进制流 返回一个博客数组
 *
 *  @param data 二进制
 *
 *  @return 博客数据
 */
+ (NSArray *)topicWithData:(NSData *)data;

/**
 *  解析节点内的博客数据
 *
 *  @param data 进制
 *
 *  @return 博客数据
 */
+ (NSArray *)TopicsNodeBlogWithData:(NSData *)data;
@end
