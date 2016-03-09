//
//  WTCommentCell.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/2/18.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTCommentCell.h"
#import "WTTopicDetail.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Extension.h"
#import "TYAttributedLabel.h"
#import "Masonry.h"
#import "NSString+Regex.h"
#import "NSString+YYAdd.h"
#import "WTURLConst.h"
#import "UIDevice+YYAdd.h"
@interface WTCommentCell() <TYAttributedLabelDelegate>
/** 头像*/
@property (weak, nonatomic) IBOutlet UIImageView            *iconImageView;
/** 作者 */
@property (weak, nonatomic) IBOutlet UILabel                *authorLabel;
/** 创建时间 */
@property (weak, nonatomic) IBOutlet UILabel                *createTimeLabel;
/** 回复正文内容 */
@property (weak, nonatomic) IBOutlet UILabel                *contentLabel;
/** 楼层 */
@property (weak, nonatomic) IBOutlet UILabel                *floorLabel;
/** markdown正文 */
@property (nonatomic, weak) TYAttributedLabel               *markdownLabel;

@end
@implementation WTCommentCell

- (void)awakeFromNib
{
    // 1、为头像添加点击手势
    self.iconImageView.userInteractionEnabled = YES;
    [self.iconImageView addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(iconTap)]];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

#pragma mark - 事件
- (void)iconTap
{
    if ([self.delegate respondsToSelector: @selector(commentCell:DidClickedIconWithTopicDetail:)])
    {
        [self.delegate commentCell: self DidClickedIconWithTopicDetail: self.topicDetail];
    }
}

- (void)setTopicDetail:(WTTopicDetail *)topicDetail
{
    _topicDetail = topicDetail;
    
    // 头像
    [self.iconImageView sd_setImageWithURL: topicDetail.icon placeholderImage: WTIconPlaceholderImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        self.iconImageView.image = [image roundImage];
    }];

    // 作者
    self.authorLabel.text = topicDetail.author;
    
    // 创建时间和来源
    self.createTimeLabel.text = topicDetail.createTime;
    
    // 楼层
    self.floorLabel.text = [NSString stringWithFormat: @"# %zd", topicDetail.floor];
    
    // 回复正文内容
    //self.contentLabel.text = topicDetail.content;
    [self parseContent];
}

- (void)parseContent
{
    self.markdownLabel.textContainer = nil;
    
    TYTextContainer *textContainer = [[TYTextContainer alloc] init];
    
    HTMLParser *parser = [[HTMLParser alloc] initWithString: self.topicDetail.content error: nil];
    
    HTMLNode *replyContentNode =  [[parser body] findChildOfClass: @"reply_content"];
 
    NSString *content = replyContentNode.rawContents;
    NSRange normalTextStart = [content rangeOfString: @"reply_content\">"];
    NSRange normalTextEnd = [content rangeOfString: @"</div>"];
    NSUInteger startLocation = normalTextStart.location + normalTextStart.length;
    NSString *normalText = [content substringWithRange: NSMakeRange(startLocation, normalTextEnd.location - startLocation)];
    
    TYTextStorage *textStore = [[TYTextStorage alloc] init];
    
    
    // 纯文本
    if ([normalText isEqualToString: replyContentNode.allContents])
    {
        NSArray *normalChildren = [replyContentNode children];
        for (HTMLNode *normalChild in normalChildren)
        {
            WTLog(@"normalChild:%@", normalChild.rawContents);
            textStore.text = normalChild.rawContents;
            [textContainer appendTextStorage: textStore];
        }
    }
    
    else
    {
        content = [content stringByReplacingOccurrencesOfString: @"<div class=\"reply_content\">" withString: @""];
        content = [content stringByReplacingOccurrencesOfString: @"</div>" withString: @""];
        NSArray *brStrs = [content componentsSeparatedByString: @"<br>"];
        if (brStrs.count > 0)
        {
            // 检查 0 ~ count-1 的节点
            for (NSString *brStr in brStrs)
            {
                if (![brStr isNotBlank])
                {
                    textStore.text = @"\n";
                    [textContainer appendTextStorage: textStore];
                    continue;
                }

                if ([brStr containsString: @"<a"]) // 可能存在链接
                {
                    NSArray *aNodes = [brStr componentsSeparatedByString: @"<a"];
                    NSString *prevText = nil;
                    for (NSString *aNode in aNodes)
                    {
                        if ([aNode containsString: @"<div>"])
                        {
                            continue;
                        }
                        
                        if (![aNode containsString: @"href"]) {
                            prevText = aNode;
                            if ([aNode isEqualToString: @"@"])
                            {
                                continue;
                            }
                            
                            textStore.text = aNode;
                            [textContainer appendTextStorage: textStore];

                            continue;
                        }
                        else
                        {
                            // 提取  target="_blank" href="http://www.abc.com" rel="nofollow">www.abc.com</a> 中 www.abc.com
                            NSRange hrefStrStartRange = [aNode rangeOfString: @">"];
                            NSUInteger hrefStrStartLocation = hrefStrStartRange.location + hrefStrStartRange.length;
                            NSRange hrefStrEndRange = [aNode rangeOfString: @"</a>"];
                            NSString *hrefStr = [aNode substringWithRange: NSMakeRange(hrefStrStartLocation, hrefStrEndRange.location - hrefStrStartLocation)];

                            // 提取 href
                            NSRange hrefStartRange = [aNode rangeOfString: @"href=\""];
                            NSUInteger hrefStartLocation = hrefStartRange.location + hrefStartRange.length;
                            
                            NSRange hrefEndRange;
                            NSString *href = nil;
                //            hrefEndRange = [aNode rangeOfString: @"\">"];
                            if ([prevText isEqualToString: @"@"])
                            {
                                hrefEndRange = [aNode rangeOfString: @"\">"];
                                hrefStr = [NSString stringWithFormat: @"@%@", hrefStr];
                            }
                            else if([aNode containsString: @" rel"])
                            {
                                hrefEndRange = [aNode rangeOfString: @"\" rel"];
                            }
                            else
                            {
                                hrefEndRange = [aNode rangeOfString: @"\">"];
                            }
                            href = [NSString stringWithFormat: @"%@", [aNode substringWithRange: NSMakeRange(hrefStartLocation, hrefEndRange.location - hrefStartLocation)]];
                            href = [href containsString: @"http:"] ? href : [WTHTTPBaseUrl stringByAppendingPathComponent: href];
                            [textContainer appendLinkWithText: hrefStr linkFont: [UIFont systemFontOfSize: 12] linkColor: [UIColor colorWithHexString: @"#c0c0c0"] underLineStyle: kCTUnderlineStyleNone linkData: href];
                        
                            
                            NSUInteger hrefStrEndLocation = hrefStrEndRange.location + hrefStrEndRange.length;
                            if (hrefStrEndLocation != aNode.length)
                            {
                                NSString *lastText = [aNode substringWithRange: NSMakeRange(hrefStrEndLocation, aNode.length - hrefStrEndLocation)];
                                
                                lastText = [lastText stringByReplacingRegex: @"<button.*</button>" options: NSRegularExpressionCaseInsensitive withString: @""];
                                lastText = [lastText stringByReplacingOccurrencesOfString: @"<div>" withString: @""];
                                textStore.text = lastText;
                                [textContainer appendTextStorage: textStore];
                            }
                        
                        }
                        prevText = nil;
                    }
                    continue;
                }
                // http://ww2.sinaimg.cn/large/6714a3e0gw1f1pc5ok66kj202y047weh.jpg 解析图片
                if ([brStr containsString: @"<img"])
                {
                    NSRange srcStartRange = [brStr rangeOfString: @"src=\""];
                    NSUInteger srcStartLocation = srcStartRange.location + srcStartRange.length;
                    
                    NSRange srcEndRange = [brStr rangeOfString: @"\" class"];
                    NSString *srcStr = [brStr substringWithRange: NSMakeRange(srcStartLocation, srcEndRange.location - srcStartLocation)];
                    
                    TYImageStorage *imageUrlStorage = [[TYImageStorage alloc] init];
                    
                    NSURL *imageUrl = [NSURL URLWithString: srcStr];
                    imageUrlStorage.imageURL = imageUrl;
                    imageUrlStorage.placeholdImageName = @"icon_placeholder";
                    imageUrlStorage.size            = CGSizeMake(374, 200);
                    imageUrlStorage.imageAlignment  = TYImageAlignmentLeft;
                    [textContainer appendTextStorage: imageUrlStorage];
                    
                    continue;
                }
                textStore.text = brStr;
                [textContainer appendTextStorage: textStore];
            }
        }
    }

    textStore.text = @"";
    [textContainer appendTextStorage: textStore];
    textContainer = [textContainer createTextContainerWithTextWidth: WTScreenWidth - 2 * WTMargin - CGRectGetMaxX(self.iconImageView.frame)];
    self.markdownLabel.textContainer = textContainer;
}

