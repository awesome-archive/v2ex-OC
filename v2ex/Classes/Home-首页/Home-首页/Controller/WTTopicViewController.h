//
//  WTBlogViewController.h
//  v2ex
//
//  Created by 无头骑士 GJ on 16/1/14.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum  {
    WTTopicTypeNormal       = 0,        // 普通
    WTTopicTypeCollection   = 1,        // 收藏
    
} WTTopicType;

@class WTNode;
@interface WTTopicViewController : UITableViewController
/** url地址 */
@property (nonatomic, strong) NSString          *urlString;
/** 帖子类型 */
@property (nonatomic, assign) WTTopicType       topicType;
@end
