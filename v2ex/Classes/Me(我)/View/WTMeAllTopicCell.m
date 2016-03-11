//
//  WTMeAllTopicCell.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/2/26.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTMeAllTopicCell.h"
#import "WTTopic.h"
@interface WTMeAllTopicCell()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *nodeLabel;

@property (weak, nonatomic) IBOutlet UILabel *createTimeLabel;

@end
@implementation WTMeAllTopicCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setTopic:(WTTopic *)topic
{
    _topic = topic;
    
    self.titleLabel.text = topic.title;
    
    self.nodeLabel.text = topic.node;
    
    self.createTimeLabel.text = topic.createTime;
}



@end
