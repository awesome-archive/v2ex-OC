//
//  WTTopicDetailTableViewController.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/3/13.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTTopicDetailTableViewController.h"
#import "WTWebViewController.h"
#import "WTNavigationController.h"
#import "WTPostReplyViewController.h"
#import "WTMemberDetailViewController.h"

#import "WTToolBarView.h"
#import "WTTopicDetailHeadCell.h"
#import "WTTopicDetailContentCell.h"
#import "WTTopicDetailCommentCell.h"

#import "WTTopicDetailViewModel.h"

#import "WTURLConst.h"
#import "NSString+Regex.h"
#import "WTAccountViewModel.h"

#import "SVProgressHUD.h"
#import "UITableView+FDTemplateLayoutCell.h"

@interface WTTopicDetailTableViewController () <WTTopicDetailHeadCellDelegate, WTTopicDetailContentCellDelegate, WTTopicDetailCommentCellDelegate>
/** 帖子回复ViewModel */
@property (nonatomic, strong) NSMutableArray<WTTopicDetailViewModel *> *topicDetailViewModels;
/** 当前页 */
@property (nonatomic, assign) NSInteger                                currentPage;
/** 帖子正文内容 */
@property (nonatomic, strong) WTTopicDetailContentCell                 *contentCell;
/** 帖子标题 */
@property (nonatomic, strong) WTTopicDetailViewModel                   *firstTopicDetailVM;
/** 回复话题的Url */
@property (nonatomic, strong) NSString                                 *replyTopicUrl;
/** 最后一页的Url */
@property (nonatomic, strong) NSString                                 *lastPageUrl;
@end

/** 帖子标题 */
static NSString  * const headerCellID = @"headerCellID";
/** 帖子正文 */
static NSString  * const contentCellID = @"contentCellID";
/** 帖子回复 */
static NSString  * const commentCellID = @"commentCellID";

@implementation WTTopicDetailTableViewController

- (instancetype)init
{
    return [UIStoryboard storyboardWithName: NSStringFromClass([WTTopicDetailTableViewController class]) bundle: nil].instantiateInitialViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.topicDetailUrl = @"http://www.v2ex.com/t/265305#reply0";
    
    // 1、加载数据
    [self setupData];
    
    // 2、添加通知
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(toolbarButtonClick:) name: WTToolBarButtonClickNotification object: nil];
    
    // 3、回复帖子用的url
    if ([self.topicDetailUrl containsString: @"#"]) {
        
        self.replyTopicUrl = [NSString subStringToIndexWithStr: @"#" string: self.topicDetailUrl];
    }
    else
    {
        self.replyTopicUrl = self.topicDetailUrl;
    }
    
    // 4、帖子详情url
    self.lastPageUrl = self.topicDetailUrl;
}

