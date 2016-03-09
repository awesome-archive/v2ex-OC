//
//  WTPostReplyViewController.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/2/27.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTPostReplyViewController.h"
#import "CTAssetsPickerController.h"
#import "NetworkTool.h"
#import "WTURLConst.h"
#import "SVProgressHUD.h"
#import "NSString+Regex.h"
@interface WTPostReplyViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
/** 相册选择器 */
@property (nonatomic, strong) UIImagePickerController *imagePicker;
/** 上传图片完成之后的地址 */
@property (nonatomic, strong) NSString                *original_pic;
/** 回复的内容 */
@property (weak, nonatomic) IBOutlet UITextView       *textView;
@end

@implementation WTPostReplyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 1、设置导航栏items
    [self setupNavigationItems];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
}

#pragma mark - 设置导航栏items
- (void)setupNavigationItems
{
    self.title = @"回复";

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed:@"nav_close_white_normal"] style: UIBarButtonItemStylePlain target: self action: @selector(closeClick)];
    
    UIBarButtonItem *rightItem0 = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"nav_post_normal"] style: UIBarButtonItemStyleDone target: self action: @selector(postClick)];
    UIBarButtonItem *rightItem1 = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"nav_photo_normal"] style: UIBarButtonItemStyleDone target: self action: @selector(photoClick)];
    self.navigationItem.rightBarButtonItems = @[rightItem0, rightItem1];
}

#pragma mark - 点击事件
#pragma mark 关闭控制器
- (void)closeClick
{
    [self dismissViewControllerAnimated: YES completion: nil];
}

#pragma mark 选择图片
- (void)photoClick
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle: @"上传图片"
                                                                     message: nil
                                                              preferredStyle: UIAlertControllerStyleActionSheet];
    
    UIAlertAction *photoAction = [UIAlertAction actionWithTitle: @"拍照" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.imagePicker.allowsEditing = YES;
        [self presentViewController: self.imagePicker animated: YES completion: nil];
        
    }];
    
    
    UIAlertAction *albumAction = [UIAlertAction actionWithTitle: @"从相册中选择" style: UIAlertActionStyleDefault handler: ^(UIAlertAction * _Nonnull action) {
        WTLog(@"albumAction");
        
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        [self presentViewController: self.imagePicker animated: YES completion: nil];
        
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle: @"取消" style: UIAlertActionStyleCancel handler: nil];
    
    //[alertVC setValue: @[photoAction, albumAction] forKey: @"actions"];
    [alertVC addAction: photoAction];
    [alertVC addAction: albumAction];
    [alertVC addAction: cancelAction];
    [self presentViewController: alertVC animated: YES completion: nil];
}

#pragma mark 发表回复
- (void)postClick
{
    NSString *content = self.textView.text;
    if (content.length == 0)
    {
        return;
    }
    
    [SVProgressHUD show];
    [[NetworkTool shareInstance] replyTopicWithUrlString: self.urlString once: self.once content: content success:^(id responseObject) {
        
        NSString *html = [[NSString alloc] initWithData: responseObject encoding: NSUTF8StringEncoding];
        if ([html containsString: @"你回复过于频繁了"])
        {
//            NSString *tip = [NSString subStringWithRegex: @"\\d*" string: html];
            
            [SVProgressHUD showErrorWithStatus: @"你回复过于频繁了，请稍等1800秒之后再试"];
        }
        else
        {
            [SVProgressHUD dismiss];
            if (self.completionBlock)
            {
                self.completionBlock(YES);
            }
            [self dismissViewControllerAnimated: YES completion: nil];
        }
    } failure:^(NSError *error) {
        
        WTLog(@"error:%@", error)
        
        [SVProgressHUD dismiss];
        if (self.completionBlock)
        {
            self.completionBlock(NO);
        }
        [self dismissViewControllerAnimated: YES completion: nil];
    }];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    WTLog(@"info:%@", info);
    
    [self dismissViewControllerAnimated: YES completion: nil];
    //先把图片转成NSData
    UIImage *image = [info objectForKey: UIImagePickerControllerOriginalImage];
    
    // 上传图片
    [self uploadImage: image];
}

#pragma mark - 上传图片
- (void)uploadImage:(UIImage *)image
{
    [[NetworkTool shareInstance] uploadImageWithUrlString: WTUploadPictureUrl image: image progress:^(NSProgress *uploadProgress) {
//        [SVProgressHUD showProgress: 1.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount];
        WTLog(@"上传中:%lld, 总大小:%lld", uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
    } success:^(id responseObject) {
        
        if (responseObject[@"original_pic"])
        {
            self.textView.text = [self.textView.text stringByAppendingFormat: @"\n%@", responseObject[@"original_pic"]];
            
        }
    } failure:^(NSError *error) {
 
        WTLog(@"error:%@", error)
    
    }];
    self.textView.text = @"123";
}


#pragma mark - 懒加载
- (UIImagePickerController *)imagePicker
{
    if (_imagePicker == nil)
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        _imagePicker = imagePicker;
    }
    return _imagePicker;
}

- (void)dealloc
{
    WTLog(@"销毁");
}

@end
