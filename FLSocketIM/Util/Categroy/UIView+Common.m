//
//  UIView+Common.m
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/6.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import "UIView+Common.h"

@implementation UIView (Common)

- (CGFloat)x {
    return self.frame.origin.x;
}

- (void)setX:(CGFloat)x {
    
    CGRect frame = self.frame;
    frame.origin.x = x;
    [self setFrame:frame];
}

- (CGFloat)y {
    return self.frame.origin.y;
}

- (void)setY:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    [self setFrame:frame];
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    [self setFrame:frame];
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    [self setFrame:frame];
}

- (CGFloat)maxX {
    return CGRectGetMaxX(self.frame);
}

- (void)setMaxX:(CGFloat)maxX {
    
}

- (CGFloat)maxY {
    return CGRectGetMaxY(self.frame);
}

- (void)setMaxY:(CGFloat)maxY {
    
}


- (void)doCircleFrame {
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = self.frame.size.width/2;
//    self.layer.borderWidth = 0.5;
//    self.layer.borderColor = kColorDDD.CGColor;
}

- (void)setCornerRadius:(CGFloat)radius {
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = radius;
}

@end
