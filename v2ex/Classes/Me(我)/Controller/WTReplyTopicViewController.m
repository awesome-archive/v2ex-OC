//
//  WTReplyViewController.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/2/27.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTReplyTopicViewController.h"
#import "WTAccountTool.h"
#import "WTURLConst.h"
#import "WTReplyTopicCell.h"
#import "WTTopicDetailViewController.h"

static NSString * const ID = @"replyTopicCell";

@interface WTReplyTopicViewController ()
/** url地址 */
@property (nonatomic, strong) NSString                  *urlString;
/** 话题模型 */
@property (nonatomic, strong) NSMutableArray<WTTopic *> *topics;
/** 页数 */
@property (nonatomic, assign) NSInteger                 page;
@end

@implementation WTReplyTopicViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 1、注册cell
    [self.tableView registerNib: [UINib nibWithNibName: NSStringFromClass([WTReplyTopicCell class]) bundle: nil] forCellReuseIdentifier: ID];
    
    // self-sizing
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 91;
    
    // 3、取消分隔线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // 4、取消滚动条
    self.tableView.showsVerticalScrollIndicator = NO;
    
    self.view.backgroundColor = [UIColor colorWithHexString: @"#F4F4F4"];
}

#pragma mark - 加载数据
- (void)loadNewData
{
    self.page = 1;
    
    NSRange range = [self.urlString rangeOfString: @"="];
    self.urlString = [NSString stringWithFormat: @"%@%ld", [self.urlString substringWithRange: NSMakeRange(0, range.location + range.length)], self.page];
    
    [WTAccountTool getReplyTopicsWithUrlString: self.urlString success:^(NSMutableArray<WTTopic *> *topics) {
        
        [self isHasNextPage: topics.lastObject];
        self.topics = topics;
        [self.topics removeLastObject];
        
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)loadOldData
{
    self.page ++;
    
    NSRange range = [self.urlString rangeOfString: @"="];
    self.urlString = [NSString stringWithFormat: @"%@%ld", [self.urlString substringWithRange: NSMakeRange(0, range.location + range.length)], self.page];
    
    [WTAccountTool getReplyTopicsWithUrlString: self.urlString success:^(NSMutableArray<WTTopic *> *topics) {
        
        [self isHasNextPage: topics.lastObject];
        [self.topics addObjectsFromArray: topics];
        [self.topics removeLastObject];
        
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
        
    } failure:^(NSError *error) {
        
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

#pragma mark - UITableViewDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.topics.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WTReplyTopicCell *cell = [tableView dequeueReusableCellWithIdentifier: ID];
    
    cell.topic = self.topics[indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 跳转至话题详情控制器
    WTTopicDetailViewController *topicDetailVC = [WTTopicDetailViewController new];
    //topicDetailVC.topic = self.topics[indexPath.row];
    [self.navigationController pushViewController: topicDetailVC animated: YES];
}

#pragma mark - 懒加载
- (NSString *)urlString
{
    if (_urlString == nil)
    {
        _urlString = [WTReplyTopicUrl stringByReplacingOccurrencesOfString: @"misaka14" withString: self.username];
    }
    return _urlString;
}

@end
