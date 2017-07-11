//
//  UIViewController+Common.h
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/6.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Common)

- (void)showMessage:(NSString *)message;
- (void)showHint:(NSString *)hint;
- (void)hideHud;
- (void)showError:(NSString *)error;
- (void)showSuccess:(NSString *)success;

@end
