//
//  WTAdvertiseViewController.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/7/25.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//  鸣谢控制器

#import "WTAdvertiseViewController.h"
#import "WTAdvertiseViewModel.h"
#import "WTRefreshNormalHeader.h"
#import "WTAdvertiseCell.h"

NSString * const advertiseCellIdentifier = @"advertiseCellIdentifier";

@interface WTAdvertiseViewController ()
@property (nonatomic, strong) NSMutableArray<WTAdvertiseItem *> *advertiseItems;
@end

@implementation WTAdvertiseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // 加载View
    [self setupView];
}

// 加载View
- (void)setupView
{
    self.title = @"鸣谢";
    
    self.tableView.estimatedRowHeight = 180;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tableView registerNib: [UINib nibWithNibName: @"WTAdvertiseCell" bundle: nil] forCellReuseIdentifier: advertiseCellIdentifier];
    self.tableView.mj_header = [WTRefreshNormalHeader headerWithRefreshingTarget: self refreshingAction: @selector(loadNewData)];
    
    [self.tableView.mj_header beginRefreshing];
}

- (void)loadNewData
{
    [WTAdvertiseViewModel loadAdvertiseItemsFromNetworkWithSuccess:^(NSMutableArray<WTAdvertiseItem *> *advertiseItems) {
        
        self.advertiseItems = advertiseItems;
        
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
        
    } failure:^(NSError *error) {
        
        [self.tableView.mj_header endRefreshing];
        
    }];
}

#pragma mark - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.advertiseItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WTAdvertiseCell *cell = [tableView dequeueReusableCellWithIdentifier: advertiseCellIdentifier];
    
    cell.advertiseItem = self.advertiseItems[indexPath.row];
    
    return cell;
}


@end
