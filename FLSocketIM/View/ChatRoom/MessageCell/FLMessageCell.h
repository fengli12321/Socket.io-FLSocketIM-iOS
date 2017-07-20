//
//  FLMessageCell.h
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/7.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FLMessageModel;

typedef NS_ENUM(NSInteger, FLMessageCellType) {
    FLTextMessageCell,
    FLImgMessageCell,
    FLOtherMessageCell
};
@interface FLMessageCell : UITableViewCell

/**
 文字字体
 */
@property (nonatomic, strong) UIFont *textFont UI_APPEARANCE_SELECTOR;

@property (nonatomic, assign) FLMessageCellType cellType;
@property (nonatomic, strong) FLMessageModel *message;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier messageModel:(FLMessageModel *)model;

+ (NSString *)cellReuseIndetifierWithMessageModel:(FLMessageModel *)Model;

- (void)updateSendStatus:(FLMessageSendStatus)status;

@end
