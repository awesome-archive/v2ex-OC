//
//  WTConversationListViewController.m
//  v2ex
//
//  Created by gengjie on 2016/10/21.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTConversationListViewController.h"
#import "WTConversationViewController.h"
@interface WTConversationListViewController ()

@end

@implementation WTConversationListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"消息";
    
    //设置需要显示哪些类型的会话
    [self setDisplayConversationTypes:@[@(ConversationType_PRIVATE)]];
    
    self.conversationListTableView.tableFooterView = [UIView new];
}

//重写RCConversationListViewController的onSelectedTableRow事件
- (void)onSelectedTableRow:(RCConversationModelType)conversationModelType conversationModel:(RCConversationModel *)model atIndexPath:(NSIndexPath *)indexPath
{
    WTConversationViewController  *conversationVC = [[WTConversationViewController alloc] initWithConversationType: model.conversationType targetId: model.targetId];
    conversationVC.title = @"想显示的会话标题";
    [self.navigationController pushViewController:conversationVC animated:YES];
}

@end
