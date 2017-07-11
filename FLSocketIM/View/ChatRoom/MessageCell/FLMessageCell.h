//
//  FLMessageCell.h
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/7.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FLMessageModel;
@interface FLMessageCell : UITableViewCell

/**
 文字字体
 */
@property (nonatomic, strong) UIFont *textFont UI_APPEARANCE_SELECTOR;


@property (nonatomic, strong) FLMessageModel *message;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier isSender:(BOOL)isSender;

+ (NSString *)cellReuseIndetifierWithIsSender:(BOOL)isSender;

@end
