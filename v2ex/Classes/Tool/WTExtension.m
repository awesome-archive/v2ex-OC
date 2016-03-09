//
//  WTExtension.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/2/26.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTExtension.h"
#import "WTTopic.h"
#import "HTMLParser.h"
#import "HTMLNode.h"
#import "WTURLConst.h"

@implementation WTExtension

/**
 *  判断是否有下一页
 *
 *  @param htmlNode body的HTMLNode
 *
 *  @return WTTopic
 */
+ (WTTopic *)getIsNextPageWithData:(HTMLNode *)htmlNode
{
    HTMLNode *buttonNode = [htmlNode findChildOfClass: @"super normal button"];
    
    NSString *buttonValue = [buttonNode getAttributeNamed: @"value"];
    
    WTTopic *topic = [WTTopic new];
    
    {
        topic.hasNextPage = [buttonValue containsString: @"下一页"];
    }
    return topic;
}

/**
 *  根据二进制获取话题数据
 *
 *  @param data 二进制
 *
 *  @return 话题数组
 */
+ (NSMutableArray<WTTopic *> *)getMeAllTopicsWithData:(NSData *)data;
{
    HTMLParser *parser = [[HTMLParser alloc] initWithData: data error: nil];
    
    // 1、把 html 当中的body部分取出来
    HTMLNode *bodyNode = [parser body];
    
    NSArray *cellNodeArrays = [bodyNode findChildrenOfClass: @"cell item"];
    
    NSMutableArray *topics = [NSMutableArray array];
    for(HTMLNode *cellNode in cellNodeArrays)
    {
        @autoreleasepool {
            
            
            // 1、节点
            NSString *node = nil;
            {
                node = [cellNode findChildOfClass: @"node"].allContents;
            }
            
            // 2、标题
            NSString *title = nil;
            NSString *detailUrl = nil;
            {
                HTMLNode *itemTitleNode = [cellNode findChildOfClass: @"item_title"];
                title = itemTitleNode.allContents;
                
                HTMLNode *aNode = [itemTitleNode findChildTag: @"a"];
                NSString *href = [aNode getAttributeNamed: @"href"];
                if (href != nil)
                {
                    detailUrl = [WTHTTPBaseUrl stringByAppendingPathComponent: href];
                }
            }
            
            // 3、时间
            NSString *createTime = nil;
            {
                HTMLNode *smallFadeNode = [cellNode findChildrenOfClass: @"small fade"].lastObject;
                NSArray *contents = [smallFadeNode.allContents componentsSeparatedByString: @"•"];
                if (contents.count > 0)
                {
                    createTime = [contents[0] stringByReplacingOccurrencesOfString: @" " withString: @""];
                    
                    // 可能存在 2014-01-01这样的数据，需要截取
                    if (createTime.length > 10)
                    {
                        createTime = [createTime substringToIndex: 9];
                    }
                }
            }
            
            // 4、回复数
            NSInteger replyCount = 0;
            {
                HTMLNode *countOrangeNode = [cellNode findChildOfClass: @"count_orange"];
                replyCount = [countOrangeNode.allContents integerValue];
            }
        
            
            // 创建WTTopic模型
            WTTopic *topic = [WTTopic new];
            {
                topic.title = title;
                topic.node = node;
                topic.createTime = createTime;
                topic.replyCount = replyCount;
                topic.detailUrl = detailUrl;
            }
            
            [topics addObject: topic];
        }
        
        
    }
    WTTopic *topic = [self getIsNextPageWithData: bodyNode];
    [topics addObject: topic];
    return topics;
}

/**
 *  根据二进制获取回复别人的话题数组
 *
 *  @param data 二进制
 *
 *  @return 话题数组
 */
