//
//  WTMeAllTopicCell.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/2/26.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTUserTopicCell.h"
#import "WTTopicViewModel.h"
@interface WTUserTopicCell()
// 标题
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
// 节点
@property (weak, nonatomic) IBOutlet UILabel *nodeLabel;
// 创建时间
@property (weak, nonatomic) IBOutlet UILabel *createTimeLabel;

@end
@implementation WTUserTopicCell

- (void)setTopicViewModel:(WTTopicViewModel *)topicViewModel
{
    _topicViewModel = topicViewModel;
    
    // 标题
    self.titleLabel.text = topicViewModel.topic.title;
    // 节点
    self.nodeLabel.text = topicViewModel.topic.node;
    // 创建时间
    self.createTimeLabel.text = topicViewModel.topic.lastReplyTime;
}



@end