- (TYAttributedLabel *)markdownLabel
{
    if (_markdownLabel == nil)
    {
        TYAttributedLabel *markdownLabel = [[TYAttributedLabel alloc] init];
        [self.contentView addSubview: markdownLabel];
        _markdownLabel = markdownLabel;
        
        // 代理
        markdownLabel.delegate = self;
        
        // 布局
        [markdownLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.iconImageView.mas_right).offset(WTMargin);
            make.right.mas_equalTo(-WTMargin);
            make.top.mas_equalTo(self.authorLabel.mas_bottom).offset(WTMargin);
            make.bottom.mas_equalTo(-WTMargin);
        }];
    }
    return _markdownLabel;
}

#pragma mark - TYAttributedLabelDelegate
- (void)attributedLabel:(TYAttributedLabel *)attributedLabel textStorageClicked:(id<TYTextStorageProtocol>)TextRun atPoint:(CGPoint)point
{
    WTLog(@"textStorageClickedAtPoint");
    if ([TextRun isKindOfClass:[TYLinkTextStorage class]])
    {
        
        NSString *linkStr = ((TYLinkTextStorage*)TextRun).linkData;
        
        if ([linkStr hasPrefix:@"http:"] || [linkStr hasPrefix: @"https:"]) // 点击了链接
        {
            if ([UIDevice systemVersion] >= 9.0)
            {
//                if ([self.delegate respondsToSelector: @selector(topicDetailTopCell:DidClickedTextLabelWithType:info:)])
//                {
//                    [self.delegate topicDetailTopCell: self DidClickedTextLabelWithType: TextLabelTypeLink info: @{@"linkUrl" : linkStr}];
//                }
                WTLog(@"linkStr:%@", linkStr)
                return;
            }
            
            [[ UIApplication sharedApplication] openURL:[ NSURL URLWithString:linkStr]];
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"点击提示" message:linkStr delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
        }
    }
    else if ([TextRun isKindOfClass:[TYImageStorage class]]) // 点击了图片
    {
//        NSURL *clickImageUrl = ((TYImageStorage*)TextRun).imageURL;
//        if ([self.delegate respondsToSelector: @selector(topicDetailTopCell:DidClickedTextLabelWithType:info:)])
//        {
//            [self.delegate topicDetailTopCell: self DidClickedTextLabelWithType: TextLabelTypeImage info: @{@"imageUrls" : self.imageUrls, @"clickImageUrl" : clickImageUrl}];
//        }
        
    }
}
@end
