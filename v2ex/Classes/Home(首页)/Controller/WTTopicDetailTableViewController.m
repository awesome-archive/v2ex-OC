//
//  WTTopicDetailTableViewController.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/3/13.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTTopicDetailTableViewController.h"
#import "WTTopicDetailViewModel.h"
#import "NetworkTool.h"
#import "WTTopicDetailHeadCell.h"
#import "WTTopicDetailContentCell.h"
#import "WTTopicDetailCommentCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
@interface WTTopicDetailTableViewController ()

@property (nonatomic, strong) NSArray<WTTopicDetailViewModel *> *topicDetailViewModels;

@property (nonatomic, assign) NSInteger                         currentPage;

@property (nonatomic, strong) WTTopicDetailContentCell          *contentCell;

@end

static NSString  * const headerCellID = @"headerCellID";
static NSString  * const contentCellID = @"contentCellID";
static NSString  * const commentCellID = @"commentCellID";

@implementation WTTopicDetailTableViewController

- (instancetype)init
{
    return [UIStoryboard storyboardWithName: NSStringFromClass([WTTopicDetailTableViewController class]) bundle: nil].instantiateInitialViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 加载数据
    [self setupData];
    
}

#pragma mark - 加载数据
- (void)setupData
{
    if (self.currentPage != 0)
    {
        NSString *url = self.topicDetailUrl;
        NSRange range = [url rangeOfString: @"#" options: NSBackwardsSearch];
        // 说明没查找到#号
        if (range.location > url.length)
        {
            range = [url rangeOfString: @"=" options: NSBackwardsSearch];
            url = [url substringToIndex: range.location];
            self.topicDetailUrl = [url stringByAppendingFormat: @"=%ld", self.currentPage];
        }
        else
        {
            url = [url substringToIndex: range.location];
            self.topicDetailUrl = [url stringByAppendingFormat: @"?p=%ld", self.currentPage];
        }
        
    }
    
    [[NetworkTool shareInstance] getHtmlCodeWithUrlString: self.topicDetailUrl success:^(NSData *data) {
       
        self.topicDetailViewModels = [WTTopicDetailViewModel topicDetailsWithData: data];
        
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.topicDetailViewModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (indexPath.row == 0)
    {
        WTTopicDetailHeadCell *cell = [tableView dequeueReusableCellWithIdentifier: headerCellID];
        cell.topicDetailVM = self.topicDetailViewModels.firstObject;
    
        return cell;
    }
    else if(indexPath.row == 1)
    {
        WTTopicDetailContentCell *cell = [tableView dequeueReusableCellWithIdentifier: contentCellID];
        cell.topicDetailVM = self.topicDetailViewModels.firstObject;
        self.contentCell = cell;
        
        __weak typeof(self) weakSelf = self;
        cell.updateCellHeightBlock = ^(CGFloat height)
        {
            if ([weakSelf.tableView.visibleCells containsObject: weakSelf.contentCell])
            {
                [weakSelf.tableView beginUpdates];
                [weakSelf.tableView endUpdates];
            }
        };
        
        return cell;
    }
    else
    {
        WTTopicDetailCommentCell *cell = [tableView dequeueReusableCellWithIdentifier: commentCellID];
        cell.topicDetailVM = self.topicDetailViewModels[indexPath.row - 1];
        return cell;
    }
    
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        return [tableView fd_heightForCellWithIdentifier: headerCellID cacheByIndexPath: indexPath configuration:^(WTTopicDetailHeadCell *cell) {
            cell.topicDetailVM = self.topicDetailViewModels.firstObject;
        }];
    }
    else if(indexPath.row == 1)
    {
        WTLog(@"contentCellHeight:%lf", self.contentCell.cellHeight)
        return self.contentCell.cellHeight;
    }
    else
    {
        return [tableView fd_heightForCellWithIdentifier: commentCellID cacheByIndexPath: indexPath configuration:^(WTTopicDetailCommentCell *cell) {
            cell.topicDetailVM = self.topicDetailViewModels[indexPath.row - 1];
        }];
    }
    
}

@end
