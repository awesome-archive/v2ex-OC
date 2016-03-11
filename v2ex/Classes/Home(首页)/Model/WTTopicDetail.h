//
//  WTBlogDetail.h
//  v2ex
//
//  Created by 无头骑士 GJ on 16/1/18.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTBaseTopic.h"
#import "HTMLNode.h"
@interface WTTopicDetail : WTBaseTopic

/** 楼层 */
@property (nonatomic, assign) NSUInteger                floor;
/** 博客被查看次数 */
@property (nonatomic, assign) NSUInteger                seeCount;
/** 未解析的正文内容 */
@property (nonatomic, strong) NSString                  *normalContent;

// 额外属性
/** 是否已经加入收藏 */
@property (nonatomic, assign, getter=isCollection) BOOL collection;
/** 加入收藏或取消url地址 */
@property (nonatomic, strong) NSString                  *collectionUrl;
/** 是否已经喜欢*/
@property (nonatomic, assign, getter=isLove) BOOL       love;
/** 感谢地址 */
@property (nonatomic, strong) NSString                  *loveUrl;
/** markdown文本 */
@property (nonatomic, strong) NSString                  *markdownStr;
/** 发表回复需要的字段 */
@property (nonatomic, strong) NSString                  *once;
/** 是否需要登陆 */
@property (nonatomic, assign, getter=iSNeedLogin)BOOL   needLogin;

/**
 *  根据二进制流解析作者话题详情
 *
 *  @param data 二进制
 *
 *  @return WTTopicDetail
 */
+ (WTTopicDetail *)authorTopicDetailWithData:(NSData *)data;

/**
 *  根据二进制流解析topicDetail
 *
 *  @param data 二进制
 *
 *  @return WTTopicDetail
 */
+ (NSArray *)topicDetailWithData:(NSData *)data;

@end
