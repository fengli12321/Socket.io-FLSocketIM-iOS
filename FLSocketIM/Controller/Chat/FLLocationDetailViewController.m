//
//  FLLocationDetailViewController.m
//  FLSocketIM
//
//  Created by 冯里 on 2017/9/7.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import "FLLocationDetailViewController.h"
#import <MAMapKit/MAMapKit.h>

@interface FLLocationDetailViewController () <MAMapViewDelegate>

@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) FLMessageModel *message;
@property (nonatomic, assign) CLLocationCoordinate2D currentLocation;

@end

@implementation FLLocationDetailViewController

#pragma mark - LifeCycle
- (instancetype)initWithMessageModel:(FLMessageModel *)message {
    if (self = [super init]) {
        self.message = message;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self creatUI];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}
#pragma mark - UI
- (void)creatUI {
    
    CGFloat bottomViewH = 100;
    
    // 地图
    _mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    _mapView.height -= bottomViewH;
    _mapView.delegate = self;
    
    _mapView.showsCompass = NO;
    _mapView.showsScale = NO;
    [_mapView setZoomLevel:15.5 animated:YES];
    _mapView.showsUserLocation = YES;
    _mapView.userTrackingMode = MAUserTrackingModeNone;
    [self.view addSubview:_mapView];
    
    FLMessageBody *messageBody = self.message.bodies;
    // 移动到定位位置
    [_mapView setRegion:MACoordinateRegionMake(CLLocationCoordinate2DMake(messageBody.latitude, messageBody.longitude), _mapView.region.span) animated:YES];
    // 添加标记点
    MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
    pointAnnotation.coordinate = CLLocationCoordinate2DMake(messageBody.latitude, messageBody.longitude);
    [_mapView addAnnotation:pointAnnotation];
    
    
    // 返回按钮
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"location_back"] forState:UIControlStateNormal];
    backButton.frame = CGRectMake(10, 15, 50, 50);
    [backButton setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [self.view addSubview:backButton];
    
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    
    // 移动到当前位置按钮
    CGFloat btnW = 50;
    UIButton *reLocatedBtn = [[UIButton alloc] initWithFrame:CGRectMake(_mapView.width - 10 - btnW, _mapView.height - 20 - btnW, btnW, btnW)];
    [reLocatedBtn setCornerRadius:btnW/2.0];
    [reLocatedBtn setBorderWidth:1 color:FLGrayColor];
    [reLocatedBtn setBackgroundColor:[UIColor whiteColor]];
    [reLocatedBtn setImage:[UIImage imageNamed:@"keyboard_location_current"] forState:UIControlStateNormal];
    [reLocatedBtn setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [reLocatedBtn addTarget:self action:@selector(moveToCurrentLocation) forControlEvents:UIControlEventTouchUpInside];
    [_mapView addSubview:reLocatedBtn];
    
    // 底部视图部分
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - bottomViewH, kScreenWidth, bottomViewH)];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
    
    // 分割线
    UIView *sepLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 0.5)];
    sepLine.backgroundColor = FLLightGrayColor;
    [bottomView addSubview:sepLine];
    
    // 位置详情描述
    CGFloat margin = 15;
    CGFloat buttonW = 50;
    CGFloat padding = 10;
    UILabel *locDesLabel = [[UILabel alloc] initWithFrame:CGRectMake(margin, margin, kScreenWidth - margin*2-padding-buttonW, 25)];
    locDesLabel.font = FLFont(20);
    locDesLabel.text = messageBody.locationName;
    [bottomView addSubview:locDesLabel];
    
    UILabel *locDetLabel = [[UILabel alloc] initWithFrame:CGRectMake(margin, CGRectGetMaxY(locDesLabel.frame) + 5, locDesLabel.width, 40)];
    locDetLabel.font = FLFont(13);
    locDetLabel.numberOfLines = 2;
    locDetLabel.text = messageBody.detailLocationName;
    locDetLabel.textColor = FLSecondColor;
    [bottomView addSubview:locDetLabel];
    
    // 地图软件打开按钮
    UIButton *openButton = [UIButton buttonWithType:UIButtonTypeCustom];
    openButton.frame = CGRectMake(kScreenWidth - margin - buttonW, (bottomViewH - buttonW)/2.0, buttonW, buttonW);
    [openButton setImage:[UIImage imageNamed:@"open_location_other"] forState:UIControlStateNormal];
    [openButton addTarget:self action:@selector(openWithOther) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:openButton];
}

#pragma mark - Action
/**
 移动到当前定位按钮
 */
- (void)moveToCurrentLocation {
    
    CLLocationCoordinate2D coordinate = _mapView.userLocation.coordinate;
    [_mapView setRegion:MACoordinateRegionMake(coordinate, _mapView.region.span) animated:YES];
}
- (void)back:(UIButton *)btn {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)openWithOther {
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"请选择打开方式" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"高德地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self openOtherMapWithType:0];
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"百度地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self openOtherMapWithType:1];
    }];
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"腾讯地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self openOtherMapWithType:2];
    }];
    UIAlertAction *action4 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alertVC addAction:action1];
    [alertVC addAction:action2];
    [alertVC addAction:action3];
    [alertVC addAction:action4];
    
    [self presentViewController:alertVC animated:YES completion:nil];
    
}
//打开地图导航
- (void)openOtherMapWithType:(NSInteger)type {
    
    FLMessageBody *messageBody = self.message.bodies;
    NSString *urlString;
    switch (type) {
        case 0: // 高德地图
            urlString = [[NSString stringWithFormat:@"iosamap://path?sourceApplication=%@&sid=BGVIS1&slat=%f&slon=%f&sname=我的位置&did=BGVIS2&dlat=%f&dlon=%f&dname=终点&dev=0&t=0",@"FoxChat", self.currentLocation.latitude, self.currentLocation.longitude ,messageBody.latitude, messageBody.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            break;
        case 1: // 百度地图
            urlString = [[NSString stringWithFormat:@"baidumap://map/direction?origin=latlng:%f,%f|name:我的位置&destination=latlng:%f,%f|name:终点&mode=driving", self.currentLocation.latitude, self.currentLocation.longitude ,messageBody.latitude, messageBody.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        default:
            break;
    }
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlString]]) {
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    }
    else {
        [FLAlertView showWithTitle:@"打开失败" message:@"您还未安装该软件" cancelButtonTitle:@"确定" otherButtonTitles:nil andAction:nil andParentView:nil];
    }
}


#pragma mark - MAMapViewDelegate
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation {
    
    self.currentLocation = userLocation.coordinate;
}

@end
