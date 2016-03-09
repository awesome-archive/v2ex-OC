//
//  WTPostReplyViewController.h
//  v2ex
//
//  Created by 无头骑士 GJ on 16/2/27.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WTPostReplyViewController : UIViewController
/** 回复帖子必须属性 */
@property (nonatomic, strong) NSString              *once;
/** 请求的URL */
@property (nonatomic, strong) NSString              *urlString;
/** 是否回复成功的回调 */
@property (nonatomic, strong) void(^completionBlock)(BOOL isSuccess);
@end
