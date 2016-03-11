//
//  WTBlogDetailViewController.h
//  v2ex
//
//  Created by 无头骑士 GJ on 16/1/17.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WTTopic;
@interface WTTopicDetailViewController : UIViewController
/** 话题模型 */
@property (nonatomic, strong) WTTopic           *topic;

/**
 *  更新页数的Block
 */
@property (nonatomic, strong) void(^updatePageBlock)(NSUInteger index);

@end
