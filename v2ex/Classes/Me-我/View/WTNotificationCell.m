//
//  WTNotificationCell.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/2/26.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTNotificationCell.h"
#import "WTTopicViewModel.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Extension.h"

@interface WTNotificationCell()
/** 头像 */
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
/** 标题 */
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
/** 正文的背景View */
@property (weak, nonatomic) IBOutlet UIView *bgContentView;
/** 正文 */
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
/** 时间 */
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@end
@implementation WTNotificationCell

- (void)awakeFromNib
{
    self.bgContentView.backgroundColor = [UIColor colorWithHexString: @"#f5f5f5"];
    self.bgContentView.layer.cornerRadius = 3;
}

- (void)setTopicViewModel:(WTTopicViewModel *)topicViewModel
{
    _topicViewModel = topicViewModel;
    
    [self.iconImageView sd_setImageWithURL: topicViewModel.iconURL placeholderImage: WTIconPlaceholderImage];
    
    self.titleLabel.text = topicViewModel.topic.title;
    
    self.contentLabel.text = topicViewModel.topic.content;
    
    self.timeLabel.text = [topicViewModel.topic.lastReplyTime stringByReplacingOccurrencesOfString: @" " withString: @""];
}

@end
