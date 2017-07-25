//
//  FLTabBarMessageItemView.m
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/25.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import "FLTabBarMessageItemView.h"

@interface FLTabBarMessageItemView ()

@property (nonatomic, strong) CAShapeLayer *leftEye;
@property (nonatomic, strong) CAShapeLayer *rightEye;

@property (nonatomic, strong) CAShapeLayer *mouthLayer;
@property (nonatomic, strong) CAShapeLayer *outerLayer;

@end
@implementation FLTabBarMessageItemView

- (void)setupContentLayer {
    if (_outerLayer == nil) {
        _outerLayer = [CAShapeLayer layer];
        [self.contentLayer addSublayer:_outerLayer];
    }
    else {
        self.contentLayer.path = nil;
    }
    
    if (_leftEye == nil) {
        _leftEye = [CAShapeLayer layer];
        [self.contentLayer addSublayer:_leftEye];
        _rightEye = [CAShapeLayer layer];
        [self.contentLayer addSublayer:_rightEye];
    }
    else {
        _leftEye.path = nil;
        _rightEye.path = nil;
    }
    
    if (_mouthLayer == nil) {
        _mouthLayer = [CAShapeLayer layer];
        [self.contentLayer addSublayer:_mouthLayer];
    }
    else {
        _mouthLayer.path = nil;
    }
    
    UIBezierPath *aPath = [UIBezierPath bezierPath];
    [aPath moveToPoint:CGPointMake(0, 18)];
    [aPath addQuadCurveToPoint:CGPointMake(3, 19) controlPoint:CGPointMake(1, 19)];
    [aPath addArcWithCenter:CGPointMake(14, 12.5) radius:12 startAngle:M_PI*4.0/5.0 endAngle:M_PI/2 clockwise:YES];
    [aPath addQuadCurveToPoint:CGPointMake(0, 18) controlPoint:CGPointMake(3, 25)];
    aPath.lineWidth = 1;
    
    _outerLayer.path = aPath.CGPath;
    if (self.orientation == FLSelected) {
        _outerLayer.fillColor = self.highlightedColor.CGColor;
        _outerLayer.strokeColor = [UIColor clearColor].CGColor;
    }
    else {
        _outerLayer.fillColor = [UIColor clearColor].CGColor;
        _outerLayer.strokeColor = self.normalColor.CGColor;
    }
    
    if (self.orientation == FLSelected) {
        
        UIBezierPath *leftEyePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(9.5, 8, 1.5, 3) cornerRadius:0.5];
        _leftEye.path = leftEyePath.CGPath;
        _leftEye.fillColor = [UIColor whiteColor].CGColor;
        
        UIBezierPath *rightEyePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(16, 8, 1.5, 3) cornerRadius:0.5];
        _rightEye.path = rightEyePath.CGPath;
        _rightEye.fillColor = [UIColor whiteColor].CGColor;
        
        UIBezierPath *dPath = [UIBezierPath bezierPath];
        [dPath moveToPoint:CGPointMake(9.5, 15)];
        [dPath addArcWithCenter:CGPointMake(13.5, 15) radius:4 startAngle:M_PI endAngle:0 clockwise:NO];
        [dPath addLineToPoint:CGPointMake(9.5, 15)];
        dPath.lineWidth = 1;
        
        _mouthLayer.path = dPath.CGPath;
        _mouthLayer.fillColor = [UIColor whiteColor].CGColor;
        _mouthLayer.strokeColor = [UIColor clearColor].CGColor;

    }
    else if (self.orientation == FLRight){
        
        UIBezierPath *leftEyePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(11.5, 8, 1.5, 3) cornerRadius:0.5];
        _leftEye.path = leftEyePath.CGPath;
        _leftEye.fillColor = self.normalColor.CGColor;
        
        UIBezierPath *rightEyePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(18, 8, 1.5, 3) cornerRadius:0.5];
        _rightEye.path = rightEyePath.CGPath;
        _rightEye.fillColor = self.normalColor.CGColor;
        
        
        UIBezierPath *dPath = [UIBezierPath bezierPath];
        [dPath moveToPoint:CGPointMake(11.5, 16)];
        [dPath addQuadCurveToPoint:CGPointMake(19.5, 16) controlPoint:CGPointMake(15.5, 20)];
        dPath.lineWidth = 1;
        
        
        _mouthLayer.path = dPath.CGPath;
        _mouthLayer.fillColor = [UIColor clearColor].CGColor;
        _mouthLayer.strokeColor = self.normalColor.CGColor;
        
        
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
    [self changeImageOffset];
    [panGes setTranslation:CGPointZero inView:self];
}

- (void)changeImageOffset {
    
    CGFloat left_eye_original_x = 0;
    CGFloat right_eye_original_x = 0;
    
    CGFloat offsetX = self.imageContentView.center.x - kScreenWidth/3.0/2.0;
    CGFloat offsetY = self.imageContentView.center.y - 19.5;
    
    _mouthLayer.path = nil;
    if (self.orientation == FLSelected) {
        
        left_eye_original_x = 9.5;
        right_eye_original_x = 16;
        
        UIBezierPath *dPath = [UIBezierPath bezierPath];
        [dPath moveToPoint:CGPointMake(9.5 + offsetX, 15 + offsetY)];
        [dPath addArcWithCenter:CGPointMake(13.5 + offsetX, 15 + offsetY) radius:4 startAngle:M_PI endAngle:0 clockwise:NO];
        [dPath addLineToPoint:CGPointMake(9.5 + offsetX, 15 + offsetY)];
 
        
        _mouthLayer.path = dPath.CGPath;
        _mouthLayer.fillColor = [UIColor whiteColor].CGColor;
        _mouthLayer.strokeColor = [UIColor clearColor].CGColor;
    }
    else if (self.orientation == FLRight) {
        
        left_eye_original_x = 11.5;
        right_eye_original_x = 18;
        
        UIBezierPath *dPath = [UIBezierPath bezierPath];
        [dPath moveToPoint:CGPointMake(11.5 + offsetX, 16 + offsetY)];
        [dPath addQuadCurveToPoint:CGPointMake(19.5 + offsetX, 16 + offsetY) controlPoint:CGPointMake(15.5 + offsetX, 20 + offsetY)];

        
        
        _mouthLayer.path = dPath.CGPath;
        _mouthLayer.fillColor = [UIColor clearColor].CGColor;
        _mouthLayer.strokeColor = self.normalColor.CGColor;
    }
    UIBezierPath *leftEyePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(left_eye_original_x + offsetX, 8 + offsetY, 1.5, 3) cornerRadius:0.5];
    _leftEye.path = leftEyePath.CGPath;
    
    UIBezierPath *rightEyePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(right_eye_original_x + offsetX, 8 + offsetY, 1.5, 3) cornerRadius:0.5];
    _rightEye.path = rightEyePath.CGPath;
}

@end
