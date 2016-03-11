//
//  WTtopicDetailViewController.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/1/17.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//  话题详情控制器

#import "WTTopicDetailViewController.h"
#import "WTTopicViewModel.h"
#import "WTTopicTool.h"
#import "WTTopicDetail.h"
#import "WTCommentCell.h"
#import "WTToolBarView.h"
#import "SVProgressHUD.h"
#import "WTTipView.h"
#import "WTAccount.h"
#import "WTLoginViewController.h"
#import "WTPostReplyViewController.h"
#import "WTNavigationController.h"
#import "WTMeViewController.h"
#import "WTTopicDetailTopCell.h"
#import "NSString+Regex.h"
#import "Masonry.h"
#import <SafariServices/SafariServices.h>
#import "UIDevice+YYAdd.h"
#import "PhotoBrowserViewController.h"
NS_ASSUME_NONNULL_BEGIN

static NSString * const commentID = @"commentCell";
static NSString * const topID = @"topCell";

@interface WTTopicDetailViewController () <UITableViewDataSource, UITableViewDelegate, WTToolBarViewDelegate, WTCommentCellDelegate, WTTopicDetailTopCellDelegate>

/** 作者博客详情 */
@property (nonatomic, strong) WTTopicDetail                              *topicDetail;
/** 评论数组 */
@property (nonatomic, strong) NSMutableArray<WTTopicDetail *>            *topicDetails;
/** 工具条View */
@property (nonatomic, weak) WTToolBarView                                *toolBarView;
/** 当前的页数 */
@property (nonatomic, assign) NSInteger                                  currentPage;
/** tableView */
@property (weak, nonatomic) IBOutlet UITableView                         *tableView;
/** 没有登陆的View */
@property (weak, nonatomic) IBOutlet UIView                              *loginView;
/** 提示框View */
@property (nonatomic, weak) WTTipView                                    *tipView;
/** 回复帖子的url */
@property (nonatomic, strong) NSString                                   *postReplyUrl;

@property (weak, nonatomic) IBOutlet UIView                              *normalView;
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
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // 查看本主题需要登录 http://www.v2ex.com/signin?next=/t/257500#reply7
    // 格式乱了1：http://www.v2ex.com/t/257543#reply12
    // 作者话题特别多的: http://www.v2ex.com/t/219639#reply40
    // 评论超过100条的: http://www.v2ex.com/t/257223#reply184
    // 图文混排：http://www.v2ex.com/t/259763#reply1  http://www.v2ex.com/t/260116#reply22
    // 高清大图 http://www.v2ex.com/t/182335#reply307
    // 时间显示不正确的
    // self.topic.detailUrl = @"http://www.v2ex.com/t/259763#reply1";
    // 未使用markdown语法的URL http://www.v2ex.com/t/260316
    // 使用 ```objc 节点 http://www.v2ex.com/t/261197#reply21
    // 如果未登陆的话，查看本主题需要登陆
    //self.topic.detailUrl = @"http://www.v2ex.com/t/249449#reply1";
    //self.topic.detailUrl = @"http://www.v2ex.com/t/182335#reply307";
    // 带gif动图的 http://www.v2ex.com/t/261117#reply5
    /*
     
        测试图文的帐号
        http://www.v2ex.com/t/261303#reply24
     
     
        测试3页的数据，其中还没有解决的网址 ：
        http://www.v2ex.com/t/261582#reply103
        http://www.v2ex.com/t/260380#reply37
        http://www.v2ex.com/t/261778#reply2
        http://www.v2ex.com/t/261761#reply0 &gt;            解决
        http://www.v2ex.com/t/261723#reply10 *的问题         解决
        http://www.v2ex.com/t/261699#reply2 *的缩进问题       解决
        http://www.v2ex.com/t/261387#reply11 重复的问题       解决
     */
    //self.topic.detailUrl = @"http://www.v2ex.com/t/259763#reply1";
    
    //self.topic.detailUrl = @"http://www.v2ex.com/t/262493#reply28";
    
    // 初始化View
    [self setupView];
    
    // 初始化数据
    [self setupData];
    
    self.postReplyUrl = self.topicViewModel.topicDetailUrl;
}

