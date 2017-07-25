//
//  FLTabBarItemView.h
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/25.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FLBarBadgeLabel;
typedef NS_ENUM(NSInteger, FLTabBarItemType) {
    FLTabBarMessage,
    FLTabBarContacts,
    FLTabBarDynamic
};

typedef NS_ENUM(NSInteger, FLTabBarSelectedOrientation) {
    FLLeft,
    FLSelected,
    FLRight
};
static CGFloat image_max_offset_x = 5;
static CGFloat image_max_offset_y = 3;
@interface FLTabBarItemView : UIView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIColor *highlightedColor;
@property (nonatomic, strong) UIColor *normalColor;
@property (nonatomic, assign) FLTabBarItemType type;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIView *imageContentView;
@property (nonatomic, strong) FLBarBadgeLabel *badgeLabel;
@property (nonatomic, strong) CAShapeLayer *contentLayer;
@property (nonatomic, assign) FLTabBarSelectedOrientation orientation;
@property (nonatomic, copy) NSString *badgeString;

- (instancetype)initWithOrientation:(FLTabBarSelectedOrientation)orientation title:(NSString *)title type:(FLTabBarItemType)type;
- (void)setupContentLayer;
- (void)commonInit;
- (void)panGesture:(UIPanGestureRecognizer *)panGes;
@end
