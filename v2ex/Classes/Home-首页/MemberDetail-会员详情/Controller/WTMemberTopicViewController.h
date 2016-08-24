//
//  WTMemberTopicViewController.h
//  v2ex
//
//  Created by gengjie on 16/8/24.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "YZPersonTableViewController.h"
@class WTTopicDetailViewModel;
@interface WTMemberTopicViewController : YZPersonTableViewController
@property (nonatomic, strong) WTTopicDetailViewModel *topicDetailVM;
@end
