//
//  WTBlog.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/1/14.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTTopic.h"
#import "HTMLParser.h"
#import "HTMLNode.h"
#import "WTURLConst.h"
@implementation WTTopic

/**
 *  是否是 `最近`节点
 *
 *  @param urlSuffix url后缀
 *
 *  @return YES 是 NO 否
 */
+ (BOOL)isNewestNodeWithUrlSuffix:(NSString *)urlSuffix
{
    if ([urlSuffix containsString: @"recent"] || [urlSuffix containsString: @"my"])
        return true;
    return false;
}

/**
 *  根据二进制流 返回一个博客数组
 *
 *  @param data 二进制
 *
 *  @return 博客数据
 */
+ (NSArray *)topicWithData:(NSData *)data
{
    // 根据 二进制对象 转换成 HTMLParser
    HTMLParser *parser = [[HTMLParser alloc] initWithData: data error: nil];
    // 取出html 所有内容
    HTMLNode *node = [parser body];
    
    // 查找 class = 'item_title'的节点 数组
    NSArray *cell_itemArray = [node findChildrenWithAttribute:@"class" matchingName:@"cell item" allowPartial:YES];
    
    // 添加评论对象 
    NSMutableArray *topics = [self parseTopicList: cell_itemArray];
    // 添加是否下一页对象
    [topics addObject: [self getIsNextPageWithData: node]];
    return topics;

}

/**
 *  判断是否有下一页
 *
 *  @param htmlNode body的HTMLNode
 *
 *  @return WTTopic
 */
+ (WTTopic *)getIsNextPageWithData:(HTMLNode *)htmlNode
{
    HTMLNode *buttonNode = [htmlNode findChildrenOfClass: @"super normal button"].lastObject;
    
    NSString *buttonValue = [buttonNode getAttributeNamed: @"value"];
    
    WTTopic *topic = [WTTopic new];
    
    {
        topic.hasNextPage = [buttonValue containsString: @"下一页 ›"];
    }
    return topic;
}

/**
 *  解析节点内的博客数据
 *
 *  @param data 进制
 *
 *  @return 博客数据
 */
+ (NSArray *)TopicsNodeBlogWithData:(NSData *)data
{
    // 根据 二进制对象 转换成 HTMLParser
    HTMLParser *parser = [[HTMLParser alloc] initWithData: data error: nil];
    
    // 取出html 所有内容
    HTMLNode *node = [parser body];
    
    // 查找 class = 'item_title'的节点 数组
    node = [node findChildWithAttribute: @"id" matchingName: @"TopicsNode" allowPartial: YES];
    
    NSArray *tableArray = [node findChildTags: @"table"];
    
    // 解析博客列表
    NSArray *blogs = [self parseTopicList: tableArray];
    
    return blogs;
}


/**
 *  解析博客列表   可以firefox 的 fireBug 插件访问http://www.v2ex.com/go/create 来查看返回html源码，以下部分源码
 *
 *  部分源码:
   <div class="cell from_141071 t_251085">
        <table cellpadding="0" cellspacing="0" border="0" width="100%">
            <tr>
                <td width="48" valign="top" align="center">
                    <a href="/member/GNiux">
                        <img src="//cdn.v2ex.co/avatar/cd4b/50ab/141071_normal.png?m=1451559467" class="avatar" border="0" align="default">
                    </a>
                </td>
                <td width="10"></td>
                <td width="auto" valign="middle">
                    <span class="item_title">
                        <a href="/t/251085#reply7">Manjaro-i3 / Bspwm 实在是把我迷住了</a>
                    </span>
                    <div class="sep5"></div>
                    <span class="small fade">
                        <strong>
                            <a href="/member/GNiux">GNiux</a>
                        </strong>  •  6 小时 36 分钟前  •  最后回复来自 
                        <strong>
                            <a href="/member/Tink">Tink</a>
                        </strong>
                    </span>
                </td>
                <td width="50" align="right" valign="middle">
                    <a href="/t/251085#reply7" class="count_livid">7</a>
                </td>
            </tr>
        </table>
     </div>
 *
 *  @param node html源码
 *
 *  @return 博客数组
 */
