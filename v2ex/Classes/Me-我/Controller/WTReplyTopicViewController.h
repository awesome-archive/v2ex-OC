//
//  WTReplyViewController.h
//  v2ex
//
//  Created by 无头骑士 GJ on 16/2/27.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTPersonTableViewController.h"

@interface WTReplyTopicViewController : WTPersonTableViewController

/** 用户名 */
@property (nonatomic, strong) NSString          *username;

/** 请求数据完成的回调 */
@property (nonatomic, copy) void(^completionBlock)();
@end
