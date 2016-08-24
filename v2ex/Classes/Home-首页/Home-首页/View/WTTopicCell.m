//
//  WTBlogCell.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/1/14.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTTopicCell.h"

#import "WTTopic.h"

#import "UILabel+StringFrame.h"
#import "NSString+Regex.h"
#import "UIImage+Extension.h"

#import "UIImageView+WebCache.h"

NS_ASSUME_NONNULL_BEGIN

@interface WTTopicCell ()

/** 头像*/
@property (weak, nonatomic) IBOutlet UIImageView            *iconImageV;
/** 标题 */
@property (weak, nonatomic) IBOutlet UILabel                *titleLabel;
/** 节点 */
@property (weak, nonatomic) IBOutlet UIButton               *nodeBtn;
/** 最后回复时间 */
@property (weak, nonatomic) IBOutlet UILabel                *lastReplyTimeLabel;
/** 作者 */
@property (weak, nonatomic) IBOutlet UILabel                *authorLabel;
/** 回复数 */
@property (weak, nonatomic) IBOutlet UIImageView            *commentCountImageView;
/** 回复数 */
@property (weak, nonatomic) IBOutlet UILabel                *commentCountLabel;
/** 节点宽度约束 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint     *nodeBtnWidthLayoutCons;
/** 最后回复时间的leading距离 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint     *lastReplyTimeLabelLeadingLayoutCons;

@end
@implementation WTTopicCell

- (void)awakeFromNib
{
    // 2、节点
    self.nodeBtn.layer.cornerRadius = 1.5;
    self.iconImageV.layer.cornerRadius = 5;
    self.iconImageV.layer.masksToBounds = YES;
}

- (void)setTopic:(WTTopic *)topic
{
    _topic = topic;
    
    // 1、头像
    [self.iconImageV sd_setImageWithURL: topic.iconURL placeholderImage: WTIconPlaceholderImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        self.iconImageV.image = [image roundImageWithCornerRadius: 3];
        self.iconImageV.image = image;
    }];
    
    // 2、标题
    self.titleLabel.text = topic.title;
    
    // 3、节点
    if (topic.node.length > 0)
    {
        //self.nodeBtn.hidden = NO;
        NSString *node = topic.node;
        // 判断是否包含中文字符串
        if ([NSString isChineseCharactersWithString: node] || node.length > 4)
        {
            //NSLog(@"中文:%@", _blog.node);
            node = [NSString stringWithFormat: @" %@ ", topic.node];
        }
        [self.nodeBtn setTitle: node forState: UIControlStateNormal];
        self.lastReplyTimeLabelLeadingLayoutCons.constant = 8;
        [self.nodeBtn sizeToFit];
    }
    else
    {
        self.nodeBtnWidthLayoutCons.constant = 0;
        self.lastReplyTimeLabelLeadingLayoutCons.constant = 0;
        [self.nodeBtn setTitle: @"" forState: UIControlStateNormal];
    }
    
    // 4、最后回复时间
    self.lastReplyTimeLabel.text = topic.lastReplyTime ? topic.lastReplyTime :  @" ";
    
    // 6、作者
    self.authorLabel.text = topic.author;
    
    // 7、评论数
    self.commentCountLabel.text = topic.commentCount;
    self.commentCountImageView.hidden = !(topic.commentCount.length > 0);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.nodeBtn.titleLabel.text.length > 0)
    {
        self.nodeBtnWidthLayoutCons.constant = self.nodeBtn.width;
        self.nodeBtn.height = 15;
    }
}

@end
NS_ASSUME_NONNULL_END
