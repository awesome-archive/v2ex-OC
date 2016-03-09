//
//  WTBlogDetail.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/1/18.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTTopicDetail.h"
#import "HTMLParser.h"
#import "HTMLNode.h"
#import "WTURLConst.h"
#import "NSString+Regex.h"
#import "TYAttributedLabel.h"
@implementation WTTopicDetail

/**
 *  根据二进制流解析作者话题详情
 *
 *  @param data 二进制
 *
 *  @return WTTopicDetail
 */
+ (WTTopicDetail *)authorTopicDetailWithData:(NSData *)data
{
    HTMLParser *parser = [[HTMLParser alloc] initWithData: data error: nil];
    
    HTMLNode *bodyNode = [parser body];
    
    HTMLNode *headNode = [parser head];
    
    HTMLNode *htmlNode = [parser html];
    
    // 2、解析博客的详情
    WTTopicDetail *authorDetail = [self getTopTopicDetailWithBodyNode: bodyNode headNode: headNode htmlNode: htmlNode];
    
    return authorDetail;
}

/**
 *  根据二进制流解析topicDetail
 *
 *  @param data 二进制
 *
 *  @return WTTopicDetail
 */
+ (NSArray *)topicDetailWithData:(NSData *)data
{
    HTMLParser *parser = [[HTMLParser alloc] initWithData: data error: nil];
    
    // 1、把 html 当中的body部分取出来
    HTMLNode *bodyNode = [parser body];
    
    HTMLNode *headNode = [parser head];
    
    HTMLNode *htmlNode = [parser html];
    
    // 2、话题数据
    NSMutableArray *topicDetailArray = [NSMutableArray array];

    // 3、有可能存在需要登陆的帖子
    if([bodyNode.allContents containsString: @"查看本主题需要登录"])
    {
        return topicDetailArray;
    }
    
    // 4、解析博客的详情
    WTTopicDetail *authorDetail = [self getTopTopicDetailWithBodyNode: bodyNode headNode: headNode htmlNode: htmlNode];
    
    // 5、解析评论
    NSArray *commentArray = [self getBottomTopicDetailWithBodyNode: bodyNode];
    
    
    
    {
        // 添加作者博客详情
        [topicDetailArray addObject: authorDetail];
        
        // 添加评论数组
        [topicDetailArray addObjectsFromArray: commentArray];
        
       // WTLog(@"blogDetailArray:%@", topicDetailArray);
    }
    
    return topicDetailArray;
}

/**
 *  解析话题的详情
 *
 *  @param bodyNode body html
 *
 *  @return 作者话题详情
 */
