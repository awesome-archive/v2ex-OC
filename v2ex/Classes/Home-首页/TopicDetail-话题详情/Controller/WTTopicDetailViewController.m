//
//  WTtopicDetailViewController.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/1/17.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//  话题详情控制器

#import "WTTopicDetailViewController.h"
#import "WTTopicViewModel.h"
#import "WTTopicDetailTableViewController.h"
#import "Masonry.h"
#import "WTToolBarView.h"

#import "UIImage+Extension.h"
@interface WTTopicDetailViewController ()
/** 已经登陆过的View */
@property (weak, nonatomic) IBOutlet UIView             *normalView;
/** 正在加载的View */
@property (weak, nonatomic) IBOutlet UIView             *loadingView;
/** 工具条的View */
@property (nonatomic, weak) WTToolBarView               *toolBarView;
/** 提示的View */
@property (weak, nonatomic) IBOutlet UIView             *tipView;
/** 帖子的tableView */
@property (nonatomic, weak) UITableView                 *tableView;
@end

@implementation WTTopicDetailViewController

- (instancetype)init
{
    return [UIStoryboard storyboardWithName: NSStringFromClass([self class]) bundle: nil].instantiateInitialViewController;
}

#pragma mark - 初始化
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 设置话题详情数据
    [self setupTopicDetailData];
}

#pragma mark -设置话题详情数据
- (void)setupTopicDetailData
{
    UIImageView *greeenView = [[UIImageView alloc] init];
    greeenView.image = [UIImage imageWithColor: [UIColor colorWithHexString: WTAppLightColor]];
    [self.view addSubview: greeenView];
    greeenView.frame = CGRectMake(0, 0, WTScreenWidth, 64);

    
    // 1、创建话题详情数据控制器
    WTTopicDetailTableViewController *topicVC = [WTTopicDetailTableViewController new];
    topicVC.topicDetailUrl = self.topicDetailUrl;
    [self.normalView addSubview: topicVC.tableView];
    _tableView = topicVC.tableView;
    [self addChildViewController: topicVC];
    
    // 2、设置属性
    topicVC.tableView.contentInset = UIEdgeInsetsMake(0, 0, WTToolBarHeight, 0);
    topicVC.tableView.separatorInset = topicVC.tableView.contentInset;
    
    // 3、设置布局
    [topicVC.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.normalView);
    }];
    
    // 4、操作帖子之后的操作
    __weak typeof(self) weakSelf = self;
    topicVC.updateTopicDetailComplection = ^(WTTopicDetailViewModel *topicDetailVM, NSError *error){
        
        weakSelf.loadingView.hidden = YES;
        
        if (error != nil)
        {
            weakSelf.tipView.hidden = NO;
            return;
        }
        weakSelf.tipView.hidden = YES;
        weakSelf.toolBarView.topicDetailVM = topicDetailVM;
    };
}

#pragma mark - 懒加载
- (WTToolBarView *)toolBarView
{
    if (_toolBarView == nil)
    {
        // 1、创建工具栏View
        WTToolBarView *toolBarView = [WTToolBarView toolBarView];
        [self.normalView addSubview: toolBarView];
        _toolBarView = toolBarView;
        
        // 3、布局
        [toolBarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.normalView);
            make.height.equalTo(@(WTToolBarHeight));
        }];
    }
    return _toolBarView;
}

#pragma mark - 事件
- (IBAction)goLoginVCBtnClick
{
    WTLoginViewController *loginVC = [WTLoginViewController new];
    loginVC.loginSuccessBlock = ^{
        WTTopicDetailTableViewController *vc = self.childViewControllers.firstObject;
        [vc setupData];
    };
    [self presentViewController: loginVC animated: YES completion: nil];
}

- (void)dealloc
{
    WTLog(@"WTTopicDetailViewController dealloc")
}

@end