+ (NSMutableArray *)parseTopicList:(NSArray *)itemArray
{
    HTMLNode *node;
    
    // HTMLNode node
    NSArray *nodes;
    
    // blog 数组
    NSMutableArray *tmpArray = [NSMutableArray array];
    
    // small node
    HTMLNode *small_fadeNode;
    // small_fade node 中的 a 标签数组
    NSArray *small_fade_aNodeArray;
    
    NSArray *small_fadeNodeArray;
    
    //HTMLNode *lastCommentsPeopleNode;
    
    HTMLNode *lastTimeNode;
    
    for (HTMLNode *htmlNode in itemArray) {
        
        @autoreleasepool {
            // blog
            WTTopic *topic = [self new];
            
            //WTLog(@"htmlNode:%@", htmlNode.rawContents);
            
            // 1、头像
            topic.icon = [NSURL URLWithString: [WTHTTP stringByAppendingString: [[htmlNode findChildOfClass: @"avatar"] getAttributeNamed: @"src"]]];
            
            // 2、标题,链接地址
            node = [[htmlNode findChildOfClass: @"item_title"] findChildTag: @"a"];
            topic.title = node.contents;
            topic.detailUrl = [WTHTTPBaseUrl stringByAppendingPathComponent: [node getAttributeNamed: @"href"]];
            
            // 节点和作者、最后回复时间和最后回复人
            small_fadeNode = [htmlNode findChildOfClass: @"small fade"]; //: @"small fade"];
            small_fadeNodeArray = [htmlNode findChildrenOfClass: @"small fade"];
            small_fade_aNodeArray = [small_fadeNodeArray.firstObject findChildTags: @"a"];
            
            // 3、节点
            node = small_fade_aNodeArray[0];
            topic.node = node.contents;
            
            // 4、作者
            node = small_fade_aNodeArray[1];
            topic.author = node.allContents;

            // 6、最后回复时间
            NSString *lastReplyTime = nil;
            if (small_fadeNodeArray.count > 1)
            {
                lastTimeNode = small_fadeNodeArray.lastObject;
                nodes = [lastTimeNode.allContents componentsSeparatedByString: @"•"];
                lastReplyTime = nodes[0];
            }
            else
            {
                HTMLNode *firstSmallFadeNode = small_fadeNodeArray.firstObject;
                NSArray *firstSmallFadeContents = [firstSmallFadeNode.allContents componentsSeparatedByString: @"•"];
                if (firstSmallFadeContents.count > 2)
                {
                    lastReplyTime = firstSmallFadeContents[2];
                    
                }
            }
            if (lastReplyTime != nil)
            {
                lastReplyTime = [lastReplyTime stringByReplacingOccurrencesOfString: @" " withString: @""];
                topic.lastReplyTime = lastReplyTime;
            }
            
            // 7、回复数
            topic.replyCount = [[[htmlNode findChildOfClass: @"count_livid"] contents] integerValue];
            [tmpArray addObject: topic];
        }
    }
    return tmpArray;
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

- (NSString *)description
{
    return [NSString stringWithFormat: @"title:%@, replyCount:%ld", self.title, self.replyCount];
}


/*
 + (NSArray *)parseTopicList:(NSArray *)itemArray
 {
 HTMLNode *node;
 
 // HTMLNode node
 NSArray *nodes;
 
 // blog 数组
 NSMutableArray *tmpArray = [NSMutableArray array];
 
 // small node
 HTMLNode *small_fadeNode;
 // small_fade node 中的 a 标签数组
 NSArray *small_fade_aNodeArray;
 
 for (HTMLNode *htmlNode in itemArray) {
 
 @autoreleasepool {
 // blog
 WTTopic *topic = [self new];
 
 //WTLog(@"htmlNode:%@", htmlNode.rawContents);
 
 // 1、头像
 topic.icon = [NSURL URLWithString: [WTHTTP stringByAppendingString: [[htmlNode findChildOfClass: @"avatar"] getAttributeNamed: @"src"]]];
 
 // 2、标题,链接地址
 node = [[htmlNode findChildOfClass: @"item_title"] findChildTag: @"a"];
 topic.title = node.contents;
 topic.detailUrl = [WTHTTPBASEURL stringByAppendingPathComponent: [node getAttributeNamed: @"href"]];
 
 // 节点和作者、最后回复时间和最后回复人
 small_fadeNode = [htmlNode findChildOfClass: @"small fade"]; //: @"small fade"];
 
 small_fade_aNodeArray = [small_fadeNode findChildTags: @"a"];
 
 // 3、节点
 node = small_fade_aNodeArray[0];
 topic.node = node.contents;
 
 // 4、作者
 node = small_fade_aNodeArray[1];
 topic.author = node.allContents;
 
 // 5、最后回复人
 if (small_fade_aNodeArray.count > 2) {
 node = small_fade_aNodeArray[2];
 topic.lastCommentsPeople = node.allContents;
 }
 
 // 6、最后回复时间
 nodes = [small_fadeNode.rawContents componentsSeparatedByString: @"•"];
 NSString *lastReplyTime = [nodes[2] stringByReplacingOccurrencesOfString: @" " withString: @""];
 topic.lastReplyTime = lastReplyTime;
 
 
 // 7、回复数
 topic.replyCount = [[[htmlNode findChildOfClass: @"count_livid"] contents] integerValue];
 
 [tmpArray addObject: topic];
 }
 
 
 }
 
 return tmpArray;
 }

 */

@end
