//
//  FLPlaceholderTextView.h
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/11.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLPlaceholderTextView : UITextView

@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic, strong) UIColor *placeholderColor;

- (void)textChanged:(NSNotification *)notification;

@end
