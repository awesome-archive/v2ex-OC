//
//  WTTopicDetailContentCell.h
//  v2ex
//
//  Created by 无头骑士 GJ on 16/3/13.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WTTopicDetailViewModel, WTTopicDetailContentCell;

@protocol WTTopicDetailContentCellDelegate <NSObject>

- (void)topicDetailContentCell:(WTTopicDetailContentCell *)contentCell didClickedWithLinkURL:(NSURL *)linkURL;

@end

@interface WTTopicDetailContentCell : UITableViewCell

@property (nonatomic, strong) WTTopicDetailViewModel *topicDetailVM;

@property (nonatomic, assign) CGFloat                cellHeight;

@property (nonatomic, weak) id<WTTopicDetailContentCellDelegate> delegate;

@property (nonatomic, copy) void(^updateCellHeightBlock)(CGFloat height);
@end
