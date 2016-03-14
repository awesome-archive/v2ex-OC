//
//  WTTopicDetailViewModel.h
//  v2ex
//
//  Created by 无头骑士 GJ on 16/3/12.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WTTopicDetailNew.h"
#import "NetworkTool.h"
@interface WTTopicDetailViewModel : NSObject
/** 话题详情模型 */
@property (nonatomic, strong) WTTopicDetailNew *topicDetail;
/** 头像 */
@property (nonatomic, strong) NSURL            *iconURL;
/** 正文HTML版 */
@property (nonatomic, strong) NSString         *contentHTML;
/** 楼层 */
@property (nonatomic, strong) NSString         *floorText;
/** 节点 */
@property (nonatomic, strong) NSString         *nodeText;
/** 收藏地址 */
@property (nonatomic, strong) NSString         *collectionUrl;
/** 喜欢、收藏 必须要提交的字段与值 */
@property (nonatomic, strong) NSString         *once;
/** 创建时间Text */
@property (nonatomic, strong) NSString         *createTimeText;
/**
 *  根据data解析出话题数组
 *
 *  @param data data
 *
 *  @return 话题数组
 */
+ (NSMutableArray<WTTopicDetailViewModel *> *)topicDetailsWithData:(NSData *)data;

/**
 *  发送收藏请求
 *
 *  @param urlString  请求地址
 *  @param completion 完成block
 */
+ (void)collectionWithUrlString:(NSString *)urlString topicDetailUrl:(NSString *)topicDetailUrl completion:(void(^)(WTTopicDetailViewModel *topicDetailVM, NSError *error))completion;
@end
