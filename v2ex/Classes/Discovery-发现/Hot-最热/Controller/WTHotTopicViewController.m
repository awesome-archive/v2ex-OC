//
//  WTDiscoveryViewController.m
//  v2ex
//
//  Created by 无头骑士 GJ on 2017/7/7.
//  Copyright © 2017年 无头骑士 GJ. All rights reserved.
//

#import "WTHotTopicViewController.h"
#import "WTTopicViewController.h"

#import "WTSearchTopicCell.h"

#import "WTURLConst.h"
#import "WTHotTopicViewModel.h"

#import "UIViewController+Extension.h"

#import "NSString+YYAdd.h"
#import "Masonry.h"

static NSString * const WTSearchTopicCellIdentifier = @"WTSearchTopicCellIdentifier";

@interface WTHotTopicViewController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

/************************* 控件 *************************/
/** 最近话题tableView的ContentView */
@property (weak, nonatomic) IBOutlet UIView *topicContentView;
/** 加载的View */
@property (weak, nonatomic) IBOutlet UIView *loadingView;
/** 搜索话题的tableView */
@property (weak, nonatomic) IBOutlet UITableView *tableView;
/** 搜索栏 */
@property (nonatomic, weak) UISearchBar *searchBar;

/************************* 控制器 *************************/
/** 话题控制器 */
@property (nonatomic, weak) WTTopicViewController *topicVC;

/************************* 数据源 *************************/
/** 搜索话题数组*/
@property (nonatomic, strong) NSMutableArray<WTSearchTopic *> *searchTopics;

@end

@implementation WTHotTopicViewController

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 1、初始化View
    [self initView];
    
    // 2、添加子控制器
    [self addChildViewControllers];
    
    
}

#pragma mark - Private
#pragma mark 初始化View
- (void)initView
{
    // 1、初始化导航栏
    [self navView];
    
    // 2、添加搜索导航栏
    {
        UISearchBar *searchBar = [[UISearchBar alloc] init];
        searchBar.placeholder = @"搜索";
        searchBar.delegate = self;
        self.searchBar = searchBar;
        searchBar.searchBarStyle = UISearchBarStyleMinimal;
        [self.nav_View addSubview: searchBar];
        [searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.center.offset(10);
            make.left.offset(10);
            make.right.offset(-10);
            
        }];
    }
    
    // 3、搜索话题的tableView
    {
        // 注册Cell
        [self.tableView registerNib: [UINib nibWithNibName: NSStringFromClass([WTSearchTopicCell class])  bundle: nil] forCellReuseIdentifier: WTSearchTopicCellIdentifier];
        
        // 自动布局
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 100;
        
    }
}

#pragma mark 添加子控制器
- (void)addChildViewControllers
{
    // 1、话题控制器
    WTTopicViewController *vc = [WTTopicViewController new];
    vc.urlString = [WTHTTPBaseUrl stringByAppendingString: @"/recent"];
    [self addChildViewController: vc];
    [self.topicContentView addSubview: vc.view];
    vc.view.frame = self.topicContentView.bounds;
    vc.view.y = vc.view.y - 20;
}

#pragma mark 搜索话题
- (void)searchTopicWithKeywords:(NSString *)keywords
{
    [self.view bringSubviewToFront: self.loadingView];
 
    __weak typeof(self) weakSelf = self;
    void (^successBlock)(NSMutableArray<WTSearchTopic *> *searchTopics) = ^(NSMutableArray<WTSearchTopic *> *searchTopics){
    
        weakSelf.searchTopics = searchTopics;
        
        [weakSelf.view bringSubviewToFront: weakSelf.tableView];
    
        [weakSelf.tableView reloadData];
    };
    
    void(^failureBlock)(NSError *error) = ^(NSError *error){
    
    };
    
    WTSearchTopicReq *req = [WTSearchTopicReq new];
    req.keywords = keywords;
    [WTHotTopicViewModel searchTopicWithSearchTopicReq: req success: successBlock failure: failureBlock];
}

#pragma mark - UISearchBar delegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *keywords = self.searchBar.text;
    if ([[keywords stringByTrim] isEqualToString: @""]) return;
    
    [self.view endEditing: YES];
    
    // 搜索话题
    [self searchTopicWithKeywords: keywords];
    
}

#pragma mark - UITableView datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchTopics.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WTSearchTopicCell *cell = [tableView dequeueReusableCellWithIdentifier: WTSearchTopicCellIdentifier];
    
    cell.searchTopic = [self.searchTopics objectAtIndex: indexPath.row];
    
    return cell;
}

@end
