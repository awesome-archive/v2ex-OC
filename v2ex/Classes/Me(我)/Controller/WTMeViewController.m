//
//  WTMeViewController.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/1/30.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTMeViewController.h"
#import "WTLoginViewController.h"
#import "WTAccount.h"
#import "WTMeTopView.h"
#import "WTAccountTool.h"
#import "WTTopicViewController.h"
#import "WTURLConst.h"
#import "WTNotificationViewController.h"
#import "WTMeAllTopicViewController.h"
#import "WTReplyTopicViewController.h"
#import "WTUserSettingViewController.h"
#import "WTTipView.h"
#import "SVProgressHUD.h"
#import "WTRegisterViewController.h"
@interface WTMeViewController () <UITableViewDelegate, WTMeTopViewDelegate>
/** 已经登陆过的页面 */
@property (weak, nonatomic) IBOutlet UIView   *normalView;
/** 登陆的页面 */
@property (weak, nonatomic) IBOutlet UIView   *loginView;
/** 静态的tableView*/
@property (nonatomic, weak) UITableView       *tableView;
/** 用户全部主题的url */
@property (nonatomic, strong) NSString        *meTopicUrl;
/** 用户信息模型 */
@property (nonatomic, strong) WTUser          *user;
/** 用户信息URL*/
@property (nonatomic, strong) NSString        *urlString;
/** tableView的顶部的View */
@property (nonatomic, weak) WTMeTopView       *meTopView;
/** 提示框View */
@property (nonatomic, weak) WTTipView         *tipView;
/** 登陆按钮 */
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@end

@implementation WTMeViewController

- (instancetype)init
{
    return [[UIStoryboard storyboardWithName: NSStringFromClass([self class]) bundle: nil] instantiateInitialViewController];
}

#pragma mark - 初始化
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 1、设置基本属性
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.loginButton.layer.borderColor = WTPrettyColor.CGColor;
    self.loginButton.layer.borderWidth = 0.5;
    self.loginButton.layer.cornerRadius = 3;
    
    // 2、设置请求用户的Url
    [self setupUserInfoUrlString];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    // 设置Views的隐藏和显示
    //[self adjustViews];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.tableView.frame = self.normalView.bounds;
    
}

#pragma mark - 设置请求用户的Url
- (void)setupUserInfoUrlString
{
    self.title = @"我";
    if (self.username.length != 0)  // 说明正在查看别人用户信息
    {
        self.title = @"用户信息";
        self.urlString = [WTUserInfoUrl stringByAppendingPathComponent: self.username];
        [self refreshUserInfo];
        return;
    }

    if ([[WTAccount shareAccount] isLogin]) // 登陆的情况下，加载自己的信息
    {
        self.normalView.hidden = NO;
        self.loginView.hidden = YES;
        self.urlString = [WTUserInfoUrl stringByAppendingPathComponent: [WTAccount shareAccount].usernameOrEmail];
        [self refreshUserInfo];
        
        return;
    }
    [self adjustViews];
}

#pragma mark - 设置Views的隐藏和显示
- (void)adjustViews
{
    if (self.username.length == 0)
    {
        if ([[WTAccount shareAccount] isLogin]) {
            self.loginView.hidden = YES;
            self.normalView.hidden = NO;
            
          //  [self refreshUserInfo];
        }
        else
        {
            self.normalView.hidden = YES;
            self.loginView.hidden = NO;
        }
    }
}
/**
 *  刷新用户信息
 */
