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
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *nodeLabel;

@property (weak, nonatomic) IBOutlet UILabel *createTimeLabel;

@end
@implementation WTUserTopicCell

- (void)setTopicViewModel:(WTTopicViewModel *)topicViewModel
{
    _topicViewModel = topicViewModel;
    
    self.titleLabel.text = topicViewModel.topic.title;
    
    self.nodeLabel.text = topicViewModel.topic.node;
    
    self.createTimeLabel.text = topicViewModel.topic.lastReplyTime;
}



@end
