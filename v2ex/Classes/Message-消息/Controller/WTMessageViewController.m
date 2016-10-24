//
//  WTMessageViewController.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/7/25.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTMessageViewController.h"
#import "WTConversationListViewController.h"
#import "WTLoginViewController.h"

#import "WTAccountViewModel.h"
@interface WTMessageViewController ()
@property (weak, nonatomic) IBOutlet UIView *emptyView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (nonatomic, weak) WTConversationListViewController *conversationListVC;
@end

@implementation WTMessageViewController

- (instancetype)init
{
    return [UIStoryboard storyboardWithName: NSStringFromClass([WTMessageViewController class]) bundle: nil].instantiateInitialViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"nav_search"] style: UIBarButtonItemStyleDone target: self action: @selector(rightBarButtonItemClick)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    if ([WTAccountViewModel shareInstance].isMasakaLogin)
    {
        [self showMessageView];
    }
    else
    {
        self.emptyView.hidden = NO;
        self.contentView.hidden = YES;
    }
}

- (void)showMessageView
{
    [self conversationListVC];
    self.contentView.hidden = NO;
    self.emptyView.hidden = YES;
}

#pragma mark - 事件
- (IBAction)loginBtnClick:(id)sender
{
    __weak typeof (self) weakSelf = self;
    WTLoginViewController *loginVC = [WTLoginViewController new];
    loginVC.loginSuccessBlock = ^{
        [weakSelf showMessageView];
        [weakSelf dismissViewControllerAnimated: YES completion: nil];
    };
    [self presentViewController: loginVC animated: YES completion: nil];
}

#pragma mark - 事件
- (void)rightBarButtonItemClick
{
    [self presentViewController: [UIViewController new] animated: YES completion: nil];
}

#pragma mark - Lazy Method
- (WTConversationListViewController *)conversationListVC
{
    if (_conversationListVC == nil) {
        WTConversationListViewController *conversationListVC = [WTConversationListViewController new];
        conversationListVC.view.frame = self.contentView.bounds;
        [self addChildViewController: conversationListVC];
        [self.contentView addSubview: conversationListVC.view];
        
        _conversationListVC = conversationListVC;
    }
    return _conversationListVC;
}

@end