- (void)refreshUserInfo
{
    // 加载TopView
    [self meTopView];
    
    [SVProgressHUD show];
    
    // 刷新用户信息请求
    [WTAccountTool getUserInfoWithUrlString: self.urlString success:^(WTUser *user){
        
        [SVProgressHUD dismiss];
        
        self.user = user;
        self.meTopView.user = user;
        
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
}

#pragma mark - 点击事件
- (IBAction)loginButtonClick
{
    WTLoginViewController *loginVC = [WTLoginViewController new];
    loginVC.loginSuccessBlock = ^{
        WTLog(@"loginBlock")
        [self setupUserInfoUrlString];
    };
    [self presentViewController: loginVC animated: YES completion: nil];
}
- (IBAction)registerButtonClick
{
    [self presentViewController: [WTRegisterViewController new] animated: YES completion: nil];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath: indexPath animated: YES];
    
    switch (indexPath.row) {
        
        case WTMeMessageTypeTopic:
        {
            WTMeAllTopicViewController *meAllTopicVC = [WTMeAllTopicViewController new];
            meAllTopicVC.urlString = self.meTopicUrl;
            meAllTopicVC.title = @"全部主题";
            [self.navigationController pushViewController: meAllTopicVC animated: YES];
            break;
        }
        case WTMeMessageTypeReply:
        {
            WTReplyTopicViewController *replyTopicVC = [WTReplyTopicViewController new];
            replyTopicVC.username = self.user.username;
            replyTopicVC.title = @"全部回复";
            [self.navigationController pushViewController: replyTopicVC animated: YES];
            break;
        }
        case WTMeMessageTypeNotification:
        {
            WTNotificationViewController *notificationVC = [WTNotificationViewController new];
            [self.navigationController pushViewController: notificationVC animated: YES];
            break;
        }
        case WTMeMessageTypeCollection:
        {
            WTTopicViewController *topicVC = [WTTopicViewController new];
            topicVC.urlString = WTCollectionTopicUrl;
            topicVC.title = @"主题收藏";
            [self.navigationController pushViewController: topicVC animated: YES];
            break;
        }
        default:
            break;
    }
}

#pragma mark - WTMeTopViewDelegate
- (void)meTopViewDidClickedSignButton:(WTMeTopView *)meTopView
{
    if ([WTAccount shareAccount].once.length > 0) {
        
        [SVProgressHUD show];
        
        // 1、请求URL
        NSString *url = [WTReceiveAwardsUrl stringByAppendingString: [WTAccount shareAccount].once];
        // 领取今日奖励
        [WTAccountTool signWithUrlString: url success:^{
            
            [SVProgressHUD dismiss];
            
            [self.tipView showTipViewWithTitle: @"签到成功"];
            self.meTopView.signButton.selected = YES;
            
        } failure:^(NSError *error) {
            [SVProgressHUD dismiss];
            [self.tipView showTipViewWithTitle: @"签到失败"];
            self.meTopView.signButton.selected = NO;
        }];
    }
}

#pragma mark - 懒加载
- (UITableView *)tableView
{
    if (_tableView == nil)
    {
        UITableViewController *vc = nil;
        if (self.username.length == 0)
        {
            vc = [[UIStoryboard storyboardWithName: NSStringFromClass([self class]) bundle: nil] instantiateViewControllerWithIdentifier: @"me_vc"];
        }
        else
        {
            vc = [[UIStoryboard storyboardWithName: NSStringFromClass([self class]) bundle: nil] instantiateViewControllerWithIdentifier: @"user_vc"];
        }
        [self addChildViewController: vc];
        [self.normalView addSubview: vc.tableView];

        _tableView = vc.tableView;
        
        _tableView.tableFooterView = [UIView new];
        _tableView.delegate = self;
    }
    return _tableView;
}

- (WTMeTopView *)meTopView
{
    if (_meTopView == nil)
    {
        // 个人资料的View
        WTMeTopView *meTopView = [WTMeTopView wt_viewFromXib];
        meTopView.frame = CGRectMake(0, 0, WTScreenWidth, 59);
        meTopView.delegate = self;
        self.tableView.tableHeaderView = meTopView;
        
        _meTopView = meTopView;
    }
    return  _meTopView;
}
- (WTTipView *)tipView
{
    if (_tipView == nil)
    {
        WTTipView *tipView = [WTTipView wt_viewFromXib];
        [self.navigationController.navigationBar insertSubview: tipView atIndex: 0];
        _tipView = tipView;
        
        tipView.frame = CGRectMake(0, -64, self.view.width, 44);
    }
    return _tipView;
}

- (NSString *)meTopicUrl
{
    if (_meTopicUrl == nil)
    {
        _meTopicUrl = [WTMeTopicUrl stringByReplacingOccurrencesOfString: @"misaka14" withString: self.user.username];
    }
    return _meTopicUrl;
}
@end
