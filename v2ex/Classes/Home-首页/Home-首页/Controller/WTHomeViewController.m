//
//  LBBHomeViewController.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/1/14.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//  首页控制器

#import "WTHomeViewController.h"
#import "WTTopicDetailViewController.h"

#import "WTURLConst.h"

#import "UIImage+Extension.h"

#import "MJExtension.h"

@interface WTHomeViewController ()  
/** WTNode数组*/
@property (nonatomic, strong) NSArray<WTNode *>             *nodes;
@end

@implementation WTHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 初始化导航栏
    [self setupNav];
    
    // 添加子控制器
    [self setupAllChildViewControllers];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *greeenView = [[UIImageView alloc] init];
    greeenView.image = [UIImage imageWithColor: [UIColor colorWithHexString: WTAppLightColor]];
    [self.view addSubview: greeenView];
    greeenView.frame = CGRectMake(0, 0, WTScreenWidth, 64);

}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    
    /*
     navBar.barTintColor = WTColor(42, 183, 103);
     navBar.translucent = NO;
     */
    // 当设置不透明的图片，效果是如上面的代码，会导致View位移，在控制器里面使用 extendedLayoutIncludesOpaqueBars = YES就行了
    [self.navigationController.navigationBar setBackgroundImage: [UIImage imageWithColor: [UIColor colorWithHexString: WTAppLightColor]] forBarMetrics:UIBarMetricsDefault];
}

#pragma mark - Lazy method
#pragma mark nodes
- (NSArray<WTNode *> *)nodes
{
    if (_nodes == nil)
    {
        _nodes = [WTNode mj_objectArrayWithFilename: @"nodes.plist"];
    }
    return _nodes;
}

#pragma mark - 初始化导航栏
- (void)setupNav
{
    self.navigationItem.title = @"v2ex";
}

#pragma mark 添加子控制器
- (void)setupAllChildViewControllers
{
    for (WTNode *node in self.nodes)
    {
        WTTopicViewController *topicVC = [WTTopicViewController new];
        topicVC.title = node.name;
        topicVC.urlString = [WTHTTPBaseUrl stringByAppendingString: node.nodeURL];
        [self addChildViewController: topicVC];
    }
}

@end