#pragma mark - 初始化View
- (void)setupView
{    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // 1、tableView相关设置
    {
        // 1、注册Cell
        [self.tableView registerNib: [UINib nibWithNibName: NSStringFromClass([WTCommentCell class]) bundle: nil] forCellReuseIdentifier: commentID];
        [self.tableView registerNib: [UINib nibWithNibName: NSStringFromClass([WTTopicDetailTopCell class]) bundle: nil] forCellReuseIdentifier: topID];
        
        // 2、设置 tableView的内边距
        self.tableView.contentInset = UIEdgeInsetsMake(WTNavigationBarHeight + WTStatusBarHeight, 0, WTToolBarHeight, 0);
        // 3、设置 滑动条的内边距
        self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
        
        // 4、设置自动布局 self-sizing
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 100;
    }
    
    // 2、初始化工具条
    [self toolBarView];
    
    // 3、设置导航栏的属性
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed:@"nav_share_normal"] style: UIBarButtonItemStyleDone target: self action: @selector(shareClick)];
}

/**
 *  操作完成之后
 */
- (void)operationCompleteWithTopicDetail:(WTTopicDetail *)authorTopicDetail;
{
    [SVProgressHUD dismiss];
    self.topicDetail = authorTopicDetail;
    [self setupToolBarViewData];
}

- (BOOL)isLogin
{
    if (![[WTAccount shareAccount] isLogin])
    {
        WTLoginViewController *loginVC = [WTLoginViewController new];
        loginVC.loginSuccessBlock = ^{
            [SVProgressHUD show];
            
            [WTTopicTool addOrCancelCollectionTopicWithUrlString: self.topicDetail.collectionUrl topicDetailUrl: self.topicViewModel.topicDetailUrl success:^(WTTopicDetail *authorTopicDetail) {
                
                // 2、隐藏等待框，并刷新页面
                [self operationCompleteWithTopicDetail: authorTopicDetail];
                
            } failure:^(NSError *error) {
                [SVProgressHUD dismiss];
            }];
        };
        [self presentViewController: loginVC animated: YES completion: nil];
        return false;
    }
    return true;
}
#pragma mark - 初始化数据
- (void)setupData
{
    
    
    if (self.currentPage != 0)
    {
        NSString *url = self.topicViewModel.topicDetailUrl;
        NSRange range = [url rangeOfString: @"#" options: NSBackwardsSearch];
        // 说明没查找到#号
        if (range.location > url.length)
        {
            range = [url rangeOfString: @"=" options: NSBackwardsSearch];
            url = [url substringToIndex: range.location];
            self.topicViewModel.topicDetailUrl = [url stringByAppendingFormat: @"=%ld", self.currentPage];
        }
        else
        {
            url = [url substringToIndex: range.location];
            self.topicViewModel.topicDetailUrl = [url stringByAppendingFormat: @"?p=%ld", self.currentPage];
        }
        
    }
    
    [SVProgressHUD show];
    
    // 获取详情页信息
    [WTTopicTool getTopicDetailWithUrlString: self.topicViewModel.topicDetailUrl success:^(NSArray *topicDetailArray) {
        
        [SVProgressHUD dismiss];
        
        // 1、说明需要登陆或其他原因
        if (topicDetailArray.count == 0)
        {
            self.loginView.hidden = NO;
            self.normalView.hidden = YES;
            return;
        }
        
        // 3、刷新评论
        self.topicDetails = [NSMutableArray array];
        [self.topicDetails addObjectsFromArray: topicDetailArray];
        [self.tableView reloadData];
        
        // 4、刷新工具条
        [self operationCompleteWithTopicDetail: self.topicDetails.firstObject];
        
        // 5、让tableView回到顶部
        [self.tableView setContentOffset: CGPointMake(0, -(WTNavigationBarHeight + WTStatusBarHeight)) animated: YES];
        
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow: 0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
       // WTLog(@"self.tableView:%@----%lf", self.tableView , WTNavigationBarHeight + WTStatusBarHeight)
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
}

/**
 *  刷新工具条View的数据
 *
 */
- (void)setupToolBarViewData
{
    NSInteger page = 1;
//    if (self.topicDetails.count > 0) {

//        WTTopicDetail *topicDetail = self.topicDetails[0];
        page = self.topicDetail.floor / 100 + 1;
//    }
    // 更新页数
    [self.toolBarView updatePageLabel: page];
    
    // 记录当前的页数
    self.currentPage = page;
    
    self.toolBarView.topicDetail = self.topicDetail;
}
#pragma mark - WTCommentCellDelegate
- (void)commentCell:(WTCommentCell *)cell DidClickedIconWithTopicDetail:(WTTopicDetail *)topicDetail
{
    [self goToUserInfoVC: topicDetail];
}


#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.topicDetails.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WTTopicDetailTopCell *cell = nil;
    
    if (indexPath.row == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier: topID];
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier: commentID];
        
    }
    WTTopicDetail *topicDetail = self.topicDetails[indexPath.row];
    cell.delegate = self;
    cell.topicDetail = topicDetail;
    return cell;
}

