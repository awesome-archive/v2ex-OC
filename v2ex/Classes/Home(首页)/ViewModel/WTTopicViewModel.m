//
//  WTTopicViewModel.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/3/12.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTTopicViewModel.h"
#import "TFHpple.h"
#import "WTURLConst.h"
#import "NSString+YYAdd.h"
#import "WTParseTool.h"
@implementation WTTopicViewModel

#pragma mark - 根据data解析出节点话题数组
+ (NSMutableArray *)nodeTopicsWithData:(NSData *)data
{
    NSMutableArray *topics = [NSMutableArray array];
    
    TFHpple *doc = [[TFHpple alloc] initWithHTMLData: data];
    NSArray *cellItemArray = [doc searchWithXPathQuery: @"//div[@class='cell item']"];
    for (TFHppleElement *cellItem in cellItemArray)
    {
        @autoreleasepool
        {
            // 1、匹配相对应的节点
            TFHppleElement *nodeElement = [cellItem searchWithXPathQuery: @"//a[@class='node']"][0];
            TFHppleElement *titleElement = [cellItem searchWithXPathQuery: @"//span[@class='item_title']//a"][0];
            TFHppleElement *authorElement = [cellItem searchWithXPathQuery: @"//strong"][0];
            NSArray<TFHppleElement *> *commentArray = [cellItem searchWithXPathQuery: @"//a[@class='count_livid']"];
            NSArray<TFHppleElement *> *smallFadeArray = [cellItem searchWithXPathQuery: @"//span[@class='small fade']"];
            NSArray<TFHppleElement *> *avatars = [cellItem searchWithXPathQuery: @"//img[@class='avatar']"];
            
            WTTopicViewModel *topicViewModel = [WTTopicViewModel new];
            {
                WTTopicNew *topic = [WTTopicNew new];

                // 1、节点
                topic.node = nodeElement.content;
                
                // 2、标题
                topic.title = titleElement.content;
                
                // 3、话题详情URL
                topic.detailUrl = [titleElement objectForKey: @"href"];
                
                // 4、作者
                topic.author = authorElement.content;
                
                // 5、评论数
                if (commentArray.count > 0)
                {
                    topic.commentCount = commentArray.firstObject.content;
                }
                
                // 6、最后回复时间
                if (smallFadeArray.count > 1)        // 首页话题列表
                {
                    topic.lastReplyTime = [[smallFadeArray[1].content componentsSeparatedByString: @"•"].firstObject stringByReplacingOccurrencesOfString: @" " withString: @""];
                }
                else                                // 用户收藏话题列表
                {
                    NSString *content = smallFadeArray[0].content;
                    NSArray *contents = [content componentsSeparatedByString: @"•"];
                    if (contents.count > 2)
                    {
                        NSString *lastReplyTime = contents[2];
                        topic.lastReplyTime = [lastReplyTime stringByTrim];
                    }
                    
                }
                
                // 7、头像
                if (avatars.count > 0)
                {
                    topic.icon = [avatars.firstObject objectForKey: @"src"];
                }
                
                topicViewModel.topic = topic;
                
                
                // 1、http://www.v2ex.com + /member/hunau 拼接成完整的地址
                topicViewModel.topicDetailUrl = [WTHTTPBaseUrl stringByAppendingPathComponent: topic.detailUrl];
                
                // 2、头像 (由于v2ex抓下来的都不是清晰的头像，替换字符串转换成相对清晰的URL)
                if (topic.icon)
                {
                    NSString *iconStr = topic.icon;
                    if ([topic.icon containsString: @"normal.png"])
                    {
                        iconStr = [topic.icon stringByReplacingOccurrencesOfString: @"normal.png" withString: @"large.png"];
                    }
                    else if([topic.icon containsString: @"s=48"])
                    {
                        iconStr = [topic.icon stringByReplacingOccurrencesOfString: @"s=48" withString: @"s=96"];
                    }
                    topicViewModel.iconURL = [NSURL URLWithString: [WTHTTP stringByAppendingString: iconStr]];
                }
            }
            
            [topics addObject: topicViewModel];
        }
    }
    return topics;
}

