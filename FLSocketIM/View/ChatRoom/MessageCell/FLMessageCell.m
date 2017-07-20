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


@property (nonatomic, strong) UIImageView *userIconView;            // 用户头像
@property (nonatomic, strong) FLMessageBubbleView *bubbleView;      // 文字气泡
@property (nonatomic, strong) UIImageView *messageImage;            // 消息图片

@property (nonatomic, strong) UIButton *reSendBtn;                  // 重新发送按钮
@property (nonatomic, strong) UIActivityIndicatorView *sendingView; // 发送中菊花转

@end
@implementation FLMessageCell

+ (void)initialize {
//    FLMessageCell *cell = [FLMessageCell appearance];
//    cell.textFont = [UIFont systemFontOfSize:20];
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier messageModel:(FLMessageModel *)model {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _isSender = [model.from isEqualToString:[FLClientManager shareManager].currentUserID];
        self.cellType = (FLMessageCellType)model.type;
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
        
        _isSender ? make.right.equalTo(self).offset(-kPadding) : make.left.equalTo(self).offset(kPadding);
        make.top.equalTo(self).offset(10);
        make.width.height.mas_equalTo(kMessageCell_UserIconWith);
    }];
    _userIconView.image = [UIImage imageNamed:_isSender?@"Fruit-1":@"Fruit-2"];
    [_userIconView setCornerRadius:kMessageCell_UserIconWith/2.0];

    _reSendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_reSendBtn setImage:[UIImage imageNamed:@"resend"] forState:UIControlStateNormal];
    [self.contentView addSubview:_reSendBtn];
    [_reSendBtn setTitle:@"重试" forState:UIControlStateNormal];
    [_reSendBtn setTitleColor:FLSecondColor forState:UIControlStateNormal];
    _reSendBtn.titleLabel.font = FLFont(13);
    
    _sendingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.contentView addSubview:_sendingView];
    [_sendingView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(_reSendBtn);
        make.right.equalTo(_reSendBtn);
    }];
    [_sendingView startAnimating];
    
    switch (self.cellType) {
        case FLTextMessageCell:{
            _bubbleView = [[FLMessageBubbleView alloc] initWithIsSender:_isSender];
            [self.contentView addSubview:_bubbleView];
            [_bubbleView mas_makeConstraints:^(MASConstraintMaker *make) {
                
                _isSender ? make.right.equalTo(_userIconView.mas_left).offset(-10) : make.left.equalTo(_userIconView.mas_right).offset(10);
                make.top.equalTo(_userIconView);
                make.width.mas_lessThanOrEqualTo(kScreenWidth);
            }];
            
            [_reSendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.centerY.equalTo(_bubbleView);
                make.right.mas_equalTo(_bubbleView.mas_left).offset(-5);
                make.height.mas_equalTo(30);
            }];
            
            
            
            break;
        }
        case FLImgMessageCell:{
            _messageImage = [[UIImageView alloc] init];
            
            _messageImage.contentMode = UIViewContentModeScaleAspectFill;
            _messageImage.clipsToBounds = YES;
            [self.contentView addSubview:_messageImage];
            [_messageImage mas_makeConstraints:^(MASConstraintMaker *make) {
                
                _isSender ? make.right.equalTo(_userIconView.mas_left).offset(-10) : make.left.equalTo(_userIconView.mas_right).offset(10);
                make.top.equalTo(_userIconView);
                make.width.mas_equalTo(kScreenWidth/4.0);
                make.height.equalTo(_messageImage.mas_width).multipliedBy(1.5);
            }];
            
            [_reSendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.centerY.equalTo(_messageImage);
                make.right.mas_equalTo(_messageImage.mas_left).offset(-5);
                make.height.mas_equalTo(30);
            }];
            
            break;
        }
            
        default:
            break;
    }
}
- (void)setMessage:(FLMessageModel *)message {
    _message = message;
    switch (self.cellType) {
        case FLTextMessageCell:
            _bubbleView.message = message;
            break;
        case FLImgMessageCell:{
            NSData *imgData = message.bodies.imgData;
            if (imgData) {
                self.messageImage.image = [UIImage imageWithData:imgData];
            }
            else {
                [self.messageImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", BaseUrl, message.bodies.imgUrl]] placeholderImage:[UIImage imageNamed:@"Fruit-5"]];
            }
            break;
        }
        default:
            break;
    }
    [self updateSendStatus:message.sendStatus];
}

- (void)setTextFont:(UIFont *)textFont {
    _textFont = textFont;
    _bubbleView.textFont = textFont;
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
        }
            
            
        default:
            break;
    }
}
@end
