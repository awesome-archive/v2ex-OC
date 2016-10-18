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
#import "NSString+Regex.h"
@implementation WTTopicDetailViewModel

#pragma mark - 根据data解析出话题数组
+ (NSMutableArray<WTTopicDetailViewModel *> *)topicDetailsWithData:(NSData *)data
{
//    NSString *html = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    NSMutableArray<WTTopicDetailViewModel *> *topics = [NSMutableArray array];
    
    TFHpple *doc = [[TFHpple alloc] initWithHTMLData: data];
    
    // 1、有些主题必须要登陆才能查看
    TFHppleElement *messageElement = [doc peekAtSearchWithXPathQuery: @"//div[@class='message']"];
    if (messageElement != nil)
    {
        return nil;
    }
    
    [topics addObject: [self parseTopicDetailWithDoc: doc]];
    
    [topics addObjectsFromArray: [self parseTopicCommentWithDoc: doc]];
    
    return topics;
}

#pragma mark - 发送收藏请求
//+ (void)collectionWithUrlString:(NSString *)urlString topicDetailUrl:(NSString *)topicDetailUrl completion:(void(^)(WTTopicDetailViewModel *topicDetailVM, NSError *error))completion;
//{
//    
//    [[NetworkTool shareInstance] getHtmlCodeWithUrlString: urlString success:^(NSData *data) {
//       
//        [self topicDetailWithUrlString: topicDetailUrl completion:^(WTTopicDetailViewModel *topicDetailVM, NSError *error) {
//           
//            if (completion)
//            {
//                completion(topicDetailVM, error);
//            }
//            
//        }];
//        
//    } failure:^(NSError *error) {
//        
//        if (completion)
//        {
//            completion(nil, error);
//        }
//    }];
//}

#pragma mark - 操作帖子请求的方法
+ (void)topicOperationWithMethod:(HTTPMethodType)method urlString:(NSString *)urlString topicDetailUrl:(NSString *)topicDetailUrl completion:(void(^)(WTTopicDetailViewModel *topicDetailVM, NSError *error))completion;
{
    void (^successBlock)(NSData *data) = ^(NSData *data){
        
        [self topicDetailWithUrlString: topicDetailUrl completion:^(WTTopicDetailViewModel *topicDetailVM, NSError *error) {
            
            if (completion)
            {
                completion(topicDetailVM, error);
            }
            
        }];
    };
    
    void (^errorBlock)(NSError *error) = ^(NSError *error){
        if (completion)
        {
            completion(nil, error);
        }
    };

    if (method == HTTPMethodTypeGET)
    {
        [[NetworkTool shareInstance] GETWithUrlString: urlString success: successBlock failure: errorBlock];
    }
    else
    {
        [[NetworkTool shareInstance] postHtmlCodeWithUrlString: urlString success: successBlock failure: errorBlock];
    }
}

#pragma mark - 请求作者话题的详情
+ (void)topicDetailWithUrlString:(NSString *)urlString completion:(void(^)(WTTopicDetailViewModel *topicDetailVM, NSError *error))completion
{
    [[NetworkTool shareInstance] GETWithUrlString: urlString success:^(NSData *data) {
        
        TFHpple *doc = [[TFHpple alloc] initWithHTMLData: data];
        
        WTTopicDetailViewModel *topicDetailVM = [self parseTopicDetailWithDoc: doc];
        
        if (completion)
        {
            completion(topicDetailVM, nil);
        }
        
    } failure:^(NSError *error) {
        if (completion)
        {
            completion(nil, error);
        }
    }];
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
    
    // 7、楼层
    TFHppleElement *floorElement = [doc searchWithXPathQuery: @"//span[@class='no']"].firstObject;
    
    // 8、操作
    NSArray<TFHppleElement *> *operations = [doc searchWithXPathQuery: @"//a[@class='op']"];
    
    // 9、once
    TFHppleElement *onceElement = [doc searchWithXPathQuery: @"//input[@name='once']"].firstObject;
    
    // 10、thank 喜欢
    TFHppleElement *topicThankE = [doc peekAtSearchWithXPathQuery: @"//div[@id='topic_thank']"];
    
    // 11、当前的页数
    TFHppleElement *currentPageE = [doc peekAtSearchWithXPathQuery: @"//span[@class='page_current']"];
    
    WTTopicDetailViewModel *topicDetailVM = [WTTopicDetailViewModel new];
    {
        WTTopicDetail *topicDetail = [WTTopicDetail new];
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
        topicDetailVM.contentHTML = [NSString stringWithFormat: @"<!DOCTYPE HTML><html><meta content='width=device-width; initial-scale=1.0; maximum-scale=1.0; user-scalable=0' name='viewport'><head>%@</head><body>%@</body></html>", cssStr, topicDetail.content];

        // 3、节点
        topicDetailVM.nodeText = [NSString stringWithFormat: @" %@  ", topicDetail.node];
        
        // 4、楼层
        topicDetailVM.floorText = floorElement.content;
        
        // 5、感谢、收藏、忽略
        if (operations.count > 0)
        {
            topicDetailVM.collectionUrl = [WTHTTPBaseUrl stringByAppendingPathComponent: [operations.firstObject objectForKey: @"href"]];
        }
        
        // 6、once
        topicDetailVM.once = [onceElement objectForKey: @"value"];
        
        // 7、创建时间
        topicDetailVM.createTimeText = [NSString subStringFromIndexWithStr: @"at " string: topicDetail.createTime];
        
        // 8、感谢
        topicDetailVM.thankType = WTThankTypeUnknown;     // 未知原因
        if (topicThankE != nil)
        {
            NSString *topicThankContent = topicThankE.content;
            topicDetailVM.thankType = WTThankTypeAlready; // 已经感谢过
            if ([topicThankContent isEqualToString: @"感谢"])
            {
                topicDetailVM.thankUrl = [WTParseTool parseThankUrlWithFavoriteUrl: topicDetailVM.collectionUrl];
                topicDetailVM.thankType = WTThankTypeNotYet;                     // 未感谢
            }
        }
        
        // 9、页数
        topicDetailVM.currentPage = [currentPageE.content integerValue];
    }
    
    
    
    return topicDetailVM;
}

#pragma mark - 解析评论数组
+ (NSMutableArray<WTTopicDetailViewModel *> *)parseTopicCommentWithDoc:(TFHpple *)doc
{
    TFHppleElement *boxElement = [[doc searchWithXPathQuery: @"//div[@class='box']"] objectAtIndex: 1];
    
    NSMutableArray<WTTopicDetailViewModel *> *topicDetailVMs = [NSMutableArray array];
    
    NSArray<TFHppleElement *> *cellArr = [boxElement searchWithXPathQuery: @"//table"];
    
    for (TFHppleElement *cell in cellArr)
    {
        TFHppleElement *contentE = [cell searchWithXPathQuery: @"//div[@class='reply_content']"].firstObject;
        if (contentE == nil)
        {
            continue;
        }
        
        TFHppleElement *iconE = [cell searchWithXPathQuery: @"//img[@class='avatar']"].firstObject;
        
        TFHppleElement *authorE = [cell searchWithXPathQuery: @"//a[@class='dark']"].firstObject;
        
        TFHppleElement *timeE = [cell searchWithXPathQuery: @"//span[@class='fade small']"].firstObject;
        
        TFHppleElement *floorE = [cell searchWithXPathQuery: @"//span[@class='no']"].firstObject;
        
        WTTopicDetailViewModel *topicDetailVM = [WTTopicDetailViewModel new];
        {
            WTTopicDetail *topicDetail = [WTTopicDetail new];
            
            topicDetail.content = contentE.content;
            
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
