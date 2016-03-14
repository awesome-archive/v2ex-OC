//
//  WTWebViewViewController.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/3/15.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTWebViewViewController.h"
#import <WebKit/WebKit.h>

#define WTEstimatedProgress @"estimatedProgress"

@interface WTWebViewViewController ()
@property (weak, nonatomic) WKWebView *webView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@end
@implementation WTWebViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 1、创建webView
    [self setupWebView];
}

#pragma mark - 创建webView
- (void)setupWebView
{
    WKWebView *webView = [[WKWebView alloc] initWithFrame: [UIScreen mainScreen].bounds];
    _webView = webView;
    [self.contentView addSubview: webView];
    
    // 2、加载请求
    [webView loadRequest: [NSURLRequest requestWithURL: self.url]];
    
    // 3、为进度条添加通知
    [webView addObserver: self forKeyPath: WTEstimatedProgress options: NSKeyValueObservingOptionNew context: nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    self.progressView.progress = self.webView.estimatedProgress;
    self.progressView.hidden = self.webView.estimatedProgress >= 1.0;
}

- (void)dealloc
{
    WTLog(@"WTWebViewViewController dealloc")
    [self.webView removeObserver: self forKeyPath: WTEstimatedProgress];
}

@end
