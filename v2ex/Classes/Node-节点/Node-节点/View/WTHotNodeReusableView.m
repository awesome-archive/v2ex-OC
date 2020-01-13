//
//  WTHotNodeReusableView.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/7/21.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTHotNodeReusableView.h"
@interface WTHotNodeReusableView()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;


@end
@implementation WTHotNodeReusableView

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.backgroundColor = [UIColor whiteColor];
    
    self.titleLabel.textColor = [UIColor colorWithHexString: @"#494949"];
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    
    self.titleLabel.text = title;
}

@end
