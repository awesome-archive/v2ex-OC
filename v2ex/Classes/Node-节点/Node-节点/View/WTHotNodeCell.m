//
//  WTHotNodeCell.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/7/21.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTHotNodeCell.h"
#import "WTNodeItem.h"
#import "UIFont+Extension.h"

@interface WTHotNodeCell()
/** 标题Label */
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end
@implementation WTHotNodeCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.titleLabel.font = [UIFont systemFontOfSize: 15];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    
//    self.contentView.backgroundColor = WTRandomColor;
}

- (void)setNodeItem:(WTNodeItem *)nodeItem
{
    _nodeItem = nodeItem;
    
    self.titleLabel.text = nodeItem.title;
}

@end
