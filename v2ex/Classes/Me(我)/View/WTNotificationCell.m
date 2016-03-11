//
//  WTNotificationCell.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/2/26.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTNotificationCell.h"
#import "WTNotification.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Extension.h"
@interface WTNotificationCell()
/** 头像 */
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
/** 标题 */
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
/** 正文 */
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
/** 时间 */
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@end
@implementation WTNotificationCell

- (void)setNotification:(WTNotification *)notification
{
    _notification = notification;
    
    [self.iconImageView sd_setImageWithURL: notification.user.icon placeholderImage: WTIconPlaceholderImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        self.iconImageView.image = [image roundImage];
    }];
    
    self.titleLabel.text = notification.topic.title;
    
    self.contentLabel.text = notification.replyContent;
    
    self.timeLabel.text = notification.topic.lastReplyTime;
}

@end
