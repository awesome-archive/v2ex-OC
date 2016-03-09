//
//  WTTopicToolBarView.h
//  v2ex
//
//  Created by 无头骑士 GJ on 16/2/19.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WTToolBarView, WTTopicDetail;

// toolBarView 各个按钮的tag
typedef NS_ENUM(NSInteger, WTToolBarButtonType) {
    WTToolBarButtonTypeLove = 0,        // 喜欢
    WTToolBarButtonTypeCollection,      // 收藏
    WTToolBarButtonTypePrev,            // 上一页
    WTToolBarButtonTypeNext,            // 下一页
    WTToolBarButtonTypeSafari,          // safari
    WTToolBarButtonTypeReply            // 回复
};

@protocol WTToolBarViewDelegate <NSObject>
@required
/**
 *  toolBarButton的点击
 *
 *  @param toolBarView toolBarView
 *  @param index       被点击的按钮tag
 */
- (void)toolBarView:(WTToolBarView *)toolBarView didClickedAtIndex:(WTToolBarButtonType)index;
@end

@interface WTToolBarView : UIView


@property (nonatomic, strong) WTTopicDetail          *topicDetail;

/** 感谢和已经感谢  */
@property (weak, nonatomic) IBOutlet UIButton        *loveButton;

/** 代理 */
@property (nonatomic, weak)id<WTToolBarViewDelegate> delegate;

/**
 *  快速创建的类方法
 *
 */
+ (instancetype)toolBarView;

/**
 *  更新pageLabel的值
 */
- (void)updatePageLabel:(NSInteger)page;

@end
