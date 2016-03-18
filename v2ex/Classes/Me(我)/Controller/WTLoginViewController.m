//
//  WTLoginViewController.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/2/23.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTLoginViewController.h"
#import "WTAccountViewModel.h"
#import "WTTipView.h"

@interface WTLoginViewController ()
/** 用户名或邮箱 */
@property (weak, nonatomic) IBOutlet UITextField    *usernameOrEmailTextField;
/** 密码 */
@property (weak, nonatomic) IBOutlet UITextField    *passwordTextField;
/** 登陆按钮 */
@property (weak, nonatomic) IBOutlet UIButton       *loginButton;
/** 提示框View */
@property (nonatomic, weak) WTTipView               *tipView;

@end

@implementation WTLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 测试代码
    self.loginButton.userInteractionEnabled = YES;

    // 1、添加圆角
    self.loginButton.layer.cornerRadius = 3;
    
    // 2、添加正在编辑监听事件
    [self.usernameOrEmailTextField addTarget: self action: @selector(textFieldEditingChanged) forControlEvents: UIControlEventEditingChanged];
    [self.passwordTextField addTarget: self action: @selector(textFieldEditingChanged) forControlEvents: UIControlEventEditingChanged];
    
    self.title = @"帐号登录";
}


#pragma mark - 事件
- (IBAction)loginButton:(UIButton *)sender
{
    [self.loginButton setTitle: @"登陆中..." forState: UIControlStateNormal];

    NSString *username = self.usernameOrEmailTextField.text;
    NSString *password = self.passwordTextField.text;
    
    [[WTAccountViewModel shareInstance] getOnceWithUsername: username password: password success:^{
        
        if (self.loginSuccessBlock)
        {
            self.loginSuccessBlock();
        }
        [self dismissViewControllerAnimated: YES completion: nil];
    } failure:^(NSError *error) {
        [self.loginButton setTitle: @"登陆" forState: UIControlStateNormal];
        if (error.code == 400 || error.code == 1001)
        {
            [self.tipView showErrorTitle: error.userInfo[@"message"]];
            return;
        }
        [self.tipView showErrorTitle: @"服务器异常，请稍候重试"];
    }];

}
- (IBAction)closeButtonClick
{
    [self dismissViewControllerAnimated: YES completion: nil];
}

- (void)textFieldEditingChanged
{
    if (self.usernameOrEmailTextField.text.length > 0 && self.passwordTextField.text.length > 0)
    {
        self.loginButton.userInteractionEnabled = YES;
    }
    else
    {
        self.loginButton.userInteractionEnabled = NO;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing: YES];
}

#pragma mark - 懒加载
- (WTTipView *)tipView
{
    if (_tipView == nil)
    {
        WTTipView *tipView = [WTTipView wt_viewFromXib];
        //[self.navigationController.navigationBar insertSubview: tipView atIndex: 0];
        [self.view addSubview: tipView];
        _tipView = tipView;
        
        tipView.frame = CGRectMake(0, -44, self.view.width, 44);
    }
    return _tipView;
}

- (void)dealloc
{
    WTLog(@"WTLoginViewController dealloc")
}
@end
