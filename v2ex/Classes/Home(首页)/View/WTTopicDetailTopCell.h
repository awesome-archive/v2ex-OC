//
//  WTTopicDetailTopCell.h
//  v2ex
//
//  Created by 无头骑士 GJ on 16/3/2.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WTTopicDetail, WTTopicDetailTopCell;

typedef NS_ENUM(NSUInteger, TextLabelType) {
    TextLabelTypeLink = 0,
    TextLabelTypeImage,
};

@protocol WTTopicDetailTopCellDelegate <NSObject>

@optional
- (void)topicDetailTopCell:(WTTopicDetailTopCell *)topicDetailTopCell DidClickedIconWithTopicDetail:(WTTopicDetail *)topicDetail;
- (void)topicDetailTopCell:(WTTopicDetailTopCell *)topicDetailTopCell DidClickedTextLabelWithType:(TextLabelType)type info:(NSDictionary *)info;
@end

@interface WTTopicDetailTopCell : UITableViewCell
/** 评论模型 */
@property (nonatomic, strong) WTTopicDetail               *topicDetail;

/** 代理 */
@property (nonatomic, weak) id<WTTopicDetailTopCellDelegate> delegate;
@end
