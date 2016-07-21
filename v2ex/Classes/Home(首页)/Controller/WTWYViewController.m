//
//  WTWYViewController.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/1/30.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//  网易新闻架构 控制器

#import "WTWYViewController.h"
NS_ASSUME_NONNULL_BEGIN

#define WTColorButton(r , g ,b) [UIColor colorWithRed:(r)  green:(g)  blue:(b) alpha:1]

@interface WTWYViewController () <UIScrollViewDelegate>
/** 标题scrollView */
@property (nonatomic, strong) UIScrollView                  *titleScrollView;
/** 内容scrollView */
@property (nonatomic, strong) UIScrollView                  *contentScrollView;
/** WTNode数组*/
@property (nonatomic, strong) NSArray<WTNode *>             *nodes;
/** 标题按钮数组 */
@property (nonatomic, strong) NSMutableArray<UIButton *>    *titleButtons;
/** 当前被选中的按钮 */
@property (nonatomic, strong) UIButton                      *selectedBtn;
/** 标识符是否是第一次进入 */
@property (nonatomic, assign) BOOL                          isInitial;
@end

@implementation WTWYViewController

#pragma mark - 初始化
- (void)viewDidLoad
{
    [super viewDidLoad];

    //设置页面
    [self setupView];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 4.设置标题
    if (!_isInitial) {
        
        [self setupAllTitle];
        
        _isInitial = YES;
    }
    
}

#pragma mark - 设置页面
- (void)setupView
{
    // 设置内容滚动视图
    [self setupContentScrollView];
    
    // 设置标题滚动视图
    [self setupTitleScrollView];
    
    // 取消添加额外的滚动区域
    self.automaticallyAdjustsScrollViewInsets = NO;
}

#pragma mark 设置标题滚动视图
- (void)setupTitleScrollView
{
    // 标题滚动视图
    UIScrollView *titleScrollView = [UIScrollView new];
    [self.view addSubview: titleScrollView];
    self.titleScrollView = titleScrollView;
    
    // 是否有导航栏
    CGFloat y = self.navigationController.navigationBarHidden ? 20 : 64;
    //CGFloat y = 0;
    titleScrollView.frame = CGRectMake(0, y, WTScreenWidth, WTTitleViewHeight);
    
    titleScrollView.backgroundColor = [UIColor colorWithWhite: 1.0 alpha: 0.9];
}

#pragma mark 设置内容滚动视图
- (void)setupContentScrollView
{
    // 1、内容滚动视图
    UIScrollView *contentScrollView = [UIScrollView new];
    [self.view addSubview: contentScrollView];
    self.contentScrollView = contentScrollView;
    
    // 2、设置尺寸
    contentScrollView.frame = CGRectMake(0, 0, WTScreenWidth, WTScreenHeight);
    
    // 3、设置代理
    contentScrollView.delegate = self;
}

