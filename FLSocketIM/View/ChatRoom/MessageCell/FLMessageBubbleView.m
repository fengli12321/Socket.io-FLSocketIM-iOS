//
//  FLMessageBubbleView.m
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/7.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import "FLMessageBubbleView.h"
#import "FLMessageModel.h"

@interface FLMessageBubbleView () {
    
    BOOL _isSender; // 是否是发送者
}

@property (nonatomic, strong) UIImageView *bubbleImage;
@property (nonatomic, strong) UILabel *textLabel;


@end
@implementation FLMessageBubbleView

+ (void)initialize {
    FLMessageBubbleView *view = [self appearance];
    view.textFont = [UIFont systemFontOfSize:15];
    view.textSendInsets = UIEdgeInsetsMake(5, 8, 5, 15);
    view.textRecInsets = UIEdgeInsetsMake(5, 15, 5, 8);
}
- (instancetype)initWithIsSender:(BOOL)isSender {
    if (self = [super init]) {
        
        _isSender = isSender;
        [self createUI];
    }
    return self;
}

- (void)createUI {
    
    
    _bubbleImage = [[UIImageView alloc] init];
    [self addSubview:_bubbleImage];
    _bubbleImage.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _bubbleImage.image = [UIImage imageNamed:_isSender ? @"video_send_bubble" : @"video_recive_bubble"];
    
    _textLabel = [[UILabel alloc] init];
    [self addSubview:_textLabel];
    _textLabel.numberOfLines = 0;
    _textLabel.textColor = _isSender ? [UIColor whiteColor] : [UIColor blackColor];
    _textLabel.font = self.textFont;
    _textLabel.autoresizingMask =
    _bubbleImage.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self updateFrame];
    
}

- (void)setMessage:(FLMessageModel *)message {
    _message = message;
    _textLabel.text = message.bodies.msg;
}

- (void)updateFrame {
    UIEdgeInsets insets = _isSender?_textSendInsets:_textRecInsets;
    _bubbleImage.frame = self.bounds;
    _textLabel.frame = CGRectMake(_bubbleImage.x + insets.left, _bubbleImage.y + insets.top, _bubbleImage.width - insets.left - insets.right, _bubbleImage.height - insets.top - insets.bottom);
}

- (void)setTextFont:(UIFont *)textFont {
    _textFont = textFont;
    _textLabel.font = textFont;
    
}

- (void)setTextSendInsets:(UIEdgeInsets)textSendInsets {
    _textSendInsets = textSendInsets;
    if (!_isSender) {
        return;
    }
    [self updateFrame];
}
- (void)setTextRecInsets:(UIEdgeInsets)textRecInsets {
    _textRecInsets = textRecInsets;
    if (_isSender) {
        return;
    }
    [self updateFrame];
}
@end
