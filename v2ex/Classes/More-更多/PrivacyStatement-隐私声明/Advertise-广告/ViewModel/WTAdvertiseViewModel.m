//
//  WTAdvertiseViewModel.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/7/25.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTAdvertiseViewModel.h"
#import "NetworkTool.h"
#import "TFHpple.h"
#import "WTUrlConst.h"

@implementation WTAdvertiseViewModel

/**
 *  从网络中加载广告
 *
 *  @param success 请求成功的回调
 *  @param failure 请求失败的回调
 */
+ (void)loadAdvertiseItemsFromNetworkWithSuccess:(void(^)(NSMutableArray<WTAdvertiseItem *> *advertiseItems))success failure:(void(^)(NSError *error))failure
{
    NSString *urlString = @"http://www.v2ex.com/advertise/2016.html";
    
    [[NetworkTool shareInstance] GETWithUrlString: urlString success:^(id data) {
        
        WTLog(@"html:%@", [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding])
        
        NSMutableArray<WTAdvertiseItem *> *advertiseItems = [self loadAdvertiseItemsWithData: data];
        
        if (success)
        {
            success(advertiseItems);
        }
        
    } failure:^(NSError *error) {
        
        if (failure)
        {
            failure(error);
        }
        
    }];
}

+ (NSMutableArray<WTAdvertiseItem *> *)loadAdvertiseItemsWithData:(NSData *)data
{
    TFHpple *doc = [[TFHpple alloc] initWithHTMLData: data];
    NSArray *cellEs = [doc searchWithXPathQuery: @"//div[@id='Wrapper']//div[@class='cell']"];
    
    NSMutableArray<WTAdvertiseItem *> *advertiseItems = [NSMutableArray array];
    for (TFHppleElement *cellE in cellEs)
    {
        TFHppleElement *detailUrlE = [cellE searchWithXPathQuery: @"//a[@target='_blank']"].firstObject;
        
        if(detailUrlE == nil)
            continue;
        
        NSString *detailUrl = [detailUrlE objectForKey: @"href"];
        
        TFHppleElement *iconE = [cellE searchWithXPathQuery: @"//img"].firstObject;
        
        NSString *src = [NSString stringWithFormat: @"%@%@", WTHTTP, [iconE objectForKey: @"src"]];
        
        NSString *title = [iconE objectForKey: @"alt"];
        
        TFHppleElement *contentE = [cellE searchWithXPathQuery: @"//div[@class='topic_content']"].firstObject;
        
        NSString *content = contentE.content;
        
        WTAdvertiseItem *advertiseItem = [WTAdvertiseItem advertiseItem: [NSURL URLWithString: src] title: title content: content detailUrl: detailUrl];
        [advertiseItems addObject: advertiseItem];
    }
    
    return advertiseItems;
}

@end
