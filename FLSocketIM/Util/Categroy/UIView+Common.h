//
//  UIView+Common.h
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/6.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Common)

@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat maxX;
@property (nonatomic, assign) CGFloat maxY;


- (void)doCircleFrame;
- (void)setCornerRadius:(CGFloat)radius;

@end
