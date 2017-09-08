//
//  FLMessageCell.h
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/7.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLMessageCellContentView.h"
@class FLMessageModel;

@protocol FLMessageCellDelegate;
@interface FLMessageCell : UITableViewCell

/**
 文字字体
 */
@property (nonatomic, strong) UIFont *textFont UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) FLMessageCellType cellType;
@property (nonatomic, strong) FLMessageModel *message;
@property (nonatomic, weak) id<FLMessageCellDelegate>delegate;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier messageModel:(FLMessageModel *)model;

+ (NSString *)cellReuseIndetifierWithMessageModel:(FLMessageModel *)Model;

- (void)updateSendStatus:(FLMessageSendStatus)status;

@end


@protocol FLMessageCellDelegate <NSObject>


/**
 重新发送消息
 @param cell cell
 @param message 消息模型
 */
- (void)messageCell:(FLMessageCell *)cell resendMessage:(FLMessageModel *)message;


/**
 cell上内容部分被点击

 @param cell cell
 */
- (void)didTapContentOfMessageCell:(FLMessageCell *)cell meesage:(FLMessageModel *)message;


@end


