//
//  FLAlertView.h
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/6.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^FLAlertButonClickBlock)(NSInteger buttonIndex);
@interface FLAlertView : UIView


+ (void)showWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles andAction:(FLAlertButonClickBlock) block andParentView:(UIView *)view;

@end
