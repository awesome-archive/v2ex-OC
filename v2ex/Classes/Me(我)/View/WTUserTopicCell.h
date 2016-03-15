//
//  WTMeAllTopicCell.h
//  v2ex
//
//  Created by 无头骑士 GJ on 16/2/26.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WTTopicViewModel;
@interface WTUserTopicCell : UITableViewCell

/** 话题模型 */
@property (nonatomic, strong) WTTopicViewModel       *topicViewModel;

@end
