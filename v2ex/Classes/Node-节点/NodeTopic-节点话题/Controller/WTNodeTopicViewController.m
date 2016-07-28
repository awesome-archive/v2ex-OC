//
//  WTNodeTopicViewController.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/7/22.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//  节点话题控制器

#import "WTNodeTopicViewController.h"
#import "WTNodeTopicAPIItem.h"
#import "WTNodeTopicCell.h"
#import "NetworkTool.h"
#import "MJExtension.h"
#import "WTNodeItem.h"

CGFloat const userCenterHeaderViewH = 150;

NSString * const identifier = @"identifier";

@interface WTNodeTopicViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) UIView *headerView;
@property (nonatomic, assign) UIView *footerView;

@property (nonatomic, assign) UITableView *tableView;

/** scrollView滑动时最后Y值 */
@property (nonatomic, assign) CGFloat endY;

@property (nonatomic, strong) NSMutableArray<WTNodeTopicAPIItem *> *nodeTopicAPIItems;
@end

@implementation WTNodeTopicViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 设置View
    [self setupView];
    
    // 加载数据
    [self setupData];
}

// 设置View
- (void)setupView
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 1、headerView
    UIView *headerView = [UIView new];
    
    {
        headerView.frame = CGRectMake(0, 0, WTScreenWidth, WTScreenHeight - WTTabBarHeight);
        [self.view addSubview: headerView];
        self.headerView = headerView;
        headerView.backgroundColor = WTColor(29, 184, 100);
    }
    
    // 2、footerView
    UIView *footerView = [UIView new];
    
    {
        footerView.backgroundColor = [UIColor clearColor];
        footerView.frame = CGRectMake(0, userCenterHeaderViewH, WTScreenWidth, WTScreenHeight - userCenterHeaderViewH);
        [self.view addSubview: footerView];
        self.footerView = footerView;
        
    }
    
    // 3、tableView
    UITableView *tableView = [UITableView new];
    
    {
       
        tableView.frame = footerView.bounds;
        [self.footerView addSubview: tableView];
        self.tableView = tableView;
        
        tableView.dataSource = self;
        tableView.delegate = self;
        
        tableView.rowHeight = 140;
        [tableView registerNib: [UINib nibWithNibName: @"WTNodeTopicCell" bundle: nil] forCellReuseIdentifier: identifier];
    }
}

// 加载数据
- (void)setupData
{
    NSString *urlString = [NSString stringWithFormat: @"https://www.v2ex.com/api/topics/show.json?node_id=%ld", self.nodeItem.uid];
    
    [[NetworkTool shareInstance] requestWithMethod: HTTPMethodTypeGET url: urlString param: nil success:^(id responseObject) {
        
        self.nodeTopicAPIItems = [WTNodeTopicAPIItem mj_objectArrayWithKeyValuesArray: responseObject];
        
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - UITableView Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.nodeTopicAPIItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WTNodeTopicCell *nodeTopicCell = [tableView dequeueReusableCellWithIdentifier: identifier];
    
    nodeTopicCell.nodeTopicAPIItem = self.nodeTopicAPIItems[indexPath.row];
    
    return nodeTopicCell;
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < 0)
    {
        [UIView animateWithDuration: 0.1 animations:^{
           
            
            self.endY += (-scrollView.contentOffset.y) * 0.3;
            self.footerView.y = userCenterHeaderViewH + self.endY;
            
        }];
        
        scrollView.contentOffset = CGPointMake(0, 0);
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [UIView animateWithDuration: 0.3 animations:^{
        
        self.footerView.y = userCenterHeaderViewH;
        self.endY = 0;
    }];
}

@end
