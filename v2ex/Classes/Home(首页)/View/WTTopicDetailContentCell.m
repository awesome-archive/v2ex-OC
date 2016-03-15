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
    
    self.webView.scrollView.bounces = NO;
    [self.webView.scrollView addObserver: self forKeyPath: @"contentSize" options: NSKeyValueObservingOptionNew context: nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
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

    [self.webView loadHTMLString: topicDetailVM.contentHTML baseURL: [NSURL URLWithString: WTHTTP]];
    WTLog(@"1")
    
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
    if (([url containsString: @"about:blank"] || [url containsString: @"http:/"]) && ![url containsString: @"jpg"])
    {
        return YES;
    }
    
    if ([NSString isAccordWithRegex: @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}" string: url])
    {
        [[UIApplication sharedApplication] openURL: request.URL];
        return NO;
    }
    if ([self.delegate respondsToSelector: @selector(topicDetailContentCell:didClickedWithLinkURL:)])
    {
        [self.delegate topicDetailContentCell: self didClickedWithLinkURL: request.URL];
    }
    return NO;
}

@end
