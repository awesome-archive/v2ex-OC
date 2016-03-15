//
//  WTTopicToolBarView.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/2/19.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTToolBarView.h"
#import "WTTopicDetailViewModel.h"
#import "SVProgressHUD.h"
@interface WTToolBarView()
/** 上一页按钮 */
@property (weak, nonatomic) IBOutlet UIButton           *prevButton;
/** 下一页按钮 */
@property (weak, nonatomic) IBOutlet UIButton           *nextButton;
/** 最大页数 */
@property (nonatomic, assign) NSInteger                 maxPage;
/** 页数Label */
@property (weak, nonatomic) IBOutlet UILabel            *pageLabel;
/** 加入收藏和取消收藏 */
@property (weak, nonatomic) IBOutlet UIButton           *collectionButton;
@property (weak, nonatomic) IBOutlet UIButton *thankButton;

@end

@implementation WTToolBarView

/**
 *  快速创建的类方法
 *
 */
+ (instancetype)toolBarView
{
    return [[NSBundle mainBundle] loadNibNamed: NSStringFromClass(self) owner: nil options: nil].lastObject;
}

- (void)setTopicDetailVM:(WTTopicDetailViewModel *)topicDetailVM
{
    _topicDetailVM = topicDetailVM;
    
    // 当前页数
    NSUInteger page = [topicDetailVM.floorText integerValue] / 100 + 1;
    self.pageLabel.text = [NSString stringWithFormat: @"%zd", page];
    
    // 记录话题的最大页数
    if (self.maxPage == 0)
    {
        self.maxPage = page;
    }

    // 收藏按钮
    self.collectionButton.selected = [topicDetailVM.collectionUrl containsString: @"unfavorite"];

    // 喜欢的按钮状态判断
    if (topicDetailVM.thankType == WTThankTypeAlready)
    {
        self.thankButton.selected = YES;
    }
    else if(topicDetailVM.thankType == WTThankTypeUnknown)
    {
        self.thankButton.enabled = YES;
    }
    else
    {
        self.thankButton.selected = NO;
        self.thankButton.enabled = YES;
    }
}

#pragma mark - 初始化
- (void)awakeFromNib
{
    self.backgroundColor = [UIColor colorWithHexString: @"#292A2A"];
    
    // 1、KVO，监听 self.pageLabel的text属性的值的变化
    [self.pageLabel addObserver: self forKeyPath: @"text" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context: nil];
}
#pragma mark - toolBar上各个按钮的点击事件
- (IBAction)toolBarBtnClick:(UIButton *)sender
{
    NSUInteger tag = sender.tag;
    if (tag == 0)
    {
        if (_topicDetailVM.thankType == WTThankTypeAlready)
        {
            [SVProgressHUD showErrorWithStatus: @"不能取消感谢" maskType: SVProgressHUDMaskTypeBlack];
            return;
        }
        else if(_topicDetailVM.thankType == WTThankTypeUnknown)
        {
            [SVProgressHUD showErrorWithStatus: @"未知原因不能感谢" maskType: SVProgressHUDMaskTypeBlack];
            return;
        }
    }
    
    NSDictionary *userInfo = @{@"buttonType" : @(sender.tag)};
    [[NSNotificationCenter defaultCenter] postNotificationName: WTToolBarButtonClickNotification object: nil userInfo:userInfo];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    // 1、获取新值
    NSInteger new = [[change objectForKey: @"new"] integerValue];
    
    // 2、根据新值的变化，来设置上一页和下一页的激活状态
    self.prevButton.enabled = new != 1;
    self.nextButton.enabled = new < self.maxPage;
}

#pragma mark - dealloc
- (void)dealloc
{
    // 移除KVO
    [self.pageLabel removeObserver: self forKeyPath: @"text"];
}

@end