+ (NSMutableArray<WTTopic *> *)getReplyTopicsWithData:(NSData *)data
{
    HTMLParser *parser = [[HTMLParser alloc] initWithData: data error: nil];
    
    // 1、把 html 当中的body部分取出来
    HTMLNode *bodyNode = [parser body];
    
    // 2、把 id = Wrapper 的节点
    HTMLNode *wrapperNode = [bodyNode findChildWithAttribute: @"id" matchingName: @"Wrapper" allowPartial: YES];
    
    // 3、把 class = dock_area 的节点
    NSArray *dock_areaNodes = [wrapperNode findChildrenOfClass: @"dock_area"];
    // 4、把 class = inner 的节点
    NSArray *innerNodes = [wrapperNode findChildrenOfClass: @"inner"];
    
    NSMutableArray *topics = [NSMutableArray array];
    for (int i = 0; i < dock_areaNodes.count; i++)
    {
        @autoreleasepool {
            
            HTMLNode *dock_areaNode = dock_areaNodes[i];
            
            // 1、时间
            NSString *lastReplyTime = nil;
            {
                HTMLNode *fadeNode = [dock_areaNode findChildOfClass: @"fade"];
                lastReplyTime = [fadeNode.allContents stringByReplacingOccurrencesOfString: @" " withString: @""];
            }
            
            // 2、作者
            NSString *author = nil;
            {
                HTMLNode *grayNode = [dock_areaNode findChildOfClass: @"gray"];
                NSString *grayContents = grayNode.allContents;
                NSArray *grayContentArray = [grayContents componentsSeparatedByString: @"›"];
                if (grayContentArray.count > 0)
                {
                    NSString *firstGrayContents = grayContentArray[0];
                    NSArray *firstGrayContentArray = [firstGrayContents componentsSeparatedByString: @" "];
                    
                    if (firstGrayContentArray.count > 0)
                    {
                        NSString *authorContent =  firstGrayContentArray[1];
                        author = [authorContent stringByReplacingOccurrencesOfString: @" " withString: @""];
                    }
                }
            }
            
            // 3、标题、话题详情url
            NSString *title = nil;
            NSString *detailUrl = nil;
            {
                HTMLNode *aNode = [dock_areaNode findChildTag: @"a"];
                title = aNode.allContents;
                
                NSString *href = [aNode getAttributeNamed: @"href"];
                if (href != nil)
                {
                    detailUrl = [WTHTTPBaseUrl stringByAppendingString: href];
                }
            }
            
            // 4、回复内容
            NSString *content = nil;
            {
                HTMLNode *innerNode = innerNodes[i];
                HTMLNode *reply_contentNode = [innerNode findChildOfClass: @"reply_content"];
                content = reply_contentNode.allContents;
            }
            
            // 5、话题模型
            WTTopic *topic = [WTTopic new];
            {
                topic.lastReplyTime = lastReplyTime;
                topic.author = author;
                topic.title = title;
                topic.detailUrl = detailUrl;
                topic.content = content;
            }
            [topics addObject: topic];
        }
    }
    WTTopic *topic = [self getIsNextPageWithData: bodyNode];
    [topics addObject: topic];
    return  topics;
}

/**
 *  获取用户的once的值
 *
 *  @param html html源码
 */
+ (NSString *)getOnceWithHtml:(NSString *)html
{
    NSRange range = [html rangeOfString: @"/signout?once="];
    return [html substringWithRange: NSMakeRange(range.location + range.length, 5)];
}

/**
 *  获取验证码的Url
 *
 *  @param html html源码
 *
 */
+ (NSString *)getCodeUrlWithData:(NSData *)data
{
    HTMLParser *parser = [[HTMLParser alloc] initWithData: data error: nil];
    
    // 1、把 html 当中的body部分取出来
    HTMLNode *bodyNode = [parser body];
    
    // 2、获取 action = '/signup'的form节点
    HTMLNode *formNode = [bodyNode findChildWithAttribute: @"action" matchingName: @"/signup" allowPartial: YES];

    // 3、获取所有tr标签
    NSArray *trNodes = [formNode findChildTags: @"tr"];
    
    // 4、获取 codeUrl
    NSString *codeUrl = nil;
    if (trNodes.count > 4)
    {
        HTMLNode *imgNode = [trNodes[3] findChildTag: @"img"];
        codeUrl = [imgNode getAttributeNamed: @"src"];
    }
    
    return codeUrl;
}
@end
