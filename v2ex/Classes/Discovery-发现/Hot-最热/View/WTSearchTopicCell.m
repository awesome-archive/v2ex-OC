//
//  WTSearchTopicCell.m
//  v2ex
//
//  Created by 无头骑士 GJ on 2017/7/9.
//  Copyright © 2017年 无头骑士 GJ. All rights reserved.
//

#import "WTSearchTopicCell.h"

#import "WTSearchTopic.h"

@interface WTSearchTopicCell()
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end
@implementation WTSearchTopicCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.timeLabel.textColor = [UIColor blackColor];
    
    self.detailLabel.textColor = WTColor(118, 118, 118);
    
    self.timeLabel.textColor = WTColor(140, 140, 140);
}

- (void)setSearchTopic:(WTSearchTopic *)searchTopic
{
    _searchTopic = searchTopic;

    self.titleLabel.text = searchTopic.title;
    
    self.detailLabel.text = searchTopic.detail;
    
    self.timeLabel.text = searchTopic.published_time;
}

@end