#pragma makr - 根据data解析出用户通知
+ (NSMutableArray<WTTopicViewModel *> *)userNotificationsWithData:(NSData *)data;
{
    NSMutableArray *notificationVMs = [NSMutableArray array];
    
    TFHpple *doc = [[TFHpple alloc] initWithHTMLData: data];
    
    NSArray<TFHppleElement *> *cellEs = [doc searchWithXPathQuery: @"//div[@class='cell']"];
    
    for (TFHppleElement *cellE in cellEs)
    {
        @autoreleasepool {
            
            NSArray<TFHppleElement *> *avatarEs = [cellE searchWithXPathQuery: @"//img[@class='avatar']"];
            
            NSArray<TFHppleElement *> *aEs = [cellE searchWithXPathQuery: @"//a"];
            
            NSArray<TFHppleElement *> *snowEs = [cellE searchWithXPathQuery: @"//span[@class='snow']"];
            
            NSArray<TFHppleElement *> *payloadEs = [cellE searchWithXPathQuery: @"//div[@class='payload']"];
            
            
            
            WTTopicViewModel *topicViewModel = [WTTopicViewModel new];
            {
                WTTopicNew *topic = [WTTopicNew new];
                
                // 1、头像
                topic.icon = [avatarEs.firstObject objectForKey: @"src"];
                // 2、作者
                topic.author = aEs[1].content;
                // 3、标题
                if (aEs.count > 2)
                {
                    topic.title = aEs[2].content;
                    topic.detailUrl = [aEs[2] objectForKey: @"href"];
                    topicViewModel.topicDetailUrl = [WTHTTPBaseUrl stringByAppendingString: topic.detailUrl];
                }
                // 4、最后回复时间
                topic.lastReplyTime = snowEs.firstObject.content;
                // 5、回复内容
                topic.content = payloadEs.firstObject.content;
                
                
                topicViewModel.topic = topic;
                
                // 1、头像 (由于v2ex抓下来的都不是清晰的头像，替换字符串转换成相对清晰的URL)
                topicViewModel.iconURL = [WTParseTool parseBigImageUrlWithSmallImageUrl: topic.icon];
                
            }
            
            [notificationVMs addObject: topicViewModel];
        }
    }
    return notificationVMs;
}

#pragma mark - 根据data解析出用户回复的话题
+ (NSMutableArray<WTTopicViewModel *> *)userReplyTopicsWithData:(NSData *)data
{
    NSMutableArray *topicVMs = [NSMutableArray array];
    
    TFHpple *doc = [[TFHpple alloc] initWithHTMLData: data];
    
    NSArray<TFHppleElement *> *dockAreaEs = [doc searchWithXPathQuery: @"//div[@class='dock_area']"];
    NSArray<TFHppleElement *> *innerEs = [doc searchWithXPathQuery: @"//div[@class='inner']"];
    
    
    for (NSUInteger i = 0; i < dockAreaEs.count; i++)
    {
        @autoreleasepool {
            
            TFHppleElement *dockAreaE = dockAreaEs[i];
            TFHppleElement *innerE = innerEs[i];
            
            TFHppleElement *grayE = [dockAreaE searchWithXPathQuery: @"//span[@class='gray']"].firstObject;
            TFHppleElement *fadeE = [dockAreaE searchWithXPathQuery: @"//span[@class='fade']"].firstObject;
            
            TFHppleElement *grayaE = [grayE searchWithXPathQuery: @"//a"].firstObject;
            
            WTTopicViewModel *topicViewModel = [WTTopicViewModel new];
            {
                WTTopicNew *topic = [WTTopicNew new];
                
                NSString *grayContent = grayE.content;
                NSString *grayAContent = grayaE.content;
                
                // 标题
                topic.title = grayAContent;
                
                // 回复内容
                topic.content = [innerE.content stringByTrim];
                
                // 最后回复时间
                topic.lastReplyTime = [fadeE.content stringByTrim];
                
                // 作者
                NSString *grayContents = [grayContent stringByReplacingOccurrencesOfString: grayAContent withString: @""];
                topic.author = [grayContents componentsSeparatedByString: @" "][1];
                
                topicViewModel.topic = topic;
            }
            [topicVMs addObject: topicViewModel];
        }
    }
    
    return topicVMs;
}

#pragma mark - 是否是 `最近`节点
+ (BOOL)isNeedNextPage:(NSString *)urlSuffix
{
    if ([urlSuffix containsString: @"recent"] || [urlSuffix containsString: @"my"])
        return true;
    return false;
}

@end
