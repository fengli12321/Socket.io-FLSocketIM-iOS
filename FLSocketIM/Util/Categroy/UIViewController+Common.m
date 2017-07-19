//
//  UIViewController+Common.m
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/6.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import "UIViewController+Common.h"
#import "MBProgressHUD.h"
#import <objc/runtime.h>

static char tHud;
@implementation UIViewController (Common)

- (void)showMessage:(NSString *)message {
    
    
    MBProgressHUD *hud = [self getHUD];
    if (hud) {
        
        hud.label.text = message;
    }
    else {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.label.text = message;
        hud.removeFromSuperViewOnHide = YES;
        hud.backgroundView.hidden = YES;
        hud.userInteractionEnabled = NO;
        objc_setAssociatedObject(self, &tHud, hud, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (MBProgressHUD *)getHUD {
    
    return (MBProgressHUD *)objc_getAssociatedObject(self, &tHud);
}

- (void)hideHud {
    MBProgressHUD *hud = [self getHUD];
    [hud hideAnimated:YES];
    objc_setAssociatedObject(self, &tHud, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)showError:(NSString *)error {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = error;
    //    hud.contentColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    //    hud.bezelView.color = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    //    hud.label.text = text;
    //    hud.label.numberOfLines = 0;
    // 设置图片
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"MBProgressHUD.bundle/%@", @"error"]]];
    // 再设置模式
    hud.mode = MBProgressHUDModeCustomView;
    
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    hud.userInteractionEnabled = NO;
    // 2秒之后再消失
    [hud hideAnimated:YES afterDelay:2];
}

- (void)showSuccess:(NSString *)success {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = success;
    //    hud.contentColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    //    hud.bezelView.color = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    //    hud.label.text = text;
    //    hud.label.numberOfLines = 0;
    // 设置图片
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"MBProgressHUD.bundle/%@", @"success"]]];
    // 再设置模式
    hud.mode = MBProgressHUDModeCustomView;
    
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    hud.userInteractionEnabled = NO;
    // 1秒之后再消失
    [hud hideAnimated:YES afterDelay:0.7];
}

- (void)showHint:(NSString *)hint {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = hint;
    // 再设置模式
    hud.mode = MBProgressHUDModeText;
    
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    hud.userInteractionEnabled = NO;
    // 2秒之后再消失
    [hud hideAnimated:YES afterDelay:1.5];
}

@end