#pragma mark - 事件
- (void)toolbarButtonClick:(NSNotification *)noti
{
    NSUInteger buttonType = [noti.userInfo[@"buttonType"] integerValue];
    
    switch (buttonType)
    {
        // 感谢 操作
        case WTToolBarButtonTypeLove:
        {
            [self topicOperationWithMethod: HTTPMethodTypePOST urlString: self.firstTopicDetailVM.thankUrl allowOperation:^{
                if (self.firstTopicDetailVM.thankType == WTThankTypeAlready)    // 已经感谢过
                {
                    [SVProgressHUD showErrorWithStatus: @"不能取消感谢"];
                    return NO;
                }
                else if(self.firstTopicDetailVM.thankType == WTThankTypeUnknown)    // 未知原因不能感谢
                {
                    [SVProgressHUD showErrorWithStatus: @"未知原因不能感谢"];
                    
                    return NO;
                }
                return YES;
            }];
        
            break;
        }
        // 收藏话题
        case WTToolBarButtonTypeCollection:
            [self topicOperationWithMethod: HTTPMethodTypeGET urlString: self.firstTopicDetailVM.collectionUrl allowOperation: nil];
            break;
        // 上一页
        case WTToolBarButtonTypePrev:
        {
            self.currentPage--;
            [self setupData];
            break;
        }
        // 下一页
        case WTToolBarButtonTypeNext:
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
    if (![[WTAccountViewModel shareInstance] isLogin])
    {
        WTLoginViewController *loginVC = [WTLoginViewController new];
        [self presentViewController: loginVC animated: YES completion: nil];
        return;
    }
    
    // 2、moda回复话题控制器
    WTPostReplyViewController *postReplyVC = [WTPostReplyViewController new];
    
    // 2.1、回复话题的必备参数
    postReplyVC.urlString = self.replyTopicUrl;
    postReplyVC.once = self.firstTopicDetailVM.once;
    
    // 2.2、回复之后的block操作
    postReplyVC.completionBlock = ^(BOOL isSuccess){
        self.topicDetailUrl = self.lastPageUrl;
        [self setupData];
    };
    
    WTNavigationController *nav = [[WTNavigationController alloc] initWithRootViewController: postReplyVC];
    [self presentViewController: nav animated: YES completion: nil];
}

#pragma mark - 帖子操作
- (void)topicOperationWithMethod:(HTTPMethodType)method urlString:(NSString *)urlString allowOperation:(BOOL(^)())allowOperation
{
    // 1、先判断是否登陆
    if (![[WTAccountViewModel shareInstance] isLogin])
    {
        // 1.1、跳转至登陆控制器
        WTLoginViewController *loginVC = [WTLoginViewController new];
        
        // 1.2、登陆之后的操作
        __weak typeof(self) weakSelf = self;
        loginVC.loginSuccessBlock = ^(){
            [weakSelf setupData];
        };
        
        [self presentViewController: loginVC animated: YES completion: nil];
        return;
    }
    
    // 允许登陆之后的操作
    if (allowOperation)
    {
        BOOL isAllow = allowOperation();
        if (!isAllow)
        {
            return;
        }
    }
    
    
    [SVProgressHUD show];
    [WTTopicDetailViewModel topicOperationWithMethod: method urlString: urlString topicDetailUrl: self.topicDetailUrl completion:^(WTTopicDetailViewModel *topicDetailVM, NSError *error) {
        
        [SVProgressHUD dismiss];
        if (error != nil)
        {
            WTLog(@"error:%@", error)
            [SVProgressHUD showErrorWithStatus: @"操作异常,请稍候重试"];
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
    
    //self.topicDetailUrl = @"http://www.v2ex.com/t/263754#reply0";
    [[NetworkTool shareInstance] GETWithUrlString: self.topicDetailUrl success:^(NSData *data) {
        
        self.topicDetailViewModels = [WTTopicDetailViewModel topicDetailsWithData: data];
        
        // 更新页数
        self.currentPage = self.topicDetailViewModels.firstObject.currentPage;
        
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

#pragma mark - 解析url
- (void)parseUrl
{
    if (self.currentPage > 0)
    {
        NSString *url = self.topicDetailUrl;
        NSRange range = [url rangeOfString: @"#" options: NSBackwardsSearch];
        // 说明没查找到#号
        if (range.location == NSNotFound)
        {
            range = [url rangeOfString: @"=" options: NSBackwardsSearch];
            
            if (range.location != NSNotFound)
            {
                url = [url substringToIndex: range.location];
                self.topicDetailUrl = [url stringByAppendingFormat: @"=%ld", self.currentPage];
            }
            else
            {
                self.topicDetailUrl = [url stringByAppendingFormat: @"?p=%ld", self.currentPage];
            }
            
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
    if (indexPath.row == 0) // 帖子标题
    {
        WTTopicDetailHeadCell *cell = [tableView dequeueReusableCellWithIdentifier: headerCellID];
        cell.topicDetailVM = self.topicDetailViewModels.firstObject;
        cell.delegate = self;
        return cell;
    }
    else if(indexPath.row == 1) // 帖子正文
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
    else    // 帖子回复
    {
        WTTopicDetailCommentCell *cell = [tableView dequeueReusableCellWithIdentifier: commentCellID];
        cell.delegate = self;
        cell.topicDetailVM = self.topicDetailViewModels[indexPath.row - 1];
        return cell;
    }
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)   // 帖子标题
    {
        return [tableView fd_heightForCellWithIdentifier: headerCellID cacheByIndexPath: indexPath configuration:^(WTTopicDetailHeadCell *cell) {
            cell.topicDetailVM = self.topicDetailViewModels.firstObject;
        }];
    }
    else if(indexPath.row == 1) // 帖子正文
    {
        //WTLog(@"contentCellHeight:%lf", self.contentCell.cellHeight)
        return self.contentCell.cellHeight;
    }
    else        // 帖子回复
    {
        return [tableView fd_heightForCellWithIdentifier: commentCellID cacheByIndexPath: indexPath configuration:^(WTTopicDetailCommentCell *cell) {
            cell.topicDetailVM = self.topicDetailViewModels[indexPath.row - 1];
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //WTMemberDetailViewController *memeberDetailVC = [WTMemberDetailViewController new];
    //[self.navigationController pushViewController: memeberDetailVC animated: YES];
}

- (void)topicDetailHeadCell:(WTTopicDetailHeadCell *)topDetailHeadCell didClickiconImageViewWithTopicDetailVM:(WTTopicDetailViewModel *)topicDetailVM
{
    WTMemberDetailViewController *memeberDetailVC = [[WTMemberDetailViewController alloc] initWithtopicDetailVM: topicDetailVM];
    [self.navigationController pushViewController: memeberDetailVC animated: YES];
}

#pragma mark - WTTopicDetailContentCellDelegate
- (void)topicDetailContentCell:(WTTopicDetailContentCell *)contentCell didClickedWithLinkURL:(NSURL *)linkURL
{
    // 跳转至自定义的网页浏览器
    WTWebViewController *webViewVC = [WTWebViewController new];
    webViewVC.url = linkURL;
    [self.navigationController pushViewController: webViewVC animated: nil];
}

#pragma mark - WTTopicDetailContentCellDelegate
- (void)topicDetailCommentCell:(WTTopicDetailCommentCell *)cell iconImageViewClickWithTopicDetailVM:(WTTopicDetailViewModel *)topicDetailVM
{
    WTMemberDetailViewController *memeberDetailVC = [[WTMemberDetailViewController alloc] initWithtopicDetailVM: topicDetailVM];
    [self.navigationController pushViewController: memeberDetailVC animated: YES];

}

#pragma mark - dealloc
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

@end