#pragma mark - WTTopicDetailTopCellDelegate
- (void)topicDetailTopCell:(WTTopicDetailTopCell *)topicDetailTopCell DidClickedIconWithTopicDetail:(WTTopicDetail *)topicDetail
{
    [self goToUserInfoVC: topicDetail];
}

- (void)topicDetailTopCell:(WTTopicDetailTopCell *)topicDetailTopCell DidClickedTextLabelWithType:(TextLabelType)type info:(NSDictionary *)info
{
    switch (type) {
        case TextLabelTypeLink:
        {
            SFSafariViewController *vc = [[SFSafariViewController alloc] initWithURL: [NSURL URLWithString: info[@"linkUrl"]]];
            [self.navigationController pushViewController: vc animated: YES];
            break;
        }
        case TextLabelTypeImage:
        {
            PhotoBrowserViewController *vc = [[PhotoBrowserViewController alloc] init];
            vc.imageUrls = info[@"imageUrls"];
            vc.clickImageUrl = info[@"clickImageUrl"];
            [self presentViewController: vc animated: YES completion: nil];
            break;
        }
        default:
            break;
    }
}

#pragma mark - WTToolBarViewDelegate
- (void)toolBarView:(WTToolBarView *)toolBarView didClickedAtIndex:(WTToolBarButtonType)index
{
    switch (index) {
        case WTToolBarButtonTypeLove:           // 喜欢
            [self love];
            break;
        case WTToolBarButtonTypeCollection:     // 收藏
            [self collection];
            break;
        case WTToolBarButtonTypePrev:           // 上一页
            [self prev];
            break;
        case WTToolBarButtonTypeNext:           // 下一页
            [self next];
            break;
        case WTToolBarButtonTypeSafari:         //  safari
            [self safari];
            break;
        case WTToolBarButtonTypeReply:          // 回复
            [self reply];
            break;
    }
}

#pragma mark - 点击事件
#pragma mark 登陆
- (IBAction)loginButtonClick
{
    WTLoginViewController *loginVC = [WTLoginViewController new];
    loginVC.loginSuccessBlock = ^{
        
        self.loginView.hidden = YES;
        self.normalView.hidden = NO;
        [self setupData];
    };
    [self presentViewController: loginVC animated: YES completion: nil];
}
#pragma mark 喜欢
- (void)love
{
    if (![self isLogin] || self.toolBarView.loveButton.isSelected) {
        return;
    }
    
    // 1、对话框
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle: @"" message: @"你确定要向本主题创建者发送谢意？" preferredStyle: UIAlertControllerStyleAlert];
    
    // 确定按钮
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle: @"确定" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [SVProgressHUD show];
        [WTTopicTool loveTopicWithUrlString: self.topicDetail.loveUrl topicDetailUrl: self.topicViewModel.topicDetailUrl success:^(WTTopicDetail *authorTopicDetail) {
            
            [self.tipView showTipViewWithTitle: @"感谢已发送"];
            self.toolBarView.loveButton.selected = YES;
            [self operationCompleteWithTopicDetail: authorTopicDetail];
        
        } failure:^(NSError *error) {
            [SVProgressHUD dismiss];
        }];
    }];
    // 取消按钮
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle: @"取消" style: UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        // 取消就什么都不做
    }];
    [alertController addAction: sureAction];
    [alertController addAction: cancelAction];
    [self presentViewController: alertController animated: YES completion: nil];
}

