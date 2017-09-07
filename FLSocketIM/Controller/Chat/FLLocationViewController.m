//
//  FLLocationViewController.m
//  FLSocketIM
//
//  Created by 冯里 on 15/08/2017.
//  Copyright © 2017 冯里. All rights reserved.
//

#import "FLLocationViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>

static NSString *const FLAroundLocationCellOnlyName = @"FLAroundLocationCellOnlyName";
static NSString *const FLAroundLocationCellDefault = @"FLAroundLocationCellDefault";
@interface FLLocationViewController () <MAMapViewDelegate, AMapSearchDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) MAPointAnnotation *oldPointAnnotation;
@property (nonatomic, strong) AMapSearchAPI *search;
@property (nonatomic, assign) BOOL firstLoad;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSString *currentLocationName;
@property (nonatomic, strong) NSArray *aroundLocationArr;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) CLLocationCoordinate2D oldLocation;
@property (nonatomic, strong) UIImageView *locationPin;


@end

@implementation FLLocationViewController

#pragma mark - Lazy
- (AMapSearchAPI *)search {
    if (!_search) {
        _search = [[AMapSearchAPI alloc] init];
        _search.delegate = self;
    }
    return _search;
}
- (UIImageView *)locationPin {
    if (!_locationPin) {
        _locationPin = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 14, 38)];
        CGPoint center = CGPointMake(_mapView.width/2.0, _mapView.height/2.0 - _locationPin.height/2.0);
        _locationPin.center = center;
        _locationPin.image = [UIImage imageNamed:@"keybord_location_pin"];
        [_mapView addSubview:_locationPin];
    }
    return _locationPin;
}
#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self creatUI];
}
#pragma mark - UI
- (void)creatUI {
    
    self.firstLoad = YES;
    self.title = @"位置";
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelSend)];
    [self.navigationItem setLeftBarButtonItem:cancel];
    UIBarButtonItem *send = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(sendLocation)];
    [self.navigationItem setRightBarButtonItem:send];
    [self.navigationItem.rightBarButtonItem  setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithHex:0x00e600]} forState:UIControlStateNormal];
    
    _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight/2.0)];
    _mapView.delegate = self;
    _mapView.showsCompass = NO;
    _mapView.showsScale = NO;
    [_mapView setZoomLevel:15.5 animated:YES];
    [self.view addSubview:_mapView];
    
    _mapView.showsUserLocation = YES;
    _mapView.userTrackingMode = MAUserTrackingModeNone;
    
    
    // tableView
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _mapView.maxY, kScreenWidth, kScreenHeight - _mapView.maxY) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 50;
    _tableView.backgroundColor = FLBackGroundColor;
    [_tableView setSeparatorColor:FLBackGroundColor];
    [self.view addSubview:_tableView];
    
    CGFloat btnW = 50;
    UIButton *reLocatedBtn = [[UIButton alloc] initWithFrame:CGRectMake(_mapView.width - 10 - btnW, _mapView.height - 20 - btnW, btnW, btnW)];
    [reLocatedBtn setCornerRadius:btnW/2.0];
    [reLocatedBtn setBorderWidth:1 color:FLGrayColor];
    [reLocatedBtn setBackgroundColor:[UIColor whiteColor]];
    [reLocatedBtn setImage:[UIImage imageNamed:@"keyboard_location_current"] forState:UIControlStateNormal];
    [reLocatedBtn setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [reLocatedBtn addTarget:self action:@selector(moveToCurrentLocation) forControlEvents:UIControlEventTouchUpInside];
    [_mapView addSubview:reLocatedBtn];

    
}
#pragma mark - Private



/**
 大头针添加动画
 */
- (void)addAnimationToLocationPin {
    [UIView animateWithDuration:0.3 animations:^{
        
        [self.locationPin setTransform:CGAffineTransformMakeTranslation(0, -10)];
    } completion:^(BOOL finished) {
        
       [UIView animateWithDuration:0.3 animations:^{
           
           [self.locationPin setTransform:CGAffineTransformIdentity];
       }];
    }];
}

/**
 地图截图
 */
- (void)screenShootImage:(void(^)(UIImage *image))shootImage {
    
    [_mapView takeSnapshotInRect:_mapView.bounds withCompletionBlock:^(UIImage *resultImage, CGRect rect) {
        
        if (resultImage) {
            shootImage(resultImage);
        }
    }];
}

/**
 搜索附近地名

 @param coordinate 搜索中心点坐标
 */
