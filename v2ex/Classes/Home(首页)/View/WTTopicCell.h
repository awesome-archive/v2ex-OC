//
//  WTBlogCell.h
//  v2ex
//
//  Created by 无头骑士 GJ on 16/1/14.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WTTopic;
@interface WTTopicCell : UITableViewCell

/** Blog模型 */
@property (nonatomic, strong) WTTopic            *topic;

/**
 *  快速创建的类方法
 *
 *  @param tableView tableView
 *
 *  @return WTBlogCell
 */
+ (instancetype)cellWithTableView:(UITableView *)tableView;



@end
