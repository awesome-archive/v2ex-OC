
//
//  WTTopicDetailTopCell.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/3/2.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTTopicDetailTopCell.h"
#import "HTMLParser.h"
#import "HTMLNode.h"
#import "WTTopicDetail.h"
#import "TYAttributedLabel.h"
#import "UIImage+Extension.h"
#import "UIImageView+WebCache.h"
#import "RegexKitLite.h"
#import "Masonry.h"
#import "NSString+Regex.h"
#import "UIDevice+YYAdd.h"
#import "NSString+YYAdd.h"
#import "UIImageView+AFNetworking.h"
#import "WTURLConst.h"
#define WTMargin 8

@interface WTTopicDetailTopCell () <TYAttributedLabelDelegate>
/** 头像 */
@property (weak, nonatomic) IBOutlet UIImageView        *iconImageV;
/** 作者 */
@property (weak, nonatomic) IBOutlet UILabel            *authorLabel;
/** 创建时间 */
@property (weak, nonatomic) IBOutlet UILabel            *createTimeLabel;
/** 节点名称 */
@property (weak, nonatomic) IBOutlet UIButton           *nodeButton;
/** 查看次数 */
@property (weak, nonatomic) IBOutlet UILabel            *seeCountLabel;
/** 标题 */
@property (weak, nonatomic) IBOutlet UILabel            *titleLabel;
/** markdown正文 */
@property (nonatomic, weak) TYAttributedLabel           *markdownLabel;
/** 普通正文 */
//@property (nonatomic, weak) UILabel                     *contentLabel;
/** 图片数组 */
@property (nonatomic, strong) NSMutableArray            *imageUrls;
@end

@implementation WTTopicDetailTopCell

- (void)awakeFromNib
{
    // 查看次数
    self.seeCountLabel.layer.cornerRadius = 3;
    self.seeCountLabel.layer.masksToBounds = YES;
    self.seeCountLabel.backgroundColor = WTColor(170, 176, 199);
    
    // 节点
    self.nodeButton.layer.cornerRadius = 3;
    self.nodeButton.layer.masksToBounds = YES;
    
    self.backgroundColor = [UIColor clearColor];
    
    // 为头像添加点击手势
    self.iconImageV.userInteractionEnabled = YES;
    [self.iconImageV addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(iconImageVClick)]];
    
    // 取消选中效果
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setTopicDetail:(WTTopicDetail *)topicDetail
{
    _topicDetail = topicDetail;
    
    // 头像
    [self.iconImageV sd_setImageWithURL: topicDetail.icon placeholderImage: [UIImage imageNamed: @"Snip20160114_16"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        self.iconImageV.image = [image roundImage];
    }];
    
    // 作者
    self.authorLabel.text = topicDetail.author;
    
    // 创建时间
    self.createTimeLabel.text = topicDetail.createTime;
    
    // 节点名称
    NSString *node = topicDetail.node;
    if ([NSString isChineseCharactersWithString: node] || node.length > 4)
    {
        node = [NSString stringWithFormat: @" %@ ", node];
    }
    [self.nodeButton setTitle: node forState: UIControlStateNormal];

    
    // 标题
    self.titleLabel.text = topicDetail.title;
    
    // 帖子被点击次数
    self.seeCountLabel.text = [NSString stringWithFormat: @" %zd ", topicDetail.seeCount];
    
    // 内容
    if (topicDetail.markdownStr == nil)
    {
        [self parseContent];
    }
    else
    {
        [self parseContentText];
    }
}

/**
 *  解析富文本
 */
- (void)parseContentText
{
    TYTextContainer *textContainer = [[TYTextContainer alloc] init];
    HTMLParser *parser = [[HTMLParser alloc] initWithString: self.topicDetail.markdownStr error: nil];
    
    HTMLNode *markdownNode =  [[parser body] findChildOfClass: @"markdown_body"];
    WTLog(@"markdownNode:%@", markdownNode.rawContents)
    NSString *liBlank = @"";
    for (HTMLNode *htmlNode in markdownNode.children)
    {
        if (![htmlNode.rawContents isNotBlank])
        {
            continue;
        }
        
        if ([htmlNode.rawContents containsString: @"<img"])
        {
            [self parseImageNode: htmlNode textContainer: textContainer];
        }
        else if([htmlNode.rawContents containsString: @"<ul>"])
        {
            [self parseUlCode: htmlNode textContainer: textContainer];
        }
        else if([htmlNode.rawContents containsString: @"<ol>"])
        {
            NSArray *liNodes = [htmlNode findChildTags: @"li"];
            
            NSString *ulStr = @"";
            for (int i = 0; i < liNodes.count; i++)
            {
                HTMLNode *liNode = liNodes[i];
                NSString *liStr = liNode.allContents;
                ulStr = [NSString stringWithFormat: @"%@%@%d.%@\n", ulStr, liBlank, i + 1, liStr];
            }
            
            TYTextStorage *textStore = [[TYTextStorage alloc] init];
            textStore.text = [ulStr stringByAppendingString: @"\n"];
            [textContainer appendTextStorage: textStore];
        }
        else if([htmlNode.rawContents subStringWithRegex: @"<h\\d{1}>"].length > 0)
        {
            [self parseH1ToH6Node: htmlNode textContainer: textContainer];
        }
        else if([htmlNode.rawContents containsString: @"<a"])
        {
            // 解析包含链接节点
            [self parseLinkNode: htmlNode textContainer: textContainer];

        }
        else if([htmlNode.rawContents containsString: @"<p"])
        {
            NSString *pStr = htmlNode.allContents;
            TYTextStorage *textStore = [[TYTextStorage alloc] init];
            textStore.text = [NSString stringWithFormat: @"%@\n\n", [self filterSpecialCharacters: pStr]];
            [textContainer appendTextStorage: textStore];
        }
    }
    textContainer = [textContainer createTextContainerWithTextWidth: WTScreenWidth - 2 * WTMargin];
    self.markdownLabel.textContainer = textContainer;
}

