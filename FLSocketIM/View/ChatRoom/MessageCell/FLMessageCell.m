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


#import "FLMessageModel.h"

@interface FLMessageCell () {
    BOOL _isSender;
}


@property (nonatomic, strong) UIImageView *userIconView;            // 用户头像

@property (nonatomic, strong) UIButton *reSendBtn;                  // 重新发送按钮
@property (nonatomic, strong) UIActivityIndicatorView *sendingView; // 发送中菊花转


@end
@implementation FLMessageCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier messageModel:(FLMessageModel *)model {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _isSender = [model.from isEqualToString:[FLClientManager shareManager].currentUserID];
        self.cellType = (FLMessageCellType)model.type;
        [self creatUI];
    }
    return self;
}
- (void)longPress {
    
    NSLog(@"长按");
}

#pragma mark - UI
- (void)creatUI {
    
    
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    self.contentView.backgroundColor = FLBackGroundColor;
    
    // 用户头像
    CGRect iconFrame = _isSender?CGRectMake(kScreenWidth - kPadding - kMessageCell_UserIconWith, kPadding, kMessageCell_UserIconWith, kMessageCell_UserIconWith):CGRectMake(kPadding, kPadding, kMessageCell_UserIconWith, kMessageCell_UserIconWith);;
    _userIconView = [[UIImageView alloc] initWithFrame:iconFrame];
    [self.contentView addSubview:_userIconView];
    _userIconView.image = [UIImage imageNamed:_isSender?@"Fruit-1":@"Fruit-2"];
    [_userIconView setCornerRadius:kMessageCell_UserIconWith/2.0];

    
    // 内容部分背景
    _contentBackView = [[FLMessageCellContentView alloc] initWithCellType:self.cellType isSender:_isSender];
    _contentBackView.horizontalOffset = _userIconView.width + kPadding * 2;
    _contentBackView.verticalOffset = _userIconView.y;
    [self.contentView addSubview:_contentBackView];
    
    __weak typeof(self) weakSelf = self;
    [self.contentBackView setContentViewTapBlock:^{
        [weakSelf cellContentTapAction];
    }];
    
    
    
    
    
    if (_isSender) { // 发送者， 添加发送状态菊花转和重发按钮
        _reSendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_reSendBtn setImage:[UIImage imageNamed:@"resend"] forState:UIControlStateNormal];
        [self.contentView addSubview:_reSendBtn];
        [_reSendBtn setTitle:@"重试" forState:UIControlStateNormal];
        [_reSendBtn setTitleColor:FLSecondColor forState:UIControlStateNormal];
        _reSendBtn.titleLabel.font = FLFont(13);
        
        [_reSendBtn addTarget:self action:@selector(reSendMessage) forControlEvents:UIControlEventTouchUpInside];
        
        _sendingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.contentView addSubview:_sendingView];
    }
    
    
    
}
- (void)setMessage:(FLMessageModel *)message {
    _message = message;
    self.contentBackView.message = message;
    [self updateSendStatus:message.sendStatus];
    if (_isSender) {
        [self updateFrame];
    }
}

- (void)updateFrame {
    CGFloat sendingViewW = 30;
    CGRect frame = CGRectMake(_contentBackView.x - 5 - sendingViewW, (self.contentBackView.height - sendingViewW)/2.0 + kPadding, sendingViewW, sendingViewW);
    _sendingView.frame = frame;
    
    [_reSendBtn sizeToFit];
    CGFloat btnW = _reSendBtn.width;
    _reSendBtn.frame = CGRectMake(_contentBackView.x - 5 - btnW, (self.contentBackView.height - sendingViewW)/2.0 + kPadding, btnW, sendingViewW);
}

- (void)setTextFont:(UIFont *)textFont {
    _textFont = textFont;
    _contentBackView.textFont = textFont;
}

#pragma mark - Private
- (void)cellContentTapAction {
    
    FLLog(@"内容点击");
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapContentOfMessageCell:meesage:)]) {
        [self.delegate didTapContentOfMessageCell:self meesage:self.message];
    }
}



#pragma mark - Public
+ (NSString *)cellReuseIndetifierWithMessageModel:(FLMessageModel *)Model {
    
    BOOL isSender = [Model.from isEqualToString:[FLClientManager shareManager].currentUserID];
    FLMessageCellType type = (FLMessageCellType)Model.type;
    switch (type) {
        case FLTextMessageCell:
            return isSender ? @"FLTxtMessageCell_send" : @"FLTxtMessageCell_receive";
            break;
            
        case FLImgMessageCell:
            return isSender ? @"FLImgMessageCell_send" : @"FLImgMessageCell_receive";
            break;
            
        case FLLocMessageCell:
            return isSender ? @"FLLocMessageCell_send" : @"FLLocMessageCell_receive";
            break;
        default:
            return nil;
            break;
    }
    
}

- (void)updateSendStatus:(FLMessageSendStatus)status {
    
    switch (status) {
        case FLMessageSending:{ // 正在发送中
            
            [_sendingView startAnimating];
            _reSendBtn.hidden = YES;
            break;
        }
        case FLMessageSendSuccess:{ // 发送成功
            
            [_sendingView stopAnimating];
            _reSendBtn.hidden = YES;
            break;
        }
            
        case FLMessageSendFail: {   // 发送失败
            
            [_sendingView stopAnimating];
            _reSendBtn.hidden = NO;
            break;
        }
            
            
        default:
            break;
    }
    
    if (self.cellType == FLLocMessageCell) {
        
        FLLocMessageContentView *contentView = (FLLocMessageContentView *)self.contentBackView;
        if ([contentView isKindOfClass:[FLLocMessageContentView class]]) {
            [contentView resetLocImage];
        }
    }
    
}

/**
 重新发送消息
 */
- (void)reSendMessage {
    
    if (_delegate && [_delegate respondsToSelector:@selector(messageCell:resendMessage:)]) {
        
        [_delegate messageCell:self resendMessage:self.message];
    }
}

@end


