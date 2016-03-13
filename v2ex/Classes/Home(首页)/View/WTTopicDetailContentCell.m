//
//  WTTopicDetailContentCell.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/3/13.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTTopicDetailContentCell.h"
#import "WTTopicDetailViewModel.h"
@interface WTTopicDetailContentCell()
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
}

- (void)setTopicDetailVM:(WTTopicDetailViewModel *)topicDetailVM
{
    _topicDetailVM = topicDetailVM;

    [self.webView loadHTMLString: topicDetailVM.contentHTML baseURL: nil];
}

- (void)dealloc
{
    [self.webView.scrollView removeObserver: self forKeyPath: @"contentSize"];
}

@end
