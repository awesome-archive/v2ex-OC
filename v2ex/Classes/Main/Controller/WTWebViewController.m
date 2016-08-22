//
//  WTWebViewController.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/3/15.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTWebViewController.h"
#import <WebKit/WebKit.h>
#import "WTShareSDKTool.h"
#import "UIBarButtonItem+Extension.h"

#define WTEstimatedProgress @"estimatedProgress"
#define WTCanGoBack @"canGoBack"
#define WTCanGoForward @"canGoForward"
#define WTTitle @"title"

@interface WTWebViewController ()
@property (weak, nonatomic) WKWebView *webView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *prevBtn;
@property (weak, nonatomic) IBOutlet UIButton *refreshBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

@end
@implementation WTWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 1、创建webView
    [self setupWebView];
    
    self.prevBtn.enabled = NO;
    self.nextBtn.enabled = NO;
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem setupBarButtonItemWithImage: [UIImage imageNamed: @"nav_share_normal"] highImage: nil frame: CGRectMake(0, 0, 25, 25) addTarget: self action: @selector(shareClick)];
}


#pragma mark - 创建webView
- (void)setupWebView
{
    WKWebView *webView = [[WKWebView alloc] initWithFrame: [UIScreen mainScreen].bounds];
    _webView = webView;
    [self.contentView addSubview: webView];
    
    // 2、加载请求
    [webView loadRequest: [NSURLRequest requestWithURL: self.url]];
    
    // 3、为进度条、是否可以返回、是否可以前进、标题 添加通知
    [webView addObserver: self forKeyPath: WTEstimatedProgress options: NSKeyValueObservingOptionNew context: nil];
    [webView addObserver: self forKeyPath: WTCanGoBack options: NSKeyValueObservingOptionNew context: nil];
    [webView addObserver: self forKeyPath: WTCanGoForward options: NSKeyValueObservingOptionNew context: nil];
    [webView addObserver: self forKeyPath: WTTitle options: NSKeyValueObservingOptionNew context: nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString: WTEstimatedProgress])
    {
    
        self.progressView.progress = self.webView.estimatedProgress;
        self.progressView.hidden = self.webView.estimatedProgress >= 1.0;
    }
    else if([keyPath isEqualToString: WTCanGoBack])
    {
        self.prevBtn.enabled = self.webView.canGoBack;
    }
    else if([keyPath isEqualToString: WTCanGoForward])
    {
        self.nextBtn.enabled = self.webView.canGoForward;
    }
    else if([keyPath isEqualToString: WTTitle])
    {
        self.title = self.webView.title;
    }
}
#pragma mark - 事件
- (IBAction)refreshBtnClick
{
    [self.webView reload];
}
- (IBAction)prevBtnClick
{
    [self.webView goBack];
    self.nextBtn.enabled = YES;
}
- (IBAction)nextBtnClick
{
    [self.webView goForward];
    self.prevBtn.enabled = YES;
}
- (void)shareClick
{
    [WTShareSDKTool shareWithText: @"" url: self.url.absoluteString title: @""];
}

- (void)dealloc
{
    WTLog(@"WTWebViewViewController dealloc")
    [self.webView removeObserver: self forKeyPath: WTEstimatedProgress];
    [self.webView removeObserver: self forKeyPath: WTCanGoBack];
    [self.webView removeObserver: self forKeyPath: WTCanGoForward];
    [self.webView removeObserver: self forKeyPath: WTTitle];
}
@end
