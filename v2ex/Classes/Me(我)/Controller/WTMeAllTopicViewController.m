//
//  WTMeAllTopicViewController.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/2/26.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTMeAllTopicViewController.h"
#import "WTMeAllTopicCell.h"
#import "WTAccountTool.h"
#import "WTTopicDetailViewController.h"
static NSString * const ID = @"meAllTopiccell";

@interface WTMeAllTopicViewController ()
/** 话题数组 */
@property (nonatomic, strong) NSMutableArray       *topics;
/** 当前页数 */
@property (nonatomic, assign) NSInteger            page;

@end

@implementation WTMeAllTopicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 个人主题超过1页的情况
    // self.urlString = @"http://www.v2ex.com/member/kn007/topics";
    self.urlString = [self.urlString stringByAppendingString: @"?p=1"];
    
    // 1、注册cell
    [self.tableView registerNib: [UINib nibWithNibName: NSStringFromClass([WTMeAllTopicCell class]) bundle: nil] forCellReuseIdentifier: ID];
    
    // 2、self.sizing
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 54;
}

#pragma mark - 加载数据
#pragma mark 加载最新的数据
- (void)loadNewData
{
    self.page = 1;
    
    NSRange range = [self.urlString rangeOfString: @"="];
    self.urlString = [NSString stringWithFormat: @"%@%ld", [self.urlString substringWithRange: NSMakeRange(0, range.location + range.length)], self.page];
    
    [WTAccountTool getMeAllTopicWithUrlString: self.urlString success:^(NSMutableArray<WTTopic *> *topics) {
        
        [self isHasNextPage: topics.lastObject];
        
        self.topics = topics;
        [self.topics removeLastObject];
        [self.tableView.mj_header endRefreshing];
        
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        [self.tableView.mj_header endRefreshing];
    }];
}

#pragma mark 加载最旧的数据
- (void)loadOldData
{
    self.page ++;
    
    NSRange range = [self.urlString rangeOfString: @"="];
    self.urlString = [NSString stringWithFormat: @"%@%ld", [self.urlString substringWithRange: NSMakeRange(0, range.location + range.length)], self.page];
    
    [WTAccountTool getMeAllTopicWithUrlString: self.urlString success:^(NSMutableArray<WTTopic *> *topics) {
        
        [self isHasNextPage: topics.lastObject];
        
        [self.topics addObjectsFromArray: topics];
        [self.topics removeLastObject];
        [self.tableView.mj_header endRefreshing];
        
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        [self.tableView.mj_header endRefreshing];
    }];
}


/**
 *  是否有下一页
 *
 */
- (void)isHasNextPage:(WTTopic *)topic
{
    // 取出最后一个模型判断是有下一页
    if (!topic.isHasNextPage)
    {
        self.tableView.mj_footer = nil;
    }
    else
    {
        self.tableView.mj_footer = [WTRefreshAutoNormalFooter footerWithRefreshingTarget: self refreshingAction: @selector(loadOldData)];
    }
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    WTLog(@"count:%ld", self.topics.count)
    return self.topics.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WTMeAllTopicCell *cell = [tableView dequeueReusableCellWithIdentifier: ID];
    
    cell.topic = self.topics[indexPath.row];

    return cell;
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath: indexPath animated: YES];
    
    WTTopic *topic = self.topics[indexPath.row];
    WTTopicDetailViewController *topDetailVC = [WTTopicDetailViewController new];
    topDetailVC.topic = topic;
    [self.navigationController pushViewController: topDetailVC animated: YES];
}
@end
