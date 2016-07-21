//
//  WTTopicDetailContentCell.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/3/13.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTTopicDetailContentCell.h"
#import "WTTopicDetailViewModel.h"
#import "NSString+Regex.h"
#import "WTURLConst.h"
@interface WTTopicDetailContentCell() <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
@implementation WTTopicDetailContentCell

- (void)awakeFromNib
{
    // 取消反弹
    self.webView.scrollView.bounces = NO;
    // 监听scrollView的contentSize
    [self.webView.scrollView addObserver: self forKeyPath: @"contentSize" options: NSKeyValueObservingOptionNew context: nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    // 更新cellHeight
    CGFloat height = self.webView.scrollView.contentSize.height;
    self.cellHeight = height;
    if (self.updateCellHeightBlock)
    {
        self.updateCellHeightBlock(height);
    }
    
    if ([keyPath isEqualToString: @"loading"]) {
        WTLog(@"loading")
    }
}

- (void)setTopicDetailVM:(WTTopicDetailViewModel *)topicDetailVM
{
    _topicDetailVM = topicDetailVM;

    // 1、加载网页
    [self.webView loadHTMLString: topicDetailVM.contentHTML baseURL: [NSURL URLWithString: WTHTTP]];
    
    // 2、更新cell的高度
    self.cellHeight = self.webView.scrollView.contentSize.height;
    
}

- (void)dealloc
{
    [self.webView.scrollView removeObserver: self forKeyPath: @"contentSize"];
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *url = request.URL.absoluteString;
    // 第一次加载
    if (([url containsString: @"about:blank"] || [url isEqualToString: @"http:/"]) && ![url containsString: @"jpg"])
    {
        return YES;
    }
    
    // 邮箱
    if ([NSString isAccordWithRegex: @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.4e-]+\\.[A-Za-z]{2,4}" string: url])
    {
        [[UIApplication sharedApplication] openURL: request.URL];
        return NO;
    }
    // 网址
    if ([self.delegate respondsToSelector: @selector(topicDetailContentCell:didClickedWithLinkURL:)])
    {
        [self.delegate topicDetailContentCell: self didClickedWithLinkURL: request.URL];
    }
    return NO;
}

@end
