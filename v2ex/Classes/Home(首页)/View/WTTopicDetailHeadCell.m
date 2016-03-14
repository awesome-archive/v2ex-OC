//
//  WTTopicDetailHeadCell.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/3/13.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTTopicDetailHeadCell.h"
#import "UIImageView+WebCache.h"
#import "WTTopicDetailViewModel.h"
@interface WTTopicDetailHeadCell()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *createTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *nodeLabel;

@end
@implementation WTTopicDetailHeadCell

- (void)awakeFromNib
{
    self.nodeLabel.layer.cornerRadius = 3;
    self.nodeLabel.layer.masksToBounds = YES;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setTopicDetailVM:(WTTopicDetailViewModel *)topicDetailVM
{
    _topicDetailVM = topicDetailVM;
    
    [self.iconImageView sd_setImageWithURL: topicDetailVM.iconURL placeholderImage: WTIconPlaceholderImage];
    
    self.authorLabel.text = topicDetailVM.topicDetail.author;
    
    self.createTimeLabel.text = topicDetailVM.createTimeText;
    
    self.titleLabel.text = topicDetailVM.topicDetail.title;
    
    self.nodeLabel.text = topicDetailVM.nodeText;
}

@end