- (void)searchLocationNameWithCoordinate:(CLLocationCoordinate2D)coordinate {
    
    
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    regeo.location = [AMapGeoPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    regeo.requireExtension = YES;
    self.oldLocation = coordinate;
    [self.search AMapReGoecodeSearch:regeo];
}


- (void)setSelectedIndex:(NSInteger)selectedIndex {
    [self hideCellSelectedImage:YES index:_selectedIndex];
    _selectedIndex = selectedIndex;
    [self hideCellSelectedImage:NO index:selectedIndex];
    
}
- (void)hideCellSelectedImage:(BOOL)hidden index:(NSInteger)index {
    if (index <= self.aroundLocationArr.count) {
        FLAroundLocationCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        if (cell) {
            cell.selectedImage.hidden = hidden;
        }
    }
}
#pragma mark - BtnAction


/**
 移动到当前定位按钮
 */
- (void)moveToCurrentLocation {
    
    CLLocationCoordinate2D coordinate = _mapView.userLocation.coordinate;
    [_mapView setRegion:MACoordinateRegionMake(coordinate, _mapView.region.span) animated:YES];
    [self addAnimationToLocationPin];
    [self searchLocationNameWithCoordinate:coordinate];
}

- (void)cancelSend {
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
- (void)sendLocation {
    
    if (self.sendLocationBlock) {
        
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(0, 0);
        if (self.selectedIndex == 0) {
            
            coordinate = self.oldLocation;
        }
        else {
            NSInteger index = self.selectedIndex - 1;
            AMapPOI *poi = self.aroundLocationArr[index];
            coordinate = CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude);
        }
        self.sendLocationBlock(coordinate, self.currentLocationName);
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MAMapViewDelegate
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation {
    if ([annotation isKindOfClass:[MAUserLocation class]]) {
        return nil;
    }
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndentifier = @"pointReuseIndentifier";
        MAPinAnnotationView *annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
        }
        annotationView.animatesDrop = YES;        //设置标注动画显示，默认为NO
        annotationView.draggable = YES;        //设置标注可以拖动，默认为NO
        annotationView.pinColor = MAPinAnnotationColorRed;
        return annotationView;
    }
    return nil;
}


- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation {
    
//    FLLog(@"%lf===1==%lf", userLocation.coordinate.latitude, userLocation.coordinate.longitude);
    if (self.firstLoad) {
        self.firstLoad = NO;
        
        [_mapView setRegion:MACoordinateRegionMake(userLocation.coordinate, mapView.region.span) animated:YES];
        self.oldLocation = userLocation.coordinate;
        [self addAnimationToLocationPin];
        [self searchLocationNameWithCoordinate:userLocation.coordinate];
    }
}

- (void)mapView:(MAMapView *)mapView mapDidMoveByUser:(BOOL)wasUserAction {
    
    CLLocationCoordinate2D centerCoordinate = mapView.region.center;
    
    
    if (wasUserAction) { // 用户操作触发，请求周边地理数据
        
        [self addAnimationToLocationPin];
        [self searchLocationNameWithCoordinate:centerCoordinate];
    }
}

#pragma mark - AMapSearchDelegate
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response {
    
    self.currentLocationName = response.regeocode.formattedAddress;
    self.aroundLocationArr = [response.regeocode.pois copy];
    [self.tableView reloadData];
    self.selectedIndex = 0;
    [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
    
}
#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FLAroundLocationCell *cell;
    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:FLAroundLocationCellOnlyName];
        if (!cell) {
            cell = [[FLAroundLocationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FLAroundLocationCellOnlyName cellStyle:FLOnlyName];
        }
        cell.nameLabel.text = self.currentLocationName;

    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:FLAroundLocationCellDefault];
        if (!cell) {
            cell = [[FLAroundLocationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FLAroundLocationCellDefault cellStyle:FLNameAndAddress];
        }
        NSInteger index = indexPath.row - 1;
        AMapPOI *poi = self.aroundLocationArr[index];
        cell.nameLabel.text = poi.name;
        cell.addressLabel.text = poi.address;
   
    }
    cell.selectedImage.hidden = !(indexPath.row == self.selectedIndex);
    return cell;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.aroundLocationArr.count > 0 ? self.aroundLocationArr.count + 1 : 0;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.selectedIndex == indexPath.row) {
        return;
    }
    self.selectedIndex = indexPath.row;
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(0, 0);
    if (indexPath.row == 0) {
        [_mapView setRegion:MACoordinateRegionMake(self.oldLocation, _mapView.region.span) animated:YES];
        coordinate = self.oldLocation;
    }
    else {
        NSInteger index = indexPath.row - 1;
        AMapPOI *poi = self.aroundLocationArr[index];
        coordinate = CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude);
        [_mapView setRegion:MACoordinateRegionMake(coordinate, _mapView.region.span) animated:YES];
        self.currentLocationName = poi.name;
    }
    [self addAnimationToLocationPin];
}

@end



@implementation FLAroundLocationCell



- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellStyle:(FLAroundLocationCellStyle)cellStyle{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
    
        
        _nameLabel = [[UILabel alloc] init];
        [self.contentView addSubview:_nameLabel];
        _nameLabel.font = FLFont(16);
        
        
        _selectedImage = [[UIImageView alloc] init];
        _selectedImage.image = [UIImage imageNamed:@"keyboard_location_select"];
        [_selectedImage setContentMode:UIViewContentModeScaleAspectFill];
        _selectedImage.hidden = YES;
        [self.contentView addSubview:_selectedImage];
        
        
        
        if (cellStyle == FLOnlyName) {
            
            [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.left.equalTo(self).offset(10);
                make.centerY.equalTo(self);
                make.right.equalTo(_selectedImage.mas_left).offset(-5);
            }];
        }
        else {
            _addressLabel = [[UILabel alloc] init];
            [self.contentView addSubview:_addressLabel];
            _addressLabel.font = FLFont(13);
            _addressLabel.textColor = FLSecondColor;
            
            
            [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.left.equalTo(self).offset(10);
                make.top.equalTo(self).offset(5);
                make.right.equalTo(_selectedImage.mas_left).offset(-5);
            }];
            
            [_addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.left.equalTo(_nameLabel);
                make.bottom.equalTo(self).offset(-5);
                make.right.equalTo(_nameLabel);
            }];
        }
        
        
        
        [_selectedImage mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.centerY.equalTo(self);
            make.right.equalTo(self).offset(-10);
            make.width.height.mas_offset(12);
        }];
    }
    return self;
}



@end
