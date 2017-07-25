//
//  FLTabBarContactsItemView.m
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/25.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import "FLTabBarContactsItemView.h"

@interface FLTabBarContactsItemView ()

@property (nonatomic, strong) CAShapeLayer *leftEye;
@property (nonatomic, strong) CAShapeLayer *rightEye;
@property (nonatomic, strong) CAShapeLayer *headLayer;
@property (nonatomic, strong) CAShapeLayer *mouthLayer;
@property (nonatomic, strong) CAShapeLayer *outerLayer;

@end

@implementation FLTabBarContactsItemView

- (void)setupContentLayer {
    if (_headLayer == nil) {
        
        _headLayer = [CAShapeLayer layer] ;
        [self.contentLayer addSublayer:_headLayer];
        _outerLayer = [CAShapeLayer layer];
        [self.contentLayer addSublayer:_outerLayer];
    }
    else {
        _headLayer.path = nil;
        _outerLayer.path = nil;
    }
    
    if (_leftEye == nil) {
        
        _leftEye = [CAShapeLayer layer];
        [self.contentLayer addSublayer:_leftEye];
        _rightEye = [CAShapeLayer layer];
        [self.contentLayer addSublayer:_rightEye];
    }
    if (_mouthLayer == nil) {
        _mouthLayer = [CAShapeLayer layer];
        [self.contentLayer addSublayer:_mouthLayer];
    }
    else {
        _mouthLayer.path = nil;
    }
    
    UIBezierPath *aPath = [UIBezierPath bezierPath];
    [aPath moveToPoint:CGPointMake(5.5, 8.5)];
    [aPath addArcWithCenter:CGPointMake(12.5, 8.5) radius:6.5 startAngle:M_PI endAngle:M_PI * 3 clockwise:YES];
    aPath.lineWidth = 1;
    
    _headLayer.path = aPath.CGPath;
    if (self.orientation == FLSelected) {
        _headLayer.fillColor = self.highlightedColor.CGColor;
        _headLayer.strokeColor = [UIColor clearColor].CGColor;
    }
    else {
        _headLayer.strokeColor = self.normalColor.CGColor;
        _headLayer.fillColor = [UIColor clearColor].CGColor;
    }
    
    UIBezierPath *bPath = [UIBezierPath bezierPath];
    [bPath moveToPoint:CGPointMake(0, 25)];
    [bPath addArcWithCenter:CGPointMake(6.5, 25) radius:6.5 startAngle:M_PI endAngle:M_PI*3/2 clockwise:YES];
    [bPath addQuadCurveToPoint:CGPointMake(18, 18.5) controlPoint:CGPointMake(12.5, 17)];
    [bPath addArcWithCenter:CGPointMake(18, 25) radius:6.5 startAngle:M_PI*3/2 endAngle:M_PI*2 clockwise:YES];
    [bPath addLineToPoint:CGPointMake(0, 25)];
    
    _outerLayer.path = bPath.CGPath;
    if (self.orientation == FLSelected) {
        _outerLayer.fillColor = self.highlightedColor.CGColor;
        _outerLayer.strokeColor = [UIColor clearColor].CGColor;
    }
    else {
        _outerLayer.strokeColor = self.normalColor.CGColor;
        _outerLayer.fillColor = [UIColor clearColor].CGColor;
    }
    
    
    if (self.orientation == FLSelected) {
        
        UIBezierPath *leftEyePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(9.5, 6, 1.5, 3) cornerRadius:0.5];
        _leftEye.path = leftEyePath.CGPath;
        _leftEye.fillColor = [UIColor whiteColor].CGColor;
        
        UIBezierPath *rightEyePaht = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(13.5, 6, 1.5, 3) cornerRadius:0.5];
        _rightEye.path = rightEyePaht.CGPath;
        _rightEye.fillColor = [UIColor whiteColor].CGColor;
        
        UIBezierPath *ePath = [UIBezierPath bezierPath];
        [ePath moveToPoint:CGPointMake(9.5, 11)];
        
        CGFloat radius = 3.0;
        [ePath addQuadCurveToPoint:CGPointMake(15.5, 11) controlPoint:CGPointMake(radius + 9.5, 11 + radius)];
        [ePath addLineToPoint:CGPointMake(9.5, 11)];
        
        _mouthLayer.path = ePath.CGPath;
        _mouthLayer.fillColor = [UIColor whiteColor].CGColor;
    }
    else if (self.orientation == FLLeft) {
        
        
        UIBezierPath *leftEyePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(8, 6, 1.5, 3) cornerRadius:0.5];
        _leftEye.path = leftEyePath.CGPath;
        _leftEye.fillColor = self.normalColor.CGColor;
        
        UIBezierPath *rightEyePaht = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(12, 6, 1.5, 3) cornerRadius:0.5];
        _rightEye.path = rightEyePaht.CGPath;
        _rightEye.fillColor = self.normalColor.CGColor;
        
        
    }
    else if (self.orientation == FLRight ){
        
        UIBezierPath *leftEyePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(11, 6, 1.5, 3) cornerRadius:0.5];
        _leftEye.path = leftEyePath.CGPath;
        _leftEye.fillColor = self.normalColor.CGColor;
        
        UIBezierPath *rightEyePaht = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(15, 6, 1.5, 3) cornerRadius:0.5];
        _rightEye.path = rightEyePaht.CGPath;
        _rightEye.fillColor = self.normalColor.CGColor;
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
    
    CGFloat offsetX = self.imageContentView.center.x - kScreenWidth/3.0/2.0;
    CGFloat offsetY = self.imageContentView.center.y - 19.5;
    if (offsetY > 0) {
        offsetY = MIN(1.5, offsetY);
    }
    else {
        offsetY = MAX(-1.5, offsetY);
    }
    
    _mouthLayer.path = nil;
    if (self.orientation == FLSelected) {
        
        if (offsetX > 0 ) {
            offsetX = MIN(1.5, offsetX);
        }
        else {
            offsetX = MAX(-1.5, offsetX);
        }
        
        left_eye_original_x = 9.5;
        
        UIBezierPath *dPath = [UIBezierPath bezierPath];
        [dPath moveToPoint:CGPointMake(9.5 + offsetX, 11 + offsetY)];
        
        CGFloat radius = 3.0f;
        [dPath addQuadCurveToPoint:CGPointMake(15.5 + offsetX, 11 + offsetY) controlPoint:CGPointMake(radius + 9.5 + offsetX, 11 + radius + offsetY)];
        [dPath addLineToPoint:CGPointMake(9.5 + offsetX, 11 + offsetY)];
        dPath.lineWidth = 1;
        
        _mouthLayer.path = dPath.CGPath;
        _mouthLayer.fillColor = [UIColor whiteColor].CGColor;
        _mouthLayer.strokeColor = [UIColor clearColor].CGColor;
    }
    else if (self.orientation == FLLeft) {
        
        left_eye_original_x = 8;
        
    }
    else {
        left_eye_original_x = 11;
    }
    
    CGFloat leftEyeX = MAX(8, left_eye_original_x + offsetX);
    leftEyeX = MIN(leftEyeX, 11);
    UIBezierPath *leftEyePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(leftEyeX, 6 + offsetY, 1.5, 3) cornerRadius:0.5];
    _leftEye.path = leftEyePath.CGPath;
    
    UIBezierPath *rightEyePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(leftEyeX + 4, 6 + offsetY, 1.5, 3) cornerRadius:0.5];
    _rightEye.path = rightEyePath.CGPath;
}

@end
