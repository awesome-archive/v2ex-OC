//
//  WTUserTopicViewController.h
//  v2ex
//
//  Created by 无头骑士 GJ on 16/3/21.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTPersonTableViewController.h"

@interface WTUserTopicViewController : WTPersonTableViewController
/** url地址 */
@property (nonatomic, strong) NSString          *urlString;
/** 请求数据完成的回调 */
@property (nonatomic, copy) void(^completionBlock)();
@end
