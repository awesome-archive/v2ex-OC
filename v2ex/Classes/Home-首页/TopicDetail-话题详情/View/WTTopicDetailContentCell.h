//
//  WTTopicDetailContentCell.h
//  v2ex
//
//  Created by 无头骑士 GJ on 16/3/13.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//  帖子详情

#import <UIKit/UIKit.h>
@class WTTopicDetailViewModel, WTTopicDetailContentCell;

@protocol WTTopicDetailContentCellDelegate <NSObject>

// 点击帖子详情的链接
- (void)topicDetailContentCell:(WTTopicDetailContentCell *)contentCell didClickedWithLinkURL:(NSURL *)linkURL;

- (void)topicDetailContentCell:(WTTopicDetailContentCell *)contentCell didClickedWithContentImages:(NSMutableArray *)images currentIndex:(NSUInteger)currentIndex;
@end

@interface WTTopicDetailContentCell : UITableViewCell

@property (nonatomic, strong) WTTopicDetailViewModel *topicDetailVM;

/** cell的高度 */
@property (nonatomic, assign) CGFloat                cellHeight;

@property (nonatomic, weak) id<WTTopicDetailContentCellDelegate> delegate;
/** webView加载完成的block */
@property (nonatomic, copy) void(^updateCellHeightBlock)(CGFloat height);
@end
