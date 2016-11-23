//
//  WTV2GroupViewController.m
//  v2ex
//
//  Created by gengjie on 2016/10/24.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTV2GroupViewController.h"
#import "MAMapKit/MAMapKit.h"
#import "NetworkTool.h"
#import "WTURLConst.h"
#import "WTUserItem.h"
#import "MJExtension.h"

#define DefaultLocationTimeout  6
#define DefaultReGeocodeTimeout 3

@interface WTV2GroupViewController () <MAMapViewDelegate>

@property (nonatomic, strong) MAMapView *mapView;

@property (nonatomic, strong) UIButton *gpsButton;

@property (nonatomic, strong) NSMutableArray<WTUserItem *> *userItems;
@end

@implementation WTV2GroupViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initView];
    
    [self initData];
}

- (void)initView
{
    self.title = @"v2ex小组";
    
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.delegate = self;
//    self.mapView.centerCoordinate = CLLocationCoordinate2DMake(39.907728, 116.397968);
    
    self.mapView.showsUserLocation = YES;
    [self.view addSubview:self.mapView];
    [self gpsAction];
    
    UIView *zoomPannelView = [self makeZoomPannelView];
    zoomPannelView.center = CGPointMake(self.view.width -  CGRectGetMidX(zoomPannelView.bounds) - 10,
                                        self.view.height -  CGRectGetMidY(zoomPannelView.bounds) - 10);
    [self.view addSubview:zoomPannelView];
    
    self.gpsButton = [self makeGPSButtonView];
    self.gpsButton.center = CGPointMake(CGRectGetMidX(self.gpsButton.bounds) + 10,
                                        self.view.height -  CGRectGetMidY(self.gpsButton.bounds) - 20);
    [self.view addSubview:self.gpsButton];
}

- (void)initData
{
    // 获取所有用户的坐标
    NSString *url = [WTMisaka14Domain stringByAppendingPathComponent: @"allUserLocation"];
    [[NetworkTool shareInstance] requestWithMethod: HTTPMethodTypeGET url: url param: nil success:^(id responseObject) {
        
        self.userItems = [WTUserItem mj_objectArrayWithKeyValuesArray: [responseObject objectForKey: @"result"]];
        
        
        
    } failure:^(NSError *error) {
        
    }];
}

- (UIButton *)makeGPSButtonView
{
    UIButton *ret = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    ret.backgroundColor = [UIColor whiteColor];
    ret.layer.cornerRadius = 4;
    
    [ret setImage:[UIImage imageNamed:@"gpsStat1"] forState:UIControlStateNormal];
    [ret addTarget:self action:@selector(gpsAction) forControlEvents:UIControlEventTouchUpInside];
    
    return ret;
}

- (UIView *)makeZoomPannelView
{
    UIView *ret = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 53, 98)];
    
    UIButton *incBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 53, 49)];
    [incBtn setImage:[UIImage imageNamed:@"increase"] forState:UIControlStateNormal];
    [incBtn sizeToFit];
    [incBtn addTarget:self action:@selector(zoomPlusAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *decBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 49, 53, 49)];
    [decBtn setImage:[UIImage imageNamed:@"decrease"] forState:UIControlStateNormal];
    [decBtn sizeToFit];
    [decBtn addTarget:self action:@selector(zoomMinusAction) forControlEvents:UIControlEventTouchUpInside];
    
    
    [ret addSubview:incBtn];
    [ret addSubview:decBtn];
    
    return ret;
}

#pragma mark - Action Handlers
- (void)returnAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)zoomPlusAction
{
    CGFloat oldZoom = self.mapView.zoomLevel;
    [self.mapView setZoomLevel:(oldZoom + 1) animated:YES];
}

- (void)zoomMinusAction
{
    CGFloat oldZoom = self.mapView.zoomLevel;
    [self.mapView setZoomLevel:(oldZoom - 1) animated:YES];
}

- (void)gpsAction
{
    if(self.mapView.userLocation.updating && self.mapView.userLocation.location)
    {
        [self.mapView setCenterCoordinate:self.mapView.userLocation.location.coordinate animated:YES];
        [self.gpsButton setSelected:YES];
    }
}


#pragma mark - MAMapView Delegate

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndetifier = @"pointReuseIndetifier";
        
        MAPinAnnotationView *annotationView = (MAPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndetifier];
        }
        
        annotationView.canShowCallout   = YES;
        annotationView.animatesDrop     = YES;
        annotationView.draggable        = NO;
        annotationView.pinColor         = MAPinAnnotationColorPurple;
        
        return annotationView;
    }
    
    return nil;
}

@end
