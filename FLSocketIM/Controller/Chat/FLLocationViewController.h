//
//  FLLocationViewController.h
//  FLSocketIM
//
//  Created by 冯里 on 15/08/2017.
//  Copyright © 2017 冯里. All rights reserved.
//

#import "FLViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface FLLocationViewController : FLViewController

@property (nonatomic, copy) void(^sendLocationBlock)(CLLocationCoordinate2D location, NSString *locationName, NSString *detailLocName);

@end


typedef NS_ENUM(NSInteger, FLAroundLocationCellStyle) {
    
    FLOnlyName,
    FLNameAndAddress
};
@interface FLAroundLocationCell : UITableViewCell

@property (nonatomic, assign) FLAroundLocationCellStyle style;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *addressLabel;
@property (nonatomic, strong) UIImageView *selectedImage;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellStyle:(FLAroundLocationCellStyle)cellStyle;

@end
