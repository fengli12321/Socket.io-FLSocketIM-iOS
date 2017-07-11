//
//  FLAlertView.m
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/6.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import "FLAlertView.h"


@implementation UIView(FLSearchVcExtend)

- (UIViewController*)viewController {
    for (UIView* next = self; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}

@end

@interface FLAlertView ()

/** 按钮点击触发的回调 */
@property (nonatomic, copy) FLAlertButonClickBlock block;

@end

@implementation FLAlertView


+ (void)showWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles andAction:(FLAlertButonClickBlock)block andParentView:(UIView *)view {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    __block FLAlertView *alertView = [[FLAlertView alloc] init];
    alertView.block = block;
    
    if (cancelButtonTitle) {
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
            if (alertView.block) {
                alertView.block(0);
            }
            
        }];
        [alert addAction:action];
    }
    
    for (int i=0; i < otherButtonTitles.count; i++) {
        NSString *otherTitle = otherButtonTitles[i];
        UIAlertAction *action = [UIAlertAction actionWithTitle:otherTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            if (cancelButtonTitle) {
                if (alertView.block) {
                    alertView.block(i+1);
                }
            } else {
                if (alertView.block) {
                    alertView.block(i);
                }
            }
        }];
        [alert addAction:action];
    }
    if (view == nil) {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [window.rootViewController presentViewController:alert animated:YES completion:nil];
    }
    else {
        [[view viewController] presentViewController:alert animated:YES completion:nil];
    }
    
}

@end
