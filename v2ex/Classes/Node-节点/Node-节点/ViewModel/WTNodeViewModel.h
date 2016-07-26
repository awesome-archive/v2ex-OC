//
//  WTNodeViewModel.h
//  v2ex
//
//  Created by 无头骑士 GJ on 16/7/21.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WTNodeItem.h"

@interface WTNodeViewModel : NSObject

@property (nonatomic, strong) NSArray<WTNodeItem *> *nodeItems;

@property (nonatomic, strong) NSString *title;

/**
 *  加载节点数据
 *
 *  @param success 请求成功的回调
 *  @param failure 请求失败的回调
 */
- (void)getNodeItemsWithSuccess:(void (^)(NSMutableArray<WTNodeViewModel *> *nodeVMs))success failure:(void(^)(NSError *error))failure;

/**
 *  加载所有节点数据
 *
 *  @param success 请求成功的回调
 *  @param failure 请求失败的回调
 */
+ (void)loadAllNodeItemsWithSuccess:(void (^)(NSMutableArray<WTNodeViewModel *> *nodeVMs))success failure:(void(^)(NSError *error))failure;

+ (NSMutableArray *)queryAllNodeItemsFromCache;

@end
