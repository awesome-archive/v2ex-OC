//
//  WTNodeTopicHeaderView.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/7/23.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTNodeTopicHeaderView.h"
#import "WTNodeItem.h"
#import "WTURLConst.h"

#import "UIImageView+WebCache.h"

@interface WTNodeTopicHeaderView()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *footerLabel;
@property (weak, nonatomic) IBOutlet UILabel *createdLabel;
@property (weak, nonatomic) IBOutlet UILabel *starsLabel;
@property (weak, nonatomic) IBOutlet UILabel *topicsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageV;

@end
@implementation WTNodeTopicHeaderView

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor clearColor];

    self.avatarImageV.layer.cornerRadius = self.avatarImageV.width * 0.5;
    self.avatarImageV.layer.masksToBounds = YES;
}

+ (instancetype)nodeTopicHeaderView
{
    return [[NSBundle mainBundle] loadNibNamed: @"WTNodeTopicHeaderView" owner: nil options: nil].lastObject;
}

- (void)setNodeItem:(WTNodeItem *)nodeItem
{
    _nodeItem = nodeItem;
    
    self.titleLabel.text = nodeItem.title;
    if (nodeItem.header.length > 0)
    {
        self.footerLabel.text = nodeItem.header;
    }
    else
    {
        self.footerLabel.text = nodeItem.footer;
    }
    self.createdLabel.text = nodeItem.created;
    self.starsLabel.text = [NSString stringWithFormat: @"%ld", nodeItem.stars];
    self.topicsLabel.text = [NSString stringWithFormat: @"%ld", nodeItem.topics];
    [self.avatarImageV sd_setImageWithURL: [NSURL URLWithString: [NSString stringWithFormat: @"%@%@", WTHTTP, nodeItem.avatar_large]]];
}

- (IBAction)collectionBtnClick:(UIButton *)sender
{
    
}

@end
