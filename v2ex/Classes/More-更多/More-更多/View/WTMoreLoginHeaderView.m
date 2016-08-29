//
//  WTMoreLoginHeaderView.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/7/27.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTMoreLoginHeaderView.h"

#import "WTAccount.h"

#import "UIImageView+WebCache.h"
@interface WTMoreLoginHeaderView ()
@property (weak, nonatomic) IBOutlet UIView *avatarbgView1;
@property (weak, nonatomic) IBOutlet UIView *avatarbgView2;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageV;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *bioLabel;

@property (weak, nonatomic) IBOutlet UIView *onlineView;


@end

@implementation WTMoreLoginHeaderView

+ (instancetype)moreLoginHeaderView
{
    return [[NSBundle mainBundle] loadNibNamed: @"WTMoreLoginHeaderView" owner: nil options: nil].lastObject;
}

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor clearColor];
    self.onlineView.layer.cornerRadius = self.onlineView.width * 0.5;
    self.avatarbgView1.layer.cornerRadius = self.avatarbgView1.width * 0.5;
    self.avatarbgView2.layer.cornerRadius = self.avatarbgView2.width * 0.5;
    self.avatarImageV.layer.cornerRadius = self.avatarImageV.width * 0.5;
    self.avatarImageV.layer.masksToBounds = YES;
}

- (void)setAccount:(WTAccount *)account
{
    _account = account;
    
    self.usernameLabel.text = account.usernameOrEmail;
    self.bioLabel.text = account.signature;
    [self.avatarImageV sd_setImageWithURL: account.avatarURL placeholderImage: WTIconPlaceholderImage];
}

@end
