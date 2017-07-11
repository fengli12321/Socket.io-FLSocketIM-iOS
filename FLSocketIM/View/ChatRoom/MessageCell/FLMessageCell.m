//
//  FLMessageCell.m
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/7.
//  Copyright © 2017年 冯里. All rights reserved.
//


#define kMessageCell_FontContent [UIFont systemFontOfSize:15]
#define kMessageCell_PadingWidth 20.0
#define kMessageCell_PadingHeight 11.0
#define kMessageCell_ContentWidth (kScreen_Width*0.6)
#define kMessageCell_TimeHeight 40.0
#define kMessageCell_UserIconWith 40.0

#import "FLMessageCell.h"
#import "FLMessageBubbleView.h"
#import "FLMessageModel.h"

@interface FLMessageCell () {
    BOOL _isSender;
}


@property (nonatomic, strong) UIImageView *userIconView;
@property (nonatomic, strong) FLMessageBubbleView *bubbleView;

@end
@implementation FLMessageCell

+ (void)initialize {
//    FLMessageCell *cell = [FLMessageCell appearance];
//    cell.textFont = [UIFont systemFontOfSize:20];
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier isSender:(BOOL)isSender {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _isSender = isSender;
        [self creatUI];
    }
    return self;
}

#pragma mark - UI
- (void)creatUI {
    
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    self.contentView.backgroundColor = FLBackGroundColor;
    
    _userIconView = [[UIImageView alloc] init];
    [self.contentView addSubview:_userIconView];
    [_userIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        _isSender ? make.right.equalTo(self) : make.left.equalTo(self);
        make.top.equalTo(self).offset(10);
        make.width.height.mas_equalTo(kMessageCell_UserIconWith);
    }];
    _userIconView.backgroundColor = [UIColor redColor];
    [_userIconView setCornerRadius:kMessageCell_UserIconWith/2.0];
    
    _bubbleView = [[FLMessageBubbleView alloc] initWithIsSender:_isSender];
    [self.contentView addSubview:_bubbleView];
    [_bubbleView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        _isSender ? make.right.equalTo(_userIconView.mas_left).offset(-10) : make.left.equalTo(_userIconView.mas_right).offset(10);
        make.top.equalTo(_userIconView);
        make.width.mas_lessThanOrEqualTo(kScreenWidth);
//        make.height.mas_greaterThanOrEqualTo(@20);
        
    }];
}
- (void)setMessage:(FLMessageModel *)message {
    _message = message;
    _bubbleView.message = message;
}

- (void)setTextFont:(UIFont *)textFont {
    _textFont = textFont;
    _bubbleView.textFont = textFont;
}

#pragma mark - Public
+ (NSString *)cellReuseIndetifierWithIsSender:(BOOL)isSender {
    
    return isSender ? @"FLMessageCell_send" : @"FLMessageCell_receive";
}
@end
