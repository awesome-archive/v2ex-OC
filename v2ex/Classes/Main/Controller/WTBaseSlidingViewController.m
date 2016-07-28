//
//  WTBaseSlidingViewController.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/7/28.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTBaseSlidingViewController.h"

CGFloat const WTBaseSlidingHeaderViewH = 150;

@interface WTBaseSlidingViewController () <UITableViewDelegate>
/** 记录scrollView的contentOff的Y值 */
@property (nonatomic, assign) CGFloat endY;
@end

@implementation WTBaseSlidingViewController

#pragma mark - LifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 1、headerView
    UIView *headerContentView = [UIView new];
    
    {
        headerContentView.frame = CGRectMake(0, 0, WTScreenWidth, WTScreenHeight - WTTabBarHeight);
        [self.view addSubview: headerContentView];
        self.headerContentView = headerContentView;
        
        headerContentView.backgroundColor = [UIColor colorWithHexString: WTAppLightColor];
    }
    
    
    // 2、footerView
    UIView *footerContentView = [UIView new];
    
    {
        footerContentView.layer.cornerRadius = 5;
        footerContentView.layer.masksToBounds = YES;
        footerContentView.frame = CGRectMake(0, WTBaseSlidingHeaderViewH, WTScreenWidth, WTScreenHeight - WTBaseSlidingHeaderViewH);
        [self.view addSubview: footerContentView];
        self.footerContentView = footerContentView;
    }
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < 0)
    {
        [UIView animateWithDuration: 0.1 animations:^{
            
            
            self.endY += (-scrollView.contentOffset.y) * 0.3;
            self.footerContentView.y = WTBaseSlidingHeaderViewH + self.endY;
            
        }];
        
        scrollView.contentOffset = CGPointMake(0, 0);
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [UIView animateWithDuration: 0.3 animations:^{
        
        self.footerContentView.y = WTBaseSlidingHeaderViewH;
        self.endY = 0;
    }];
}

- (void)setShowTabBarFlag:(BOOL)showTabBarFlag
{
    if (showTabBarFlag)
    {
        self.footerContentView.frame = CGRectMake(0, WTBaseSlidingHeaderViewH, WTScreenWidth, WTScreenHeight - WTBaseSlidingHeaderViewH);
    }
    else
    {
        self.footerContentView.frame = CGRectMake(0, WTBaseSlidingHeaderViewH, WTScreenWidth, WTScreenHeight);
    }
}
@end
