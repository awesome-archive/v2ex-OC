//
//  WTNotificationCell.h
//  v2ex
//
//  Created by 无头骑士 GJ on 16/2/26.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WTTopicViewModel;
@interface WTNotificationCell : UITableViewCell
/** 回复消息模型 */
@property (nonatomic, strong) WTTopicViewModel *topicViewModel;

@end
