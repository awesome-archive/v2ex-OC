//
//  WTTopicDetailCommentCell.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/3/13.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTTopicDetailCommentCell.h"
#import "UIImageView+WebCache.h"
#import "WTTopicDetailViewModel.h"
@interface WTTopicDetailCommentCell()
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *createTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *floorLabel;

@end

@implementation WTTopicDetailCommentCell

- (void)awakeFromNib
{
    [self.iconImageView addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(iconImageViewClick)]];
    self.iconImageView.userInteractionEnabled = YES;
}

- (void)setTopicDetailVM:(WTTopicDetailViewModel *)topicDetailVM
{
    _topicDetailVM = topicDetailVM;
    
    [self.iconImageView sd_setImageWithURL: topicDetailVM.iconURL placeholderImage: WTIconPlaceholderImage];
    
    self.authorLabel.text = topicDetailVM.topicDetail.author;
    
    self.createTimeLabel.text = topicDetailVM.topicDetail.createTime;
    
    self.contentLabel.text = topicDetailVM.topicDetail.content;
    
    self.floorLabel.text = topicDetailVM.floorText;
}

#pragma mark - 事件
- (void)iconImageViewClick
{
    
}

@end
