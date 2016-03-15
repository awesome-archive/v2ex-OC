//
//  WTReplyCell.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/2/27.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTReplyTopicCell.h"
#import "WTTopicViewModel.h"
@interface WTReplyTopicCell()
/** 标题 */
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
/** 回复内容 */
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
/** 作者 */
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
/** 回复时间 */
@property (weak, nonatomic) IBOutlet UILabel *lastReplyTimeLabel;
/** 背景View */
@property (weak, nonatomic) IBOutlet UIView  *bgView;

@end
@implementation WTReplyTopicCell

- (void)awakeFromNib
{
    self.bgView.layer.cornerRadius = 8;
    self.bgView.layer.masksToBounds = YES;
}

- (void)setTopicViewModel:(WTTopicViewModel *)topicViewModel
{
    _topicViewModel = topicViewModel;
    
    WTTopicNew *topic = topicViewModel.topic;
    
    self.titleLabel.text = topic.title;
    self.contentLabel.text = topic.content;
    self.authorLabel.text = topic.author;
    self.lastReplyTimeLabel.text = topic.lastReplyTime;
}

@end
