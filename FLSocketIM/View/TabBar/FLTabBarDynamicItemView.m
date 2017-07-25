//
//  FLDynamicItemView.m
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/25.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import "FLTabBarDynamicItemView.h"

@interface FLTabBarDynamicItemView ()

@property (nonatomic, strong) CAShapeLayer *bigStar;
@property (nonatomic, strong) CAShapeLayer *smallStar;

@end
@implementation FLTabBarDynamicItemView

- (void)setupContentLayer {
    if (_bigStar == nil) {
        _bigStar = [CAShapeLayer layer];
        [self.contentLayer addSublayer:_bigStar];
    }
    else {
        _bigStar.path = nil;
    }
    
    if (_smallStar == nil) {
        _smallStar = [CAShapeLayer layer];
        [self.contentLayer addSublayer:_smallStar];
    }
    else {
        _smallStar.path = nil;
    }
    
    if (self.orientation == FLSelected) {
        
        UIBezierPath *bigPath = [UIBezierPath bezierPath];
        [bigPath moveToPoint:CGPointMake(1, 10)];
        [bigPath addLineToPoint:CGPointMake(8.5, 8)];
        [bigPath addLineToPoint:CGPointMake(12.5, 2)];
        [bigPath addLineToPoint:CGPointMake(16, 8)];
        [bigPath addLineToPoint:CGPointMake(24, 9.5)];
        [bigPath addLineToPoint:CGPointMake(19, 16.5)];
        [bigPath addLineToPoint:CGPointMake(20.5, 24)];
        [bigPath addLineToPoint:CGPointMake(13.5, 21)];
        [bigPath addLineToPoint:CGPointMake(6.5, 24)];
        [bigPath addLineToPoint:CGPointMake(6, 16.5)];
        [bigPath closePath];
        
        _bigStar.path = bigPath.CGPath;
        _bigStar.fillColor = self.highlightedColor.CGColor;
        _bigStar.strokeColor = [UIColor clearColor].CGColor;
        
        
        UIBezierPath *smallPath = [UIBezierPath bezierPath];
        [smallPath moveToPoint:CGPointMake(19, 3)];
        [smallPath addArcWithCenter:CGPointMake(22, 3) radius:3 startAngle:M_PI endAngle:M_PI * 3 clockwise:YES];
        
        _smallStar.path = smallPath.CGPath;
        _smallStar.fillColor = self.highlightedColor.CGColor;
    }
    else {
        
        UIBezierPath *bigPath = [UIBezierPath bezierPath];
        [bigPath moveToPoint:CGPointMake(1, 10)];
        [bigPath addLineToPoint:CGPointMake(8, 8.5)];
        [bigPath addLineToPoint:CGPointMake(12.5, 3)];
        [bigPath addLineToPoint:CGPointMake(16, 8)];
        [bigPath addLineToPoint:CGPointMake(24, 9.5)];
        [bigPath addLineToPoint:CGPointMake(19, 16.5)];
        [bigPath addLineToPoint:CGPointMake(20.5, 24)];
        [bigPath addLineToPoint:CGPointMake(11.5, 21)];
        [bigPath addLineToPoint:CGPointMake(6, 24)];
        [bigPath addLineToPoint:CGPointMake(6, 16)];
        [bigPath closePath];
        bigPath.lineWidth = 1;
        
        _bigStar.path = bigPath.CGPath;
        _bigStar.fillColor = [UIColor clearColor].CGColor;
        _bigStar.strokeColor = self.normalColor.CGColor;
        
    }
}
- (void)panGesture:(UIPanGestureRecognizer *)panGes {
    
    CGPoint translation = [panGes translationInView:self];
    if (panGes.state == UIGestureRecognizerStateBegan || panGes.state == UIGestureRecognizerStateChanged) {
        
        CGPoint imgContentCenter = self.imageContentView.center;
        imgContentCenter.x += translation.x/5.0;
        imgContentCenter.y += translation.y/5.0;
        
        imgContentCenter.x = MIN(kScreenWidth/3.0/2.0 + 5, imgContentCenter.x);
        imgContentCenter.x = MAX(kScreenWidth/3.0/2.0 - 5, imgContentCenter.x);
        
        imgContentCenter.y = MIN(19.5 + 3, imgContentCenter.y);
        imgContentCenter.y = MAX(19.5 - 3, imgContentCenter.y);
        
        self.imageContentView.center = imgContentCenter;
        
    }
    else if (panGes.state == UIGestureRecognizerStateCancelled || panGes.state == UIGestureRecognizerStateFailed || panGes.state == UIGestureRecognizerStateEnded) {
        self.imageContentView.center = CGPointMake(kScreenWidth/3.0/2.0, 19.5);
    }
    [panGes setTranslation:CGPointZero inView:self];
}


@end