+ (WTTopicDetail *)getTopTopicDetailWithBodyNode:(HTMLNode *)bodyNode headNode:(HTMLNode *)headNode htmlNode:(HTMLNode *)htmlNode
{
    // 获取 class = 'header'的节点
    HTMLNode *headerNode = [bodyNode findChildOfClass: @"header"];
    
    // 1、标题
    NSString *title = [headerNode findChildTag: @"h1"].allContents;
    
    
    // 2、创建时间和查看次数
    NSArray *grays = [NSArray array];
    {
        // 获取 class = 'gray' 的节点
        HTMLNode *grayNode = [headerNode findChildOfClass: @"gray"];
        
        grays = [grayNode.allContents componentsSeparatedByString: @","];
    }
    
    // 3、正文内容
    NSString *content = nil;
    NSString *normalContent = nil;
    NSString *mardownStr = nil;
    {
        // 获取 id = 'Main' 的节点
        HTMLNode *mainNode = [bodyNode findChildWithAttribute: @"id" matchingName: @"Wrapper" allowPartial: YES];
        // 获取 class = 'box' 的节点数组
        NSArray *boxArray = [mainNode findChildrenOfClass: @"box"];
        
        HTMLNode *firstBoxNode = [boxArray firstObject];
        
        // 取出 class = 'cell'的节点
        NSArray *contentNodes = [firstBoxNode findChildrenOfClass: @"topic_content"];
        
        NSMutableString *contentTemp = [NSMutableString string];
        for (HTMLNode *contentNode in contentNodes)
        {
//            normalContent = [NSString stringWithFormat: @"%@%@", normalContent, contentNode.allContents];
            [contentTemp appendString: contentNode.allContents];
        }
        
        //normalContent = [contentTemp stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        normalContent = [NSString stringWithFormat: @"<!DOCTYPE html><html lang=\"zh-CN\">                                   <head><meta charset=\"utf-8\"></head><body>%@</body></html>", [firstBoxNode findChildOfClass: @"topic_content"].rawContents];
        
        
        HTMLNode *mardownNode = [contentNodes.firstObject findChildOfClass: @"markdown_body"];
        mardownStr = mardownNode.rawContents;
    }
   
    // 4、头像地址
    NSString *icon = nil;
    {
        // 获取 class = 'avatar' 节点
        HTMLNode *avatarNode = [headerNode findChildOfClass: @"avatar"];
        // 获取 img 标题的 src 属性的值
        icon = [avatarNode getAttributeNamed: @"src"];
    }
    
    // 5、标题的描述
    NSString *description = nil;
    
    {
        // 获取 name = 'description' 节点
        HTMLNode *descriptionNode = [headNode findChildWithAttribute: @"name" matchingName: @"description" allowPartial: YES];
        // descriptionNode节点的属性content的值
        description = [descriptionNode getAttributeNamed: @"content"];
    }
    
    //HTMLNode *headerNode = [bodyNode findChildOfClass: @"header"];
    
    // 6、节点
    NSString *node = nil;
    {
        NSArray *aNodeArray = [headerNode findChildTags: @"a"];
        if (aNodeArray.count > 2)
        {
            
            HTMLNode *aNode = aNodeArray[2];
            node = aNode.allContents;
        }
    }
    
    // 7、作者
    NSString *author = nil;
    {
        HTMLNode *aNode = [[headerNode findChildOfClass: @"fr"] findChildTag: @"a"];
        NSString *href = [aNode getAttributeNamed: @"href"];
        author = href.lastPathComponent;
    }

    
    // 8、查找 name = 'once'的节点的值，这个值用于回复帖子用的
    NSString *once = nil;
    {
        HTMLNode *onceNode = [bodyNode findChildWithAttribute: @"name" matchingName: @"once" allowPartial: YES];
        once = [onceNode getAttributeNamed: @"value"];
    }
    
    // 9、收藏、喜欢
    NSString *collectionText = nil;
    NSString *collectionUrl = nil;
    NSString *loveUrl = nil;
    {
        HTMLNode *innerNode = [bodyNode findChildOfClass: @"inner"];
        
        NSArray *opArray = [innerNode findChildrenOfClass: @"op"];
        
        if (opArray.count > 0)
        {
            // 1、收藏
            HTMLNode *collectionNode = opArray.firstObject;
            collectionText = collectionNode.allContents;
            collectionUrl = [collectionNode getAttributeNamed: @"href"];
            
            
            // 2、喜欢
            //HTMLNode *loveNode = opArray.lastObject;
            //loveText = loveNode.allContents;
            // 利用firebug查看发现和加入收藏地址只是 favorite或者unfavorite 替换 thank即可
            HTMLNode *f11GrayNode = [innerNode findChildOfClass: @"f11 gray"];
            if (f11GrayNode != nil)
            {
                if ([collectionUrl containsString: @"unfavorite"])
                {
                    loveUrl = [collectionUrl stringByReplacingOccurrencesOfString: @"unfavorite" withString: @"thank"];
                }
                else
                {
                    loveUrl = [collectionUrl stringByReplacingOccurrencesOfString: @"favorite" withString: @"thank"];
                }
            }
        }
    }
    
    // 10、楼层
    NSString *floor = nil;
    {
        HTMLNode *noNode = [bodyNode findChildOfClass: @"no"];
        floor = noNode.allContents;
    }

    // 11、初始化 blogDetail
    WTTopicDetail *topicDetail = [WTTopicDetail new];

    {
        // 1、标题
        topicDetail.title = title;
        
        // 2、正文内容
        topicDetail.content = content;
        topicDetail.normalContent = normalContent;
        
        // 3、创建时间
        NSString *createTimeTemp = grays[0];
        NSRange createTimeRange = [createTimeTemp rangeOfString: @"at"];
        createTimeTemp = [createTimeTemp substringFromIndex: createTimeRange.location + createTimeRange.length];
        NSString *createTime = [createTimeTemp stringByReplacingOccurrencesOfString: @" " withString: @""];
        if ([createTime containsString: @":"])// 解析去年的时间
        {
            topicDetail.createTime = [createTimeTemp substringWithRange: NSMakeRange(3, 14)];
        }
        else // 今年的时间
        {
            topicDetail.createTime = createTime;
        }
        
        
        // 4、头像 (之前有测试到icon可以为nil,如果为nil的话，就直接使用之前的topic里面的icon,暂时就这么处理吧)
        if (icon != nil)
        {
            topicDetail.icon = [NSURL URLWithString: [WTHTTP stringByAppendingString: icon]];
        }
        
        NSArray *descriptions = [description componentsSeparatedByString: @" -"];
        
        // 5、同头像的处理
        if (descriptions.count >= 2) {
            // 5、节点名称
            topicDetail.node = descriptions[0];;
        }
        
        // 6、加入收藏、取消收藏
        if (collectionText != nil)
        {
            topicDetail.collection = [collectionText isEqualToString: @"取消收藏"];
            topicDetail.collectionUrl = collectionUrl;
        }
        
        // 7、感谢、已经感谢
        topicDetail.love = loveUrl != nil;
        topicDetail.loveUrl = loveUrl;
        
        // 8、点击次数
        topicDetail.seeCount = [NSString getNumberWithString: grays[1]];
        
        // 8、节点
        topicDetail.node = node;
        
        // 10、作者
        topicDetail.author = author;
        
        // 额外
        // 11、markdown正文内容
        if (mardownStr != nil) {
            topicDetail.markdownStr = [NSString stringWithFormat: @"<!DOCTYPE html><html lang=\"zh-CN\">                                   <head><meta charset=\"utf-8\"></head><body>%@</body></html>", mardownStr];
        }
        
    
        // 12、once
        topicDetail.once = once;
        
        // 13、floor
        if (floor != nil)
        {
            topicDetail.floor = [floor integerValue];
        }
    }
    
    return topicDetail;
}

