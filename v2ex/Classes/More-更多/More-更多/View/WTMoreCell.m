//
//  WTMoreCell.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/7/25.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTMoreCell.h"

@implementation WTMoreCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(21, 11.5, 25, 22);
    
    self.textLabel.x = 66.5;
}
@end
