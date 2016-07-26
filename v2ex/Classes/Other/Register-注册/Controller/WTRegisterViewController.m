//
//  WTRegisterViewController.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/3/4.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTRegisterViewController.h"
#import "NetworkTool.h"
#import "WTAccountViewModel.h"
#import "UIImageView+WebCache.h"
#import "SVProgressHUD.h"
#import "WTTipView.h"
#import "WTPrivacyStatementViewController.h"

@interface WTRegisterViewController ()
/** 二维码图片 */
@property (weak, nonatomic) IBOutlet UIImageView *codeImageView;
/** 用户名 */
@property (weak, nonatomic) IBOutlet UITextField *usernameTextF;
/** 密码 */
@property (weak, nonatomic) IBOutlet UITextField *passwordTextF;
/** 邮箱 */
@property (weak, nonatomic) IBOutlet UITextField *emailTextF;
/** 验证码 */
@property (weak, nonatomic) IBOutlet UITextField *codeTextF;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

/** 验证码图片Url */
@property (nonatomic, strong) NSString           *codeUrl;
/** 提示框View */
@property (nonatomic, weak) WTTipView            *tipView;
@end

@implementation WTRegisterViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    // 1、设置验证码图片
    [self DownloadCodeImage];
    
    // 2、设置view
    [self setupView];
}

#pragma mark - 自定义方法
#pragma mark 下载验证码图片
- (void)DownloadCodeImage
{
    [[WTAccountViewModel shareInstance] getVerificationCodeUrlWithSuccess:^(NSString *codeUrl) {
        self.codeUrl = codeUrl;
        // 设置验证码图片
        [self setupCodeImage];
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark 设置验证码图片
- (void)setupCodeImage
{
    [[NetworkTool shareInstance] GETWithUrlString: self.codeUrl success:^(NSData *data) {
        self.codeImageView.image = [UIImage imageWithData: data];

    } failure:^(NSError *error) {
        WTLog(@"getDataWithUrl Error:%@", error)
    }];
}

#pragma mark 设置View
- (void)setupView
{
    // 1、为 codeImageView 添加点击手势
    self.codeImageView.userInteractionEnabled = YES;
    [self.codeImageView addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(imageViewClick)]];
    
    self.loginButton.layer.cornerRadius = 3;
}

#pragma mark - 事件
#pragma mark 关闭按钮点击
- (IBAction)closeButtonClick
{
    [self dismissViewControllerAnimated: YES completion: nil];
}

#pragma mark 登陆按钮点击
- (IBAction)loginButtonClick
{
    // 1、检验
    NSString *username = self.usernameTextF.text;
    NSString *password = self.passwordTextF.text;
    NSString *email = self.emailTextF.text;
    NSString *c = self.codeTextF.text;
    if (username.length == 0 || password.length == 0 || email.length == 0 || c.length == 0)
        return
    
    // 2、发起请求
    [SVProgressHUD show];
//    [[WTAccountViewModel shareInstance] registerWithUsername: username password: password email: email c: c success:^(BOOL isSuccess) {
//        
//        if (isSuccess)
//        {
//            [self.tipView showSuccessTitle: @"注册成功"];
//        }
//        
//        [SVProgressHUD dismiss];
//        
//    } failure:^(NSError *error) {
//        
//        WTLog(@"error:%@", error)
//        [self.tipView showErrorTitle: @"服务器异常，请稍候重试"];
//        
//        [SVProgressHUD dismiss];
//    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD showSuccessWithStatus: @"注册成功"];
        //[self.tipView showSuccessTitle: @"注册成功"];
    });
        
}
#pragma mark - 隐私按钮点击
- (IBAction)privacyButtonClick
{
    [self presentViewController: [WTPrivacyStatementViewController new] animated: YES  completion: nil];
}

#pragma mark 验证码图片点击
- (void)imageViewClick
{
    // 设置验证码图片
    [self setupCodeImage];
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
        [[UIApplication sharedApplication].keyWindow addSubview: tipView];
        _tipView = tipView;
        
        tipView.frame = CGRectMake(0, -44, self.view.width, 44);
    }
    return _tipView;
}

@end
