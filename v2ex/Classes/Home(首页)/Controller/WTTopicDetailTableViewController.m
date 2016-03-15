//
//  WTTopicDetailTableViewController.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/3/13.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTTopicDetailTableViewController.h"
#import "WTTopicDetailViewModel.h"
#import "WTTopicDetailHeadCell.h"
#import "WTTopicDetailContentCell.h"
#import "WTTopicDetailCommentCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "WTToolBarView.h"
#import "SVProgressHUD.h"
#import "WTPostReplyViewController.h"
#import "NSString+Regex.h"
#import "WTNavigationController.h"
#import "WTWebViewViewController.h"
#import "WTAccount.h"
#import "WTURLConst.h"
@interface WTTopicDetailTableViewController () <WTTopicDetailContentCellDelegate>

@property (nonatomic, strong) NSMutableArray<WTTopicDetailViewModel *> *topicDetailViewModels;

@property (nonatomic, assign) NSInteger                                currentPage;

@property (nonatomic, strong) WTTopicDetailContentCell                 *contentCell;

@property (nonatomic, strong) WTTopicDetailViewModel                   *firstTopicDetailVM;
/** 回复话题的Url */
@property (nonatomic, strong) NSString                                 *replyTopicUrl;
/** 最后一页的Url */
@property (nonatomic, strong) NSString                                 *lastPageUrl;
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
    
    // 添加通知
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(toolbarButtonClick:) name: WTToolBarButtonClickNotification object: nil];
    
    // 回复帖子用的url
    self.replyTopicUrl = [NSString subStringToIndexWithStr: @"#" string: self.topicDetailUrl];
    
    self.lastPageUrl = self.topicDetailUrl;
}

#pragma mark - 事件
- (void)toolbarButtonClick:(NSNotification *)noti
{
    NSUInteger buttonType = [noti.userInfo[@"buttonType"] integerValue];
    
    switch (buttonType)
    {
        case WTToolBarButtonTypeLove:
            [self topicOperationWithMethod: HTTPMethodTypePOST urlString: self.firstTopicDetailVM.thankUrl];
            break;
        case WTToolBarButtonTypeCollection: // 收藏话题
            [self topicOperationWithMethod: HTTPMethodTypeGET urlString: self.firstTopicDetailVM.collectionUrl];
            break;
        case WTToolBarButtonTypePrev:       // 上一页
        {
            self.currentPage--;
            [self setupData];
            break;
        }
        case WTToolBarButtonTypeNext:       // 下一页
        {
            self.currentPage++;
            [self setupData];
            break;
        }
        case WTToolBarButtonTypeSafari:
            
            break;
        case WTToolBarButtonTypeReply:      // 回复话题
            [self replyTopic];
            break;
    }
}

#pragma mark 回复话题
- (void)replyTopic
{
    // 1、先判断是否登陆
    if(![[WTAccount shareAccount] isLogin])
    {
        WTLoginViewController *loginVC = [WTLoginViewController new];
        [self presentViewController: loginVC animated: YES completion: nil];
        return;
    }
    
    WTPostReplyViewController *postReplyVC = [WTPostReplyViewController new];
    
    postReplyVC.urlString = self.replyTopicUrl;
    postReplyVC.once = self.firstTopicDetailVM.once;
    
    postReplyVC.completionBlock = ^(BOOL isSuccess){
        self.topicDetailUrl = self.lastPageUrl;
        [self setupData];
    };
    
    WTNavigationController *nav = [[WTNavigationController alloc] initWithRootViewController: postReplyVC];
    [self presentViewController: nav animated: YES completion: nil];
}

#pragma mark - 帖子操作
- (void)topicOperationWithMethod:(HTTPMethodType)method urlString:(NSString *)urlString
{
    // 1、先判断是否登陆
    if(![[WTAccount shareAccount] isLogin])
    {
        WTLoginViewController *loginVC = [WTLoginViewController new];
        [self presentViewController: loginVC animated: YES completion: nil];
        return;
    }
    
    [SVProgressHUD show];
    [WTTopicDetailViewModel topicOperationWithMethod: method urlString: urlString topicDetailUrl: self.topicDetailUrl completion:^(WTTopicDetailViewModel *topicDetailVM, NSError *error) {
        
        [SVProgressHUD dismiss];
        if (error != nil)
        {
            [SVProgressHUD showErrorWithStatus: @"操作异常,请稍候重试" maskType: SVProgressHUDMaskTypeBlack];
            return;
        }
        
        self.firstTopicDetailVM = topicDetailVM;
        if (self.updateTopicDetailComplection)
        {
            self.updateTopicDetailComplection(topicDetailVM, nil);
        }
    }];
}

#pragma mark - 加载数据
- (void)setupData
{
    [self parseUrl];
    
    //self.topicDetailUrl = @"http://www.v2ex.com/t/262888#reply0";
    [[NetworkTool shareInstance] getHtmlCodeWithUrlString: self.topicDetailUrl success:^(NSData *data) {
        
        self.topicDetailViewModels = [WTTopicDetailViewModel topicDetailsWithData: data];
        
        // 说明帖子需要登陆
        if (self.topicDetailViewModels.count == 0)
        {
            if (self.updateTopicDetailComplection)
            {
                NSError *error = [[NSError alloc] initWithDomain: WTDomain code: -1011 userInfo: @{@"errorMessage" : @"查看本主题需要登录"}];
                self.updateTopicDetailComplection(nil, error);
            }
            return;
        }
        
        self.firstTopicDetailVM = self.topicDetailViewModels.firstObject;
        
        if (self.updateTopicDetailComplection)
        {
            self.updateTopicDetailComplection(self.topicDetailViewModels.firstObject, nil);
        }
        
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
    }];
}

- (void)parseUrl
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
}


#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.topicDetailViewModels.count + 1;
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
        cell.delegate = self;
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

#pragma mark - WTTopicDetailContentCellDelegate
- (void)topicDetailContentCell:(WTTopicDetailContentCell *)contentCell didClickedWithLinkURL:(NSURL *)linkURL
{
    WTWebViewViewController *webViewVC = [WTWebViewViewController new];
    webViewVC.url = linkURL;
    [self.navigationController pushViewController: webViewVC animated: nil];
}

#pragma mark - dealloc
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

@end
