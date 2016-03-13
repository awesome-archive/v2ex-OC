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
@implementation WTTopicViewModel

#pragma mark - 根据data解析出话题数组
+ (NSMutableArray *)topicsWithData:(NSData *)data
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
            TFHppleElement *timeElement = [cellItem searchWithXPathQuery: @"//span[@class='small fade']"][1];
            TFHppleElement *icon = [cellItem searchWithXPathQuery: @"//img[@class='avatar']"][0];
            
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
                topic.lastReplyTime = [[timeElement.content componentsSeparatedByString: @"•"].firstObject stringByReplacingOccurrencesOfString: @" " withString: @""];
                
                // 7、头像
                topic.icon = [icon objectForKey: @"src"];
                
                topicViewModel.topic = topic;
                
                
                // 1、http://www.v2ex.com + /member/hunau 拼接成完整的地址
                topicViewModel.topicDetailUrl = [WTHTTPBaseUrl stringByAppendingPathComponent: topic.detailUrl];
                
                // 2、头像 (由于v2ex抓下来的都不是清晰的头像，替换字符串转换成相对清晰的URL)
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
            
            [topics addObject: topicViewModel];
        }
    }
    return topics;
}

#pragma mark - 是否是 `最近`节点
+ (BOOL)isNeedNextPage:(NSString *)urlSuffix
{
    if ([urlSuffix containsString: @"recent"] || [urlSuffix containsString: @"my"])
        return true;
    return false;
}

@end
