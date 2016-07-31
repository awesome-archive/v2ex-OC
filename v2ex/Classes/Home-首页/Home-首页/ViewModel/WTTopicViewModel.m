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
    return [self nodeTopicsWithData: data iconURL: nil];
}

#pragma mark - 根据data解析出节点话题数组
+ (NSMutableArray *)nodeTopicsWithData:(NSData *)data iconURL:(NSURL *)iconURL
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
            NSArray<TFHppleElement *> *countOrangeArray = [cellItem searchWithXPathQuery: @"//a[@class='count_orange']"];
            NSArray<TFHppleElement *> *avatars = [cellItem searchWithXPathQuery: @"//img[@class='avatar']"];
            
            WTTopicViewModel *topicViewModel = [WTTopicViewModel new];
            {
                WTTopic *topic = [WTTopic new];

                // 1、节点
                topic.node = nodeElement.content;
                
                // 2、标题
                topic.title = titleElement.content;
                
                // 3、话题详情URL
                topic.detailUrl = [titleElement objectForKey: @"href"];
                
                // 4、作者
                topic.author = authorElement.content;
                
                // 5、评论数
                if (commentArray.count > 0)    // 首页话题控制器的评论数
                {
                    topic.commentCount = commentArray.firstObject.content;
                }
                else        // 用户话题控制器的评论数
                {
                    topic.commentCount = countOrangeArray.firstObject.content;
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
                else if(iconURL)
                {
                    topicViewModel.iconURL = iconURL;
                }
            }
            
            [topics addObject: topicViewModel];
        }
    }
    return topics;
}

/**
 *  根据data解析出热点话题数据
 *
 *  @param data data
 *
 *  @return 热点话题数组
 */
+ (NSMutableArray *)hotNodeTopicsWithData:(NSData *)data
{
    NSMutableArray *topics = [NSMutableArray array];
    
    TFHpple *doc = [[TFHpple alloc] initWithHTMLData: data];
    NSArray *cellItemArray = [doc searchWithXPathQuery: @"//div[@class='cell']"];
    
    for (TFHppleElement *cellItem in cellItemArray)
    {
        @autoreleasepool
        {
            // 1、匹配相对应的节点
//            TFHppleElement *nodeElement = [cellItem searchWithXPathQuery: @"//a[@class='node']"][0];
            TFHppleElement *titleElement = [cellItem searchWithXPathQuery: @"//span[@class='item_title']//a"][0];
            TFHppleElement *authorElement = [cellItem searchWithXPathQuery: @"//strong"][0];
            NSArray<TFHppleElement *> *commentArray = [cellItem searchWithXPathQuery: @"//a[@class='count_livid']"];
            NSArray<TFHppleElement *> *smallFadeArray = [cellItem searchWithXPathQuery: @"//span[@class='small fade']"];
            NSArray<TFHppleElement *> *countOrangeArray = [cellItem searchWithXPathQuery: @"//a[@class='count_orange']"];
            NSArray<TFHppleElement *> *avatars = [cellItem searchWithXPathQuery: @"//img[@class='avatar']"];
            
            WTTopicViewModel *topicViewModel = [WTTopicViewModel new];
            {
                WTTopic *topic = [WTTopic new];
                
                // 1、节点
//                topic.node = nodeElement.content;
                
                // 2、标题
                topic.title = titleElement.content;
                
                // 3、话题详情URL
                topic.detailUrl = [titleElement objectForKey: @"href"];
                
                // 4、作者
                topic.author = authorElement.content;
                
                // 5、评论数
                if (commentArray.count > 0)    // 首页话题控制器的评论数
                {
                    topic.commentCount = commentArray.firstObject.content;
                }
                else        // 用户话题控制器的评论数
                {
                    topic.commentCount = countOrangeArray.firstObject.content;
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
                WTTopic *topic = [WTTopic new];
                
                NSString *grayContent = grayE.content;
                NSString *grayAContent = grayaE.content;
                
                // 标题
                topic.title = grayAContent;
                
                // 话题详情
                topic.detailUrl = grayaE[@"href"];
                
                // 回复内容
                topic.content = [innerE.content stringByTrim];
                
                // 最后回复时间
                topic.lastReplyTime = [fadeE.content stringByTrim];
                
                // 作者
                NSString *grayContents = [grayContent stringByReplacingOccurrencesOfString: grayAContent withString: @""];
                topic.author = [grayContents componentsSeparatedByString: @" "][1];
                
                topicViewModel.topic = topic;
                
                // 1、话题详情Url
                if (topic.detailUrl)
                {
                    topicViewModel.topicDetailUrl = [WTHTTPBaseUrl stringByAppendingPathComponent: topic.detailUrl];
                }
            }
            [topicVMs addObject: topicViewModel];
        }
    }
    
    return topicVMs;
}

#pragma mark - 是否是下一页
+ (BOOL)isNeedNextPage:(NSString *)urlSuffix
{
    if ([urlSuffix containsString: @"recent"] || [urlSuffix containsString: @"my"] || [urlSuffix containsString: @"member"])
        return true;
    return false;
}

#pragma mark - 创建nodes.plist文件
+ (void)createNodesPlist
{
    NSDictionary *dict_0 = @{@"name" : @"最近", @"nodeURL" : @"/recent"};
    NSDictionary *dict0 = @{@"name" : @"技术", @"nodeURL" : @"/?tab=tech"};
    NSDictionary *dict1 = @{@"name" : @"创意", @"nodeURL" : @"/?tab=creative"};
    NSDictionary *dict2 = @{@"name" : @"好玩", @"nodeURL" : @"/?tab=play"};
    NSDictionary *dict3 = @{@"name" : @"Apple", @"nodeURL" : @"/?tab=apple"};
    NSDictionary *dict4 = @{@"name" : @"酷工作", @"nodeURL" : @"/?tab=jobs"};
    NSDictionary *dict5 = @{@"name" : @"交易", @"nodeURL" : @"/?tab=deals"};
    NSDictionary *dict6 = @{@"name" : @"城市", @"nodeURL" : @"/?tab=city"};
    NSDictionary *dict7 = @{@"name" : @"问与答", @"nodeURL" : @"/?tab=qna"};
    NSDictionary *dict8 = @{@"name" : @"最热", @"nodeURL" : @"/?tab=hot"};
    NSDictionary *dict9 = @{@"name" : @"全部", @"nodeURL" : @"/?tab=all"};
    NSDictionary *dict10 = @{@"name" : @"R2", @"nodeURL" : @"/?tab=r2"};
    NSArray *array = @[dict_0,dict0, dict1,dict2, dict3, dict4, dict5, dict6, dict7, dict8, dict9, dict10];
    BOOL flag = [array writeToFile: @"/Users/wutouqishigj/Desktop/nodes.plist" atomically: YES];
    if (flag)
    {
        WTLog(@"成功");
    }
    else
    {
        WTLog(@"失败");
    }
}

@end
