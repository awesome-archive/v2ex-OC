//
//  WTNoLoginView.m
//  v2ex
//
//  Created by 无头骑士 GJ on 2017/4/22.
//  Copyright © 2017年 无头骑士 GJ. All rights reserved.
//

#import "WTNoLoginView.h"
#import "WTLoginViewController.h"
#import "UIViewController+Extension.h"
@interface WTNoLoginView()
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@end
@implementation WTNoLoginView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.loginBtn.layer.cornerRadius = 5;
    self.loginBtn.backgroundColor = WTSelectedColor;
    [self.loginBtn setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
    [self.loginBtn addTarget: self action: @selector(loginBtnClick) forControlEvents: UIControlEventTouchUpInside];
}
- (void)loginBtnClick
{
    WTLoginViewController *loginVC = [WTLoginViewController new];
    [[UIViewController topVC] presentViewController: loginVC animated: YES completion: nil];
}

@end
