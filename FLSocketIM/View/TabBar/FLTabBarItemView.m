//
//  FLTabBarItemView.m
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/25.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import "FLTabBarItemView.h"
#import "FLBarBadgeLabel.h"





@interface FLTabBarItemView ()



@end
@implementation FLTabBarItemView

#pragma mark - Lazy
- (CAShapeLayer *)contentLayer {
    if (!_contentLayer) {
        _contentLayer = [CAShapeLayer layer];
    }
    return _contentLayer;
}
#pragma mark - init

- (instancetype)initWithOrientation:(FLTabBarSelectedOrientation)orientation title:(NSString *)title type:(FLTabBarItemType)type {
    if (self = [super initWithFrame:CGRectZero]) {
        self.highlightedColor = RGBAColor(59, 171, 253, 1);
        self.normalColor = RGBAColor(108, 111, 129, 1);
        
        self.title = title;
        self.type = type;
        self.orientation = orientation;
        [self commonInit];
        [self setupTitleLabel];
        [self setupImageView];
        [self initBadgeLabel];
        
        [self addPan];
    }
    return self;
}


- (instancetype)init {
    if (self = [super init]) {
        
        
        
    }
    return self;
}

#pragma mark - Set
- (void)setOrientation:(FLTabBarSelectedOrientation)orientation {
    _orientation = orientation;
    [self setupTitleLabel];
    [self setupImageView];
}
- (void)setBadgeString:(NSString *)badgeString {
    
    if (self.badgeLabel == nil) {
        [self initBadgeLabel];
    }
    _badgeLabel.text = badgeString;
    [_badgeLabel sizeToFit];
    CGFloat badgeWidth = _badgeLabel.width + 12;
    _badgeLabel.frame = CGRectMake(25 - badgeWidth/2.0, -5, badgeWidth, 19);
    _badgeLabel.layer.cornerRadius = 9.5;
    _badgeString = [badgeString copy];
}

- (void)initBadgeLabel {
    
    _badgeLabel = [[FLBarBadgeLabel alloc] init];
    _badgeLabel.clipsToBounds = YES;
    _badgeLabel.backgroundColor = [UIColor redColor];
    _badgeLabel.textColor = [UIColor whiteColor];
    _badgeLabel.font = FLFont(10);
    [self.imageContentView addSubview:_badgeLabel];

    __weak typeof(self) weakSelf = self;
    _badgeLabel.clearCompletion = ^{
      
        [weakSelf.badgeLabel removeFromSuperview];
        weakSelf.badgeLabel = nil;
    };
}

- (void)setupTitleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        [self addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.right.bottom.equalTo(self);
            make.height.mas_equalTo(16);
        }];
        _titleLabel.text = self.title;
        _titleLabel.font = FLFont(12);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    if (_orientation == FLSelected) {
        _titleLabel.textColor = self.highlightedColor;
    }
    else {
        _titleLabel.textColor = self.normalColor;
    }
}

- (void)setupImageView {
    
    if (_imageContentView == nil) {
        _imageContentView = [[UIView alloc] init];
        [self addSubview:_imageContentView];
        
        [_imageContentView.layer addSublayer:self.contentLayer];
        _imageContentView.bounds = CGRectMake(0, 0, 25, 25);
        _imageContentView.center = CGPointMake(kScreenWidth/3.0/2.0, 19.5);
    }
    else {
        // 选中
        if (self.orientation == FLSelected) {
            
            [UIView animateWithDuration:0.1 animations:^{
                
                self.imageContentView.transform = CGAffineTransformMakeScale(0.7, 0.7);
            } completion:^(BOOL finished) {
                self.imageContentView.transform = CGAffineTransformIdentity;
            }];
        }
    }
    [self setupContentLayer];
}

- (void)addPan {
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    [self addGestureRecognizer:pan];
}


#pragma mark - Public
- (void)setupContentLayer {
    
}

- (void)panGesture:(UIPanGestureRecognizer *)panGes {
    
}

- (void)commonInit {
    
}

#pragma mark - override
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *result = [super hitTest:point withEvent:event];
    if (self.badgeLabel == nil) {
        return result;
    }
    CGPoint badgePoint = [_badgeLabel convertPoint:point fromView:self];
    if ([self.badgeLabel pointInside:badgePoint withEvent:event]) {
        return _badgeLabel;
    }
    return result;
}

@end