#pragma mark - 解析评论
+ (NSArray *)getBottomTopicDetailWithBodyNode:(HTMLNode *)bodyNode
{
    // 1、查看所有 table 节点

    // 查找 id = 'Main' 节点
    //HTMLNode *mainNode = [bodyNode findChildWithAttribute: @"id" matchingName: @"Main" allowPartial: YES];
    // 本主题需要登录
    if ([bodyNode.rawContents containsString: @"查看本主题需要登录"])
    {
        return [NSArray array];
    }
    // 查找所有table节点
    NSArray *tableArray = [bodyNode findChildTags: @"table"];
    
    // 2、创建评论数组，并遍历table节点赋值
    NSMutableArray *commentArray = [NSMutableArray array];
    {
        // 遍历所有 table 节点
        for (HTMLNode *node in tableArray)
        {
            @autoreleasepool {

                // 1、头像
                NSString *icon = nil;
                
                {
                    // 头像节点
                    HTMLNode *avatarNode = [node findChildWithAttribute: @"class" matchingName: @"avatar" allowPartial: YES];
                    
                    if (avatarNode == nil)
                    {
                        continue;
                    }
                    
                    // 拼接头像地址
                    icon = [WTHTTP stringByAppendingString: [avatarNode getAttributeNamed: @"src"]];
                }
                
                
                // 2、作者
                NSString *author = nil;
                {
                    // 查找 strong 标签
                    HTMLNode *strongNode = [node findChildTag: @"strong"];
                    // 作者名称
                    author = strongNode.allContents;
                }
               
                // 3、创建时间
                NSString *createTime = nil;
                
                {
                    // 查找 class = 'fade small'节点
                    HTMLNode *fade_smallNode = [node findChildWithAttribute: @"class" matchingName: @"fade small" allowPartial: YES];
                    // 创建时间
                    createTime = fade_smallNode.allContents;
                    if ([createTime containsString: @":"])
                    {
                        createTime = [createTime substringWithRange: NSMakeRange(2, 14)];
                    }
                }
                
                // 4、正文内容
                NSString *content = nil;
                
                {
                    // 查找 class = 'reply_content' 节点
                    HTMLNode *reply_contentNode = [node findChildOfClass: @"reply_content"];
                    content = [NSString stringWithFormat: @"<!DOCTYPE html><html lang=\"zh-CN\">                                   <head><meta charset=\"utf-8\"></head><body>%@</body></html>", reply_contentNode.rawContents];
                }
                
                // 5、楼层
                NSString *floor = nil;
                
                {
                    HTMLNode *floorNode = [node findChildOfClass: @"no"];
                    floor = floorNode.allContents;
                }
                
                // 7、创建 topDicDetal
                WTTopicDetail *topicDetail = [WTTopicDetail new];
                
                {
                    // 1、头像
                    topicDetail.icon = [NSURL URLWithString: icon];
                    // 2、作者
                    topicDetail.author = author;
                    // 3、创建时间
                    topicDetail.createTime = createTime;
                    // 4、内容
                    topicDetail.content = content;
                    // 5、楼层
                    topicDetail.floor = [floor integerValue];
                    
                   
                }
                
                // 8、添加到数组中
                [commentArray addObject: topicDetail];
            }
        }
    }
    return commentArray;
}

+ (void)parseContets:(HTMLNode *)cellNode
{
    HTMLNode *mardownNode = [cellNode findChildOfClass: @"markdown_body"];
    
    HTMLNode *firstChild = mardownNode.firstChild;
    if (firstChild) {
        WTLog(@"contents:%@", mardownNode.children);
        
    }
    for (HTMLNode *htmlNode in mardownNode.children)
    {
        if ([htmlNode.allContents containsString: @"<img"])
        {
            TYImageStorage *imageUrlStorage = [[TYImageStorage alloc]init];
            imageUrlStorage.imageURL = [NSURL URLWithString:@"https://raw.githubusercontent.com/bigfa/kana/screenshot/mobile.png"];
            imageUrlStorage.placeholdImageName = @"icon_placeholder";
            imageUrlStorage.size = CGSizeMake(374, 400);
            
        }
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat: @"author:%@, createTime:%@, nodeName:%@, floor:%zd" , self.author, self.createTime, self.node, self.floor];
}
@end
