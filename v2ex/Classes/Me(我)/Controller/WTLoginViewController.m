//
//  WTLoginViewController.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/2/23.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTLoginViewController.h"
#import "WTAccountTool.h"
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
    
    // 3、设置textField的文字颜色和占位文字颜色
    self.usernameOrEmailTextField.textColor = WTPrettyColor;
    self.passwordTextField.textColor = self.usernameOrEmailTextField.textColor;

    self.usernameOrEmailTextField.attributedPlaceholder = [self setPlaceholderAttribute: 14 placeholder: @"邮箱或帐号"];
    self.passwordTextField.attributedPlaceholder = [self setPlaceholderAttribute: 14 placeholder: @"密码"];
    
    self.title = @"帐号登录";
}

/**
 *  设置placeholder的属性
 *
 *  @param font        字体大小
 *  @param placeholder placeholder
 *
 *  @return placeholder的属性
 */
- (NSAttributedString *)setPlaceholderAttribute:(NSInteger)fontSize placeholder:(NSString *)placeholder
{
    return [[NSAttributedString alloc] initWithString: placeholder attributes:@{NSForegroundColorAttributeName : WTPrettyColor, NSFontAttributeName : [UIFont systemFontOfSize: fontSize]}];
}

#pragma mark - 事件
- (IBAction)loginButton:(UIButton *)sender
{
    [self.loginButton setTitle: @"登陆中..." forState: UIControlStateNormal];
    
    // 请求参数
    WTAccountParam *param = [WTAccountParam new];
    {
        param.u = self.usernameOrEmailTextField.text;
        param.p = self.passwordTextField.text;
    }
    
    [WTAccountTool loginWithParam: param success:^{
        
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

- (BOOL)prefersStatusBarHidden
{
    return true;
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
@end
