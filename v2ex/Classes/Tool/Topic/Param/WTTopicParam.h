//
//  WTBlogParam.h
//  v2ex
//
//  Created by 无头骑士 GJ on 16/1/15.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WTTopicParam : NSObject

/** 节点名称 */
@property (nonatomic, strong) NSString          *nodeName;

/** url后缀 */
@property (nonatomic, strong) NSString          *urlString;

/** 第几页 */
@property (nonatomic, assign) NSInteger         page;

/**
 *  快速创建的类方法
 *
 *  @param urlSuffix    url后缀
 *  @param page         第几页
 *
 *  @return             WTBlogParam
 */
+ (instancetype)topicParamWithUrlString:(NSString *)urlString page:(NSInteger)page;


/**
 *  获取完整的路径
 *
 *  @return 路径
 */
- (NSString *)url;

@end
