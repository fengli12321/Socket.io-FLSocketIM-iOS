//
//  FLTabBar.m
//  FLSocketIM
//
//  Created by 冯里 on 2017/12/11.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import "FLTabBar.h"

@implementation FLTabBar

- (void)setFrame:(CGRect)frame {
    if (self.superview && CGRectGetMaxY(self.superview.bounds) != CGRectGetMaxY(frame)) {
        frame.origin.y = CGRectGetMaxY(self.superview.bounds) - CGRectGetHeight(frame);
    }
    [super setFrame:frame];
}

- (void)addSubview:(UIView *)view {
   
    if ([view isKindOfClass:[UIControl class]]) {
        return;
    }
    [super addSubview:view];
}

@end
