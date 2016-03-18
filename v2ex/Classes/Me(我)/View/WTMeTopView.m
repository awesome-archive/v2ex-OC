//
//  WTMeTopView.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/2/24.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTMeTopView.h"
#import "WTUser.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Extension.h"
#import "WTAccount.h"
@interface WTMeTopView ()
/** 头像 */
@property (weak, nonatomic) IBOutlet UIImageView    *iconImageView;
/** 用户名 */
@property (weak, nonatomic) IBOutlet UILabel        *usernameLabel;
/** 加入时间 */
@property (weak, nonatomic) IBOutlet UILabel        *joinTimeLabel;
/** 加入排名 */
//@property (weak, nonatomic) IBOutlet UILabel        *joinRankLabel;
/** 活跃排名 */
//@property (weak, nonatomic) IBOutlet UILabel        *activeRankLabel;



@end
@implementation WTMeTopView

- (void)awakeFromNib
{
    self.signButton.layer.cornerRadius = 3;
    self.signButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.signButton.layer.borderWidth = 1;
    self.signButton.hidden = YES;
    
    [self.signButton addTarget: self action: @selector(signBtnClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)signBtnClick
{
    WTLog(@"signBtnClick")
}

- (void)setUser:(WTUser *)user
{
    _user = user;
    
    // 头像
    [self.iconImageView sd_setImageWithURL: user.icon placeholderImage: WTIconPlaceholderImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        self.iconImageView.image = [image roundImage];
        
    }];
    
    // 用户名
    self.usernameLabel.text = user.username;
    
    // 加入时间
    self.joinTimeLabel.text = user.joinTime;
    
    // 加入排名
    //self.joinRankLabel.text = [NSString stringWithFormat: @"NO.%@", user.joinRank];
    
    // 是否是登录用户
    if (user.isLoginUser)
    {
        // 领取过奖励
//        if ([WTAccount shareAccount].isReceiveAwards) {
//            self.signButton.hidden = YES;
//        }
//        else
//        {
//            self.signButton.hidden = NO;
//        }
    }
    
}

#pragma mark - 点击事件
- (IBAction)signButtonClick:(UIButton *)sender
{
    if ([self.delegate respondsToSelector: @selector(meTopViewDidClickedSignButton:)]) {
        [self.delegate meTopViewDidClickedSignButton: self];
    }
    self.signButton.hidden = YES;
}

/**
 *  签到成功
 */
- (void)signSuccess
{
    self.signButton.selected = YES;
    self.signButton.userInteractionEnabled = YES;
}
@end