#pragma mark - 事件
- (void)iconImageVClick
{
    if ([self.delegate respondsToSelector: @selector(topicDetailTopCell:DidClickedIconWithTopicDetail:)])
    {
        [self.delegate topicDetailTopCell: self DidClickedIconWithTopicDetail: self.topicDetail];
    }
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
                if ([self.delegate respondsToSelector: @selector(topicDetailTopCell:DidClickedTextLabelWithType:info:)])
                {
                    [self.delegate topicDetailTopCell: self DidClickedTextLabelWithType: TextLabelTypeLink info: @{@"linkUrl" : linkStr}];
                }
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
        NSURL *clickImageUrl = ((TYImageStorage*)TextRun).imageURL;
        if ([self.delegate respondsToSelector: @selector(topicDetailTopCell:DidClickedTextLabelWithType:info:)])
        {
            [self.delegate topicDetailTopCell: self DidClickedTextLabelWithType: TextLabelTypeImage info: @{@"imageUrls" : self.imageUrls, @"clickImageUrl" : clickImageUrl}];
        }

    }
}

#pragma mark - 解析普通文本
- (void)parseContent
{
    self.markdownLabel.textContainer = nil;
    
    TYTextContainer *textContainer = [[TYTextContainer alloc] init];
    
    HTMLParser *parser = [[HTMLParser alloc] initWithString: self.topicDetail.normalContent error: nil];
    
    HTMLNode *replyContentNode =  [[parser body] findChildOfClass: @"topic_content"];
    
    NSString *content = replyContentNode.rawContents;
    NSRange normalTextStart = [content rangeOfString: @"topic_content\">"];
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
        content = [content stringByReplacingOccurrencesOfString: @"<div class=\"topic_content\">" withString: @""];
        content = [content stringByReplacingOccurrencesOfString: @"</div>" withString: @""];
        NSArray *brStrs = [content componentsSeparatedByString: @"<br>"];
        if (brStrs.count > 0)
        {
            // 检查 0 ~ count-1 的节点
            for (NSString *brStr in brStrs)
            {
                if (![brStr isNotBlank])
                {
                    textStore.text = @"\n\n";
                    [textContainer appendTextStorage: textStore];
                    continue;
                }
                if ([brStr containsString: @"<a"]) // 可能存在链接
                {
                    NSArray *aNodes = [brStr componentsSeparatedByString: @"<a"];
                    NSString *prevText = nil;
                    for (NSString *aNode in aNodes)
                    {
                        if (![aNode containsString: @"href"]) {
                            prevText = aNode;
                            if ([aNode isEqualToString: @"@"])
                            {
                                continue;
                            }
                            
                            textStore.text = aNode;
                            [textContainer appendTextStorage: textStore];
                            //                            prevText = aNode;
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
    textContainer = [textContainer createTextContainerWithTextWidth: WTScreenWidth - 2 * WTMargin];
    self.markdownLabel.textContainer = textContainer;
}

#pragma mark - 懒加载
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
            make.left.mas_equalTo(WTMargin);
            make.right.mas_equalTo(-WTMargin);
            make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(WTMargin);
            make.bottom.mas_equalTo(-WTMargin);
        }];
    }
    return _markdownLabel;
}

- (NSMutableArray *)imageUrls
{
    if (_imageUrls == nil)
    {
        _imageUrls = [NSMutableArray array];
    }
    return _imageUrls;
}

#pragma mark - 解析节点
#pragma mark 解析图片节点
- (void)parseImageNode:(HTMLNode *)htmlNode textContainer:(TYTextContainer *)textContainer
{
    HTMLNode *imageNode             = [htmlNode findChildTag: @"img"];
    NSString *src                   = [imageNode getAttributeNamed: @"src"];
    TYImageStorage *imageUrlStorage = [[TYImageStorage alloc] init];
    
    NSURL *imageUrl = [NSURL URLWithString: src];
    imageUrlStorage.imageURL = imageUrl;
    imageUrlStorage.placeholdImageName = @"icon_placeholder";
    imageUrlStorage.size            = CGSizeMake(374, 200);
    [textContainer appendTextStorage: imageUrlStorage];
    
    
    TYTextStorage *textStorage = [[TYTextStorage alloc] init];
    textStorage.text = @"\n\n";
    [textContainer appendTextStorage: textStorage];
    

    // 添加图片数组中
    [self.imageUrls addObject: imageUrl];
}

#pragma mark 解析包含链接的节点
- (void)parseLinkNode:(HTMLNode *)htmlNode textContainer:(TYTextContainer *)textContainer
{
    NSString *rawContentStr = htmlNode.rawContents;
    NSArray *rawContentArr  = [rawContentStr componentsSeparatedByString: @"</br>"];
    
    for (NSString *rawContent in rawContentArr)
    {
        NSArray *aStrs = [rawContent componentsSeparatedByString: @"<a"];
        
        for (NSString *aStr in aStrs)
        {
            NSString *text = nil;
            if (![aStr containsString: @"</a>"])
            {
                text = [aStr stringByReplacingOccurrencesOfString: @"<p>" withString: @""];
            }
            else
            {
                // 获取链接的文字
                NSRange hrefStrStartRange   = [aStr rangeOfString: @"\">"];
                NSRange hrefStrEndRange     = [aStr rangeOfString: @"</a>"];
                NSString *hrefStr           = [aStr substringWithRange: NSMakeRange(hrefStrStartRange.location + hrefStrStartRange.length, hrefStrEndRange.location - hrefStrStartRange.location - 2)];
                
                // 获取链接URL
                NSRange hrefStartRange = [aStr rangeOfString: @"href=\""];
                NSRange hrefEndRange   = [aStr rangeOfString: @"\">"];
                NSUInteger hrefStart   = hrefStartRange.location + hrefStartRange.length;
                NSString *href         = [aStr substringWithRange: NSMakeRange(hrefStart, hrefEndRange.location - hrefStart)];
                
                [textContainer appendLinkWithText: hrefStr linkFont: [UIFont systemFontOfSize: 12] linkColor: [UIColor colorWithHexString: @"#c0c0c0"] underLineStyle: kCTUnderlineStyleNone linkData: href];
                
                text = [aStr substringFromIndex: hrefStrEndRange.location + hrefStrEndRange.length];
                text = [text stringByReplacingOccurrencesOfString: @"</p>" withString: @""];
            }
            TYTextStorage *textStore = [[TYTextStorage alloc] init];
            textStore.text           = [self filterSpecialCharacters: text];
            [textContainer appendTextStorage: textStore];
        }
        
        TYTextStorage *textStore = [[TYTextStorage alloc] init];
        textStore.text = @" \n\n";
        [textContainer appendTextStorage: textStore];
    }
}

#pragma mark 解析h1~h6节点
- (void)parseH1ToH6Node:(HTMLNode *)htmlNode textContainer:(TYTextContainer *)textContainer
{
    TYTextStorage *textStore = [[TYTextStorage alloc] init];
    textStore.text           = [NSString stringWithFormat: @"%@", [self filterSpecialCharacters: htmlNode.allContents]];
    
    NSString *rawContens = htmlNode.rawContents;
    if ([rawContens containsString: @"h1"])
    {
        textStore.font = [UIFont systemFontOfSize: 18];
    }
    if ([rawContens containsString: @"h2"])
    {
        textStore.font = [UIFont systemFontOfSize: 17];
    }
    if ([rawContens containsString: @"h3"])
    {
        textStore.font = [UIFont systemFontOfSize: 16];
    }
    if ([rawContens containsString: @"h4"])
    {
        textStore.font = [UIFont boldSystemFontOfSize: 15];
    }
    if ([rawContens containsString: @"h5"])
    {
        textStore.font = [UIFont boldSystemFontOfSize: 14];
    }
    if ([rawContens containsString: @"h6"])
    {
        textStore.font = [UIFont boldSystemFontOfSize: 13];
    }

    textStore.font = [UIFont systemFontOfSize: 16];
    [textContainer appendTextStorage: textStore];
    
    TYTextStorage *nStore = [[TYTextStorage alloc] init];
    nStore.text           = @"\n";
    nStore.font           = [UIFont systemFontOfSize: 20];
    [textContainer appendTextStorage: nStore];
}

#pragma mark 解析ul节点
- (void)parseUlCode:(HTMLNode *)htmlNode textContainer:(TYTextContainer *)textContainer
{
    
    NSArray *li1Nodes = htmlNode.children;
    for (HTMLNode *li1Node in li1Nodes)
    {
        NSString *li1Str = li1Node.rawContents;
        
        if (![li1Str isNotBlank])
        {
            continue;
        }

        
        NSString *firstliStr     = [li1Str componentsSeparatedByString: @"<ul>"].firstObject;
        TYTextStorage *textStore = [[TYTextStorage alloc] init];
        if ([firstliStr containsString: @"<a"])     // li 标签中还包含 a 标签
        {
            NSArray *aStrs = [firstliStr componentsSeparatedByRegex: @"<a"];
            for (NSString *aStr in aStrs)
            {
                
                if ([aStr containsString: @"href=\""])
                {
                    NSRange hrefStrStartRange   = [aStr rangeOfString: @"\">"];
                    NSRange hrefStrEndRange     = [aStr rangeOfString: @"</a>"];
                    NSString *hrefStr           = [aStr substringWithRange: NSMakeRange(hrefStrStartRange.location + hrefStrStartRange.length, hrefStrEndRange.location - hrefStrStartRange.location - 2)];
                    
                    // 获取链接URL
                    NSRange hrefStartRange = [aStr rangeOfString: @"href=\""];
                    NSRange hrefEndRange   = [aStr rangeOfString: @"\">"];
                    NSUInteger hrefStart   = hrefStartRange.location + hrefStartRange.length;
                    NSString *href         = [aStr substringWithRange: NSMakeRange(hrefStart, hrefEndRange.location - hrefStart)];
                    
                    
                    [textContainer appendLinkWithText: hrefStr linkFont: [UIFont systemFontOfSize: 12] linkColor: [UIColor colorWithHexString: @"#c0c0c0"] underLineStyle: kCTUnderlineStyleNone linkData: href];
                    
                    // 说明a标签后面还有文字
                    if ((hrefStrEndRange.location + hrefStrEndRange.length) != aStr.length) {
                        NSUInteger endTextLocation = hrefStrEndRange.location + hrefStrEndRange.length;
                        NSString *endText = [aStr substringWithRange: NSMakeRange(endTextLocation, aStr.length - endTextLocation)];
                        textStore.text           = [NSString stringWithFormat: @" %@\n", [self filterSpecialCharacters: endText]];
                        [textContainer appendTextStorage: textStore];
                    }
                    else
                    {
                        textStore.text = @"\n";
                        [textContainer appendTextStorage: textStore];
                    }
                    
                    
                    continue;
                }
                
                NSString *text = [aStr stringByReplacingOccurrencesOfString: @"<li>" withString: @""];
                textStore.text           = [NSString stringWithFormat: @"▪︎%@ ", [self filterSpecialCharacters: text]];
                [textContainer appendTextStorage: textStore];
            }
//            textStore.text           = @"\n";
//            [textContainer appendTextStorage: textStore];
        }
        else
        {
            firstliStr = [firstliStr stringByReplacingOccurrencesOfString: @"<li>" withString: @""];
            firstliStr = [firstliStr stringByReplacingOccurrencesOfString: @"</li>" withString: @""];
            textStore.text           = [NSString stringWithFormat: @"▪︎%@\n", [self filterSpecialCharacters: firstliStr]];
            //textStore.text           = [NSString stringWithFormat: @"▪︎%@\n\n", [self filterSpecialCharacters: firstliStr]];
            [textContainer appendTextStorage: textStore];
        }
        
        
        // 解析 li 中还包含 ul标签的
        HTMLNode *ul2Node = [li1Node findChildTag: @"ul"];
        NSArray *li2Nodes = [ul2Node findChildTags: @"li"];
        for (HTMLNode *li2Node in li2Nodes)
        {
            textStore.text           = [NSString stringWithFormat: @"   ▪︎%@\n", [self filterSpecialCharacters: li2Node.allContents]];
            [textContainer appendTextStorage: textStore];
        }
        if (li2Nodes.count > 0)
        {
            textStore.text           = @"\n";
            [textContainer appendTextStorage: textStore];
        }
        
    }
}

#pragma mark 过滤特殊字符
- (NSString *)filterSpecialCharacters:(NSString *)text
{
    text = [text stringByReplacingOccurrencesOfString: @"<br><br>" withString: @"\n"];
    text = [text stringByReplacingOccurrencesOfString: @"<br>" withString: @""];
    text = [text stringByReplacingOccurrencesOfString: @"&gt;" withString: @">"];
    text = [text stringByReplacingOccurrencesOfString: @"&li;" withString: @"<"];
    text = [text removeStartAndEndSpace];
    return text;
}
@end
