//
//  WTMeTopView.h
//  v2ex
//
//  Created by 无头骑士 GJ on 16/2/24.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WTUser, WTMeTopView;
@protocol WTMeTopViewDelegate <NSObject>

@optional
- (void)meTopViewDidClickedSignButton:(WTMeTopView *)meTopView;

@end

@interface WTMeTopView : UIView
/** 用户信息模型 */
@property (nonatomic, strong) WTUser                *user;
/** 代理 */
@property (nonatomic, weak) id<WTMeTopViewDelegate> delegate;
/** 签到按钮 */
@property (weak, nonatomic) IBOutlet UIButton       *signButton;
/**
 *  签到成功
 */
- (void)signSuccess;
@end
