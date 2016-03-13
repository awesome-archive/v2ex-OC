//
//  WTTopicDetailViewModel.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/3/12.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTTopicDetailViewModel.h"
#import "TFHpple.h"
#import "WTURLConst.h"
#import "WTParseTool.h"
@implementation WTTopicDetailViewModel

#pragma mark - 根据data解析出话题数组
+ (NSMutableArray<WTTopicDetailViewModel *> *)topicDetailsWithData:(NSData *)data
{
//    NSString *html = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    NSMutableArray<WTTopicDetailViewModel *> *topics = [NSMutableArray array];
    
    TFHpple *doc = [[TFHpple alloc] initWithHTMLData: data];
    
    [topics addObject: [self parseTopicDetailWithDoc: doc]];
    
    [topics addObjectsFromArray: [self parseTopicCommentWithDoc: doc]];
    
    return topics;
}

#pragma mark - 根据doc解析话题正文内容
+ (WTTopicDetailViewModel *)parseTopicDetailWithDoc:(TFHpple *)doc
{
    // 1、正文
    TFHppleElement *topicContentElement = [doc peekAtSearchWithXPathQuery: @"//div[@class='topic_content']"];
    
    // 2、时间数组
    NSArray<TFHppleElement *> *timeArray = [doc searchWithXPathQuery: @"//small[@class='gray']"];
    
    TFHppleElement *headerElement = [doc peekAtSearchWithXPathQuery: @"//div[@class='header']"];
    // 3、头像
    TFHppleElement *iconElement = [headerElement searchWithXPathQuery: @"//img[@class='avatar']"][0];
    // 4、作者
    TFHppleElement *authorElement = [headerElement searchWithXPathQuery: @"//small[@class='gray']//a"][0];
    
    // 5、标题
    TFHppleElement *titleElement = [headerElement searchWithXPathQuery: @"//h1"].firstObject;
    
    // 6、节点
    TFHppleElement *nodeElement = [headerElement searchWithXPathQuery: @"//a"][2];
    
    WTTopicDetailViewModel *topicDetailVM = [WTTopicDetailViewModel new];
    {
        WTTopicDetailNew *topicDetail = [WTTopicDetailNew new];
        // 正文
        topicDetail.content = topicContentElement.raw;
    
        // 创建时间
        topicDetail.createTime = timeArray.firstObject.content;
        
        // 头像
        topicDetail.icon = [iconElement objectForKey: @"src"];
        
        // 作者
        topicDetail.author = authorElement.content;
        
        // 标题
        topicDetail.title = titleElement.content;
        
        // 节点
        topicDetail.node = nodeElement.content;
      
        topicDetailVM.topicDetail = topicDetail;
        
        // 1、头像 (由于v2ex抓下来的都不是清晰的头像，替换字符串转换成相对清晰的URL)
        topicDetailVM.iconURL = [WTParseTool parseBigImageUrlWithSmallImageUrl: topicDetail.icon];
        
        
        // 2、拼接HTML正文内容
        NSString *cssPath = [[NSBundle mainBundle] pathForResource: @"light.css" ofType: nil];
        NSString *cssStr = [NSString stringWithContentsOfFile: cssPath encoding: NSUTF8StringEncoding error: nil];
        topicDetailVM.contentHTML = [NSString stringWithFormat: @"<!DOCTYPE HTML><html><head>%@</head><body>%@</body></html>", cssStr, topicDetail.content];

        // 3、节点
        topicDetailVM.nodeText = [NSString stringWithFormat: @" %@  ", topicDetail.node];
    }
    
    return topicDetailVM;
}

#pragma mark - 解析评论数组
+ (NSMutableArray<WTTopicDetailViewModel *> *)parseTopicCommentWithDoc:(TFHpple *)doc
{
    NSMutableArray<WTTopicDetailViewModel *> *topicDetailVMs = [NSMutableArray array];
    
    NSArray<TFHppleElement *> *cellArr = [doc searchWithXPathQuery: @"//div[@class='cell']"];
    
    for (TFHppleElement *cell in cellArr)
    {
        TFHppleElement *ContentE = [cell searchWithXPathQuery: @"//div[@class='reply_content']"].firstObject;
        if (ContentE == nil)
        {
            continue;
        }
        
        TFHppleElement *iconE = [cell searchWithXPathQuery: @"//img[@class='avatar']"].firstObject;
        
        TFHppleElement *authorE = [cell searchWithXPathQuery: @"//a[@class='dark']"].firstObject;
        
        TFHppleElement *timeE = [cell searchWithXPathQuery: @"//span[@class='fade small']"].firstObject;
        
        TFHppleElement *floorE = [cell searchWithXPathQuery: @"//span[@class='no']"].firstObject;
        
        WTTopicDetailViewModel *topicDetailVM = [WTTopicDetailViewModel new];
        {
            WTTopicDetailNew *topicDetail = [WTTopicDetailNew new];
            
            topicDetail.content = ContentE.content;
            
            topicDetail.icon = [iconE objectForKey: @"src"];
            
            topicDetail.author = authorE.content;
            
            topicDetail.createTime = timeE.content;
            
            topicDetail.floor = floorE.content;
            
            topicDetailVM.topicDetail = topicDetail;
            
            
            // 1、楼层
            topicDetailVM.floorText = [NSString stringWithFormat: @"#%@", topicDetail.floor];
            
            // 2、高清头像
            topicDetailVM.iconURL = [WTParseTool parseBigImageUrlWithSmallImageUrl: topicDetail.icon];
        }
        [topicDetailVMs addObject: topicDetailVM];
    }
    return topicDetailVMs;
}

@end