#pragma mark 设置标题
- (void)setupAllTitle
{
    // 1、标题按钮数组 初始化
    self.titleButtons = [NSMutableArray array];
    
    NSInteger count = self.nodes.count;
    
    // 2、添加标题按钮
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat w = 80;
    CGFloat h = self.titleScrollView.height;
    for (NSInteger i = 0; i < count; i++)
    {
        x = i * w;
        UIViewController *topicVC = self.childViewControllers[i];
        
        // 自定义按钮
        UIButton *btn = [UIButton buttonWithType: UIButtonTypeCustom];
        btn.frame = CGRectMake(x, y, w, h);
        [self.titleScrollView addSubview: btn];
        
        btn.tag = i;
        btn.titleLabel.font = [UIFont systemFontOfSize: 18];
        btn.backgroundColor = [UIColor clearColor];
        [btn setTitle: topicVC.title forState: UIControlStateNormal];
        [btn setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
        [btn addTarget: self action: @selector(titleClick:) forControlEvents: UIControlEventTouchDown];
        
        // 默认点击第一个按钮
        if (i == 0)
        {
            [self titleClick: btn];
        }
        
        // 添加titleButtons数组中
        [self.titleButtons addObject: btn];
    }
    
    [self changeButtonAttr: 0];
    [self scrollViewDidEndScrollingAnimation: self.contentScrollView];
    
    // 设置标题栏scrollView
    {
        self.titleScrollView.contentSize = CGSizeMake(count * w, 0);
        self.titleScrollView.showsHorizontalScrollIndicator = NO;
    }
    
    // 设置内容scrollView
    {
        self.contentScrollView.contentSize = CGSizeMake(count * WTScreenWidth, 0);
        self.contentScrollView.showsHorizontalScrollIndicator = NO;
        self.contentScrollView.pagingEnabled = YES;
        self.contentScrollView.bounces = NO;
    }
}

#pragma mark 标题栏标题点击事件
- (void)titleClick:(UIButton *)selectedBtn
{
    NSInteger currentIndex = selectedBtn.tag;
    
    // 1、设置选中按钮
    [self selectBtn: selectedBtn];
    
    // 2、设置滚动视图偏移量
    [self.contentScrollView setContentOffset: CGPointMake(currentIndex * WTScreenWidth, 0) animated: YES];
    
    // 3、添加一个子控制器的View
    //[self setupOneViewControllerView: currentIndex];
}

#pragma mark 选中按钮
- (void)selectBtn:(UIButton *)selectedBtn
{
    // 1、设置按钮颜色
    [self.selectedBtn setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
    [selectedBtn setTitleColor: [UIColor redColor] forState: UIControlStateNormal];
    
    // 2、让标题居中
    [self setupTitleButtonCenter: selectedBtn];
    
    // 4、赋值当前选中的按钮
    self.selectedBtn = selectedBtn;
}

#pragma mark 添加一个子控制器的View
- (void)setupOneViewControllerView:(NSInteger)currentIndex
{
    // 1、获取子控制器
    WTTopicViewController *topicVC = self.childViewControllers[currentIndex];
    
    // 2、判断view已经加入到contentView
    if (topicVC.view.superview) return;
    
    // 3、设置frame
    topicVC.view.frame = self.contentScrollView.bounds;
    
    [self.contentScrollView addSubview: topicVC.view];
}

#pragma mark 设置标题居中
- (void)setupTitleButtonCenter:(UIButton *)selectedBtn
{
    // 1、修改偏移量
    CGFloat offsetX = selectedBtn.center.x - WTScreenWidth * 0.5;
    
    // 2、处理最小偏移量
    if (offsetX < 0)
    {
        offsetX = 0;
    }
    // 3、处理最大偏移量
    CGFloat maxOffsetX = self.titleScrollView.contentSize.width - WTScreenWidth;
    if (offsetX > maxOffsetX)
    {
        offsetX = maxOffsetX;
    }
    
    // 4、设置偏移量
    [self.titleScrollView setContentOffset: CGPointMake(offsetX, 0) animated: YES];
}

#pragma mark - UIScrollViewDelegate
// 手指滑动的时候调用
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self changeButtonAttr: scrollView.contentOffset.x];
}

// 减速完成后调用
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollViewDidEndScrollingAnimation: scrollView];
}

// 当滚动视图动画完成后，调用该方法，如果没有动画，那么该方法将不被调用，动画为 setOffset
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    // NSLog(@"%s", __func__);
    // 1、获取当前的角标
    NSInteger currentIndex = scrollView.contentOffset.x / WTScreenWidth;
    
    // 2、获取标题栏中对应的按钮
    UIButton *selectedBtn = self.titleButtons[currentIndex];
    
    // 3、选中标题
    [self selectBtn: selectedBtn];
    
    // 4、添加对应子控制器的View
    [self setupOneViewControllerView: currentIndex];
    
    // 5、把其余的按钮设置成黑色
    for (UIButton *btn in self.titleButtons)
    {
        if (currentIndex != btn.tag)
        {
            [btn setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
            btn.transform = CGAffineTransformMakeScale(0.7, 0.7);
        }
    }
}

/**
 *  
 
 *
 *  @param offsetX scrollView的偏移量
 */
- (void)changeButtonAttr:(CGFloat)offsetX
{
    //NSLog(@"%s", __func__);
    // 1、获取左边按钮角标
    NSInteger leftIndex = offsetX / WTScreenWidth;
    
    // 2、获取右边按钮角标
    NSInteger rightIndex = leftIndex + 1;
    
    // 3、获取左边按钮
    UIButton *leftBtn = self.titleButtons[leftIndex];
    
    // 4、获取右边按钮
    UIButton *rightBtn;
    NSInteger count = self.titleButtons.count;
    // 4.1、防止滑动到最后一个按钮，数组越界
    if (rightIndex < count)
    {
        rightBtn = self.titleButtons[rightIndex];
    }
    
    // 5、计算右边按钮的偏移量
    CGFloat rightScale = offsetX / WTScreenWidth - leftIndex;
    
    // 6、计算左边按钮的偏移量
    CGFloat leftScale = 1 - rightScale;
    //WTLog(@"leftScale:%lf,rightScale:%lf",leftScale,rightScale);
    
    // 7、形变
    leftBtn.transform = CGAffineTransformMakeScale(leftScale * 0.3 + 0.7, leftScale * 0.3 + 0.7);
    rightBtn.transform = CGAffineTransformMakeScale(rightScale * 0.3 + 0.7, rightScale * 0.3 + 0.7);
    
    // 8、变颜色
    [leftBtn setTitleColor: WTColorButton(leftScale, 0, 0) forState: UIControlStateNormal];
    [rightBtn setTitleColor: WTColorButton(rightScale, 0, 0) forState: UIControlStateNormal];
}

@end
NS_ASSUME_NONNULL_END