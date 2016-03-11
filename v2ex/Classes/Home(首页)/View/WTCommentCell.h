//
//  WTCommentCell.h
//  v2ex
//
//  Created by 无头骑士 GJ on 16/2/18.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WTTopicDetail, WTCommentCell;

@protocol WTCommentCellDelegate <NSObject>

@optional
- (void)commentCell:(WTCommentCell *)cell DidClickedIconWithTopicDetail:(WTTopicDetail *)topicDetail;

@end

@interface WTCommentCell : UITableViewCell

/** 评论模型 */
@property (nonatomic, strong) WTTopicDetail           *topicDetail;
/** 代理 */
@property (nonatomic, weak) id<WTCommentCellDelegate> delegate;

@end
