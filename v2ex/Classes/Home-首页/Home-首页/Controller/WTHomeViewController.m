//
//  LBBHomeViewController.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/1/14.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//  首页控制器

#import "WTHomeViewController.h"
#import "MJExtension.h"
#import "WTURLConst.h"
#import "WTTopicDetailViewController.h"

@interface WTHomeViewController ()  
/** WTNode数组*/
@property (nonatomic, strong) NSArray<WTNode *>             *nodes;
@end

@implementation WTHomeViewController

// 重写初始化方法
- (instancetype)init
{
    return [UIStoryboard storyboardWithName: NSStringFromClass([WTHomeViewController class]) bundle: nil].instantiateInitialViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 初始化导航栏
    [self setupNav];
    
    // 添加子控制器
    [self setupAllChildViewControllers];
    
    self.view.backgroundColor = [UIColor whiteColor];

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

