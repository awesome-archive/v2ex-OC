//
//  WTBlogCell.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/1/14.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTTopicCell.h"
#import "UIImageView+WebCache.h"
#import "WTTopic.h"
#import "UILabel+StringFrame.h"
#import "NSString+Regex.h"
#import "UIImage+Extension.h"
NS_ASSUME_NONNULL_BEGIN
@interface WTTopicCell ()

/** 头像 */
@property (weak, nonatomic) IBOutlet UIImageView            *iconImageV;
/** 标题 */
@property (weak, nonatomic) IBOutlet UILabel                *titleLabel;
/** 节点名称 */
@property (weak, nonatomic) IBOutlet UIButton               *nodeBtn;
/** 最后回复时间 */
@property (weak, nonatomic) IBOutlet UILabel                *lastReplyTimeLabel;
/** 作者*/
@property (weak, nonatomic) IBOutlet UILabel                *authorLabel;


@end

@implementation WTTopicCell


/**
 *  快速创建的类方法
 *
 *  @param tableView tableView
 *
 *  @return WTBlogCell
 */
+ (instancetype)cellWithTableView:(UITableView * _Nonnull)tableView
{
    static NSString *ID = @"topicCell";
    WTTopicCell *cell = [tableView dequeueReusableCellWithIdentifier: ID];
    
    if (cell == nil)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed: @"WTTopicCell" owner: nil options: nil] lastObject];
    }
    return cell;
}

- (void)awakeFromNib
{
    // 2、节点
    self.nodeBtn.layer.cornerRadius = 1.5;
}

// 重写 blog set方法，初始化数据
- (void)setTopic:(WTTopic *)topic
{
    _topic = topic;
    
    // 设置数据
    [self setUpData];
    
    // 设置属性
    [self setUpView];
}

#pragma mark - 设置数据
- (void)setUpData
{
    // 1、头像
    [self.iconImageV sd_setImageWithURL: _topic.icon placeholderImage: WTIconPlaceholderImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        self.iconImageV.image = [image roundImage];
    }];
    
    // 2、标题
    self.titleLabel.text = _topic.title;
    
    // 3、节点
    NSString *node = _topic.node;
    // 判断是否包含中文字符串
    if ([NSString isChineseCharactersWithString: node] || node.length > 4)
    {
        //NSLog(@"中文:%@", _blog.node);
        node = [NSString stringWithFormat: @" %@ ", _topic.node];
    }
    [self.nodeBtn setTitle: node forState: UIControlStateNormal];
    
    // 4、最后回复时间
    self.lastReplyTimeLabel.text = _topic.lastReplyTime;
    
    // 6、作者
    self.authorLabel.text = _topic.author;
}

#pragma mark - 设置属性
- (void)setUpView
{
    [self.authorLabel adjustFontSizeToFillItsContents];
}
@end
NS_ASSUME_NONNULL_END
