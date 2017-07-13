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
@property (nonatomic, strong) UIImageView *messageImage;

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
    
    switch (self.cellType) {
        case FLTextMessageCell:{
            _bubbleView = [[FLMessageBubbleView alloc] initWithIsSender:_isSender];
            [self.contentView addSubview:_bubbleView];
            [_bubbleView mas_makeConstraints:^(MASConstraintMaker *make) {
                
                _isSender ? make.right.equalTo(_userIconView.mas_left).offset(-10) : make.left.equalTo(_userIconView.mas_right).offset(10);
                make.top.equalTo(_userIconView);
                make.width.mas_lessThanOrEqualTo(kScreenWidth);
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
@end
