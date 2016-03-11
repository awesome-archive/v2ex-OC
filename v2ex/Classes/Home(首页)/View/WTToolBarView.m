//
//  WTTopicToolBarView.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/2/19.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTToolBarView.h"
#import "WTTopicDetail.h"
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



/**
 *  更新pageLabel的值
 */
- (void)updatePageLabel:(NSInteger)page
{
    // 1、设置评论页数的最大值，只有第一次才设置
    if (self.maxPage == 0)
    {
        self.maxPage = page;
    }

    self.pageLabel.text = [NSString stringWithFormat: @"%ld", page];
}

- (void)setTopicDetail:(WTTopicDetail *)topicDetail
{
    _topicDetail = topicDetail;
    
    // 1、设置是加入收藏或取消收藏
    self.collectionButton.selected = topicDetail.isCollection;
    // 2、设置是感谢或已经感谢
    self.loveButton.selected = topicDetail.isLove;
    self.loveButton.enabled = !self.loveButton.isSelected;
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
    if ([self.delegate respondsToSelector: @selector(toolBarView:didClickedAtIndex:)])
    {
        [self.delegate toolBarView: self didClickedAtIndex: sender.tag];
    }
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
