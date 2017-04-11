//
//  WTPublishTopicViewController.m
//  v2ex
//
//  Created by 无头骑士 GJ on 2017/4/9.
//  Copyright © 2017年 无头骑士 GJ. All rights reserved.
//

#import "WTPublishTopicViewController.h"
#import "UITextView+Placeholder.h"

@interface WTPublishTopicViewController ()
/** 标题 */
@property (weak, nonatomic) IBOutlet UITextField *titleTextF;
/** 正文　*/
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;

@end

@implementation WTPublishTopicViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.contentTextView.placeholder = @"请输入正文";
    self.contentTextView.placeholderColor = [UIColor grayColor];
}


@end