#pragma mark 收藏
- (void)collection
{
    if (![self isLogin]) {
        return;
    }
    
    [SVProgressHUD show];
    
    [WTTopicTool addOrCancelCollectionTopicWithUrlString: self.topicDetail.collectionUrl topicDetailUrl: self.topicViewModel.topicDetailUrl success:^(WTTopicDetail *authorTopicDetail) {
       
        // 1、展示提示框
        if ([self.topicDetail.collectionUrl containsString: @"unfavorite"])
        {
             [self.tipView showTipViewWithTitle: @"已取消收藏"];
        }
        else
        {
            [self.tipView showTipViewWithTitle: @"加入收藏成功"];
        }
        
        // 2、隐藏等待框，并刷新页面
        [self operationCompleteWithTopicDetail: authorTopicDetail];
        
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
}

#pragma mark 上一页
- (void)prev
{
    self.currentPage --;
    [self setupData];
}

#pragma mark 下一页
- (void)next
{
    self.currentPage ++;
    [self setupData];
}

#pragma mark 刷safari
- (void)safari
{
//    if ([UIDevice systemVersion] >= 9.0)
//    {
//        SFSafariViewController *vc = [[SFSafariViewController alloc] initWithURL: [NSURL URLWithString: self.topic.detailUrl]];
//        [self.navigationController pushViewController: vc animated: NO];
//        return;
//    }
//    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: self.topic.detailUrl]];

    [self setupData];
}

#pragma mark 回复话题
- (void)reply
{
    if (![self isLogin] || self.toolBarView.loveButton.isSelected) {
        return;
    }
    
    // 发表回复控制器
    WTPostReplyViewController *postReplyVC = [WTPostReplyViewController new];
    WTNavigationController *nav = [[WTNavigationController alloc] initWithRootViewController: postReplyVC];
    WTTopicDetail *topicDetail = self.topicDetails.firstObject;
    postReplyVC.once = topicDetail.once;
    postReplyVC.urlString = [NSString subStringWithStr: @"#" string: self.postReplyUrl];
    postReplyVC.completionBlock = ^(BOOL isSuccess){
        
        if (isSuccess)
        {
            [self.tipView showTipViewWithTitle: @"回复成功"];
        }
        else
        {
            [self.tipView showTipViewWithTitle: @"回复失败"];
        }
        [self setupData];
    };
    [self presentViewController: nav animated: YES completion: nil];
}

#pragma mark 分享
- (void)shareClick
{
    WTLog(@"shareClick")
}

#pragma mark - 跳转至自用户信息控制器
- (void)goToUserInfoVC:(WTTopicDetail *)topicDetail
{
    WTMeViewController *meVC = [WTMeViewController new];
    meVC.username = topicDetail.author;
    [self.navigationController pushViewController: meVC animated: YES];
}

#pragma mark - 懒加载
- (WTToolBarView *)toolBarView
{
    if (_toolBarView == nil)
    {
        // 1、创建toolBarView
        WTToolBarView *toolBarView = [WTToolBarView toolBarView];
        [self.normalView addSubview: toolBarView];
        _toolBarView = toolBarView;
        
        // 2、设置位置大小、代理
        toolBarView.delegate = self;
       // CGFloat y = WTScreenHeight - WTToolBarHeight;
//        toolBarView.frame = CGRectMake(0, y, WTScreenWidth, WTToolBarHeight);
        [toolBarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.normalView.mas_left).offset(0);
            make.right.equalTo(self.normalView.mas_right).offset(0);
            make.bottom.equalTo(self.normalView.mas_bottom).offset(0);
            make.height.equalTo(@44);
        }];
        
    }
    return _toolBarView;
}
- (WTTipView *)tipView
{
    if (_tipView == nil)
    {
        WTTipView *tipView = [WTTipView wt_viewFromXib];
        [self.navigationController.navigationBar insertSubview: tipView atIndex: 0];
        _tipView = tipView;

        tipView.frame = CGRectMake(0, -64, WTScreenWidth, 44);
    }
    return _tipView;
}
#pragma mark - dealloc
- (void)dealloc
{
    [SVProgressHUD dismiss];
    [self.tipView removeFromSuperview];
    WTLog(@"WTTopicDetailViewController销毁")
}

@end
NS_ASSUME_NONNULL_END