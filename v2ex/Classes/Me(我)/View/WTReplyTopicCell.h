//
//  WTReplyCell.h
//  v2ex
//
//  Created by 无头骑士 GJ on 16/2/27.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WTTopic;
@interface WTReplyTopicCell : UITableViewCell
/** 话题模型 */
@property (nonatomic, strong) WTTopic   *topic;

@end
