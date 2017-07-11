//
//  FLMessageInputView.m
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/11.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import "FLMessageInputView.h"
#import "FLPlaceholderTextView.h"

#define kKeyboardView_Height 216.0
#define kMessageInputView_Height 50.0
#define kMessageInputView_HeightMax 120.0
#define kMessageInputView_PadingHeight 7.0
#define kMessageInputView_Width_Tool 35.0
#define kMessageInputView_MediaPadding 1.0

@interface FLMessageInputView ()

@property (nonatomic, strong) UIScrollView *contentView;
@property (nonatomic, strong) UIButton *voiceButton;
@property (nonatomic, strong) UIButton *arrowKeyboardButton;
@property (nonatomic, strong) UIButton *emotionButton;
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) FLPlaceholderTextView *inputTextView;

@end
@implementation FLMessageInputView

- (instancetype)init {
    if (self = [super initWithFrame:CGRectMake(0, kScreenHeight - kMessageInputView_Height, kScreenWidth, kMessageInputView_Height)]) {
        
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = FLNavBGColor;
    
    // topLine
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 1)];
    line.backgroundColor = [UIColor colorWithHexString:@"0xD8DDE4"];
    [self addSubview:line];
    
    // voiceButton
    _voiceButton = [[UIButton alloc] initWithFrame:CGRectMake(7, (kMessageInputView_Height - kMessageInputView_Width_Tool)/2, kMessageInputView_Width_Tool, kMessageInputView_Width_Tool)];
    
    [_voiceButton setImage:[UIImage imageNamed:@"keyboard_voice"] forState:UIControlStateNormal];
    [_voiceButton addTarget:self action:@selector(voiceButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_voiceButton];
    
    // emotionButton
    _emotionButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 15.0/2 - 2 * kMessageInputView_Width_Tool, (kMessageInputView_Height - kMessageInputView_Width_Tool)/2, kMessageInputView_Width_Tool, kMessageInputView_Width_Tool)];
    [_emotionButton setImage:[UIImage imageNamed:@"keyboard_emotion"] forState:UIControlStateNormal];
    [_emotionButton addTarget:self action:@selector(emotionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_emotionButton];
    
    // addButton
    _addButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 15.0/2 -kMessageInputView_Width_Tool, (kMessageInputView_Height - kMessageInputView_Width_Tool)/2, kMessageInputView_Width_Tool, kMessageInputView_Width_Tool)];
    [_addButton setImage:[UIImage imageNamed:@"keyboard_add"] forState:UIControlStateNormal];
    [_addButton addTarget:self action:@selector(addButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_addButton];
    
    // arrowKeyboardButton
    _arrowKeyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _arrowKeyboardButton.frame = CGRectMake(0, 0, kMessageInputView_Width_Tool, kMessageInputView_Width_Tool);
    [_arrowKeyboardButton setImage:[UIImage imageNamed:@"keyboard_arrow_down"] forState:UIControlStateNormal];
    [_arrowKeyboardButton addTarget:self action:@selector(arrowButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_arrowKeyboardButton];
    _arrowKeyboardButton.hidden = YES;
    
    
    // contentView
     CGFloat contentViewHeight = kMessageInputView_Height -2*kMessageInputView_PadingHeight;
    _contentView = [[UIScrollView alloc] init];
    _contentView.backgroundColor = [UIColor whiteColor];
    _contentView.layer.borderWidth = 0.5;
    _contentView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _contentView.layer.cornerRadius = contentViewHeight/2;
    _contentView.layer.masksToBounds = YES;
    _contentView.alwaysBounceVertical = YES;
    [self addSubview:_contentView];
    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat left = 7+kMessageInputView_Width_Tool+7;
        make.edges.equalTo(self).insets(UIEdgeInsetsMake(kMessageInputView_PadingHeight, left, kMessageInputView_PadingHeight, 15 + 2 *kMessageInputView_Width_Tool));
    }];
    // inputTextView
    _inputTextView = [[FLPlaceholderTextView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth - 15 - 2 *kMessageInputView_Width_Tool - (7+kMessageInputView_Width_Tool+7), contentViewHeight)];
    _inputTextView.font = [UIFont systemFontOfSize:16];
    _inputTextView.returnKeyType = UIReturnKeySend;
    _inputTextView.scrollsToTop = NO;
    _inputTextView.delegate = self;
    
    //输入框缩进
    UIEdgeInsets insets = _inputTextView.textContainerInset;
    insets.left += 8.0;
    insets.right += 8.0;
    _inputTextView.textContainerInset = insets;
    
    [self.contentView addSubview:_inputTextView];
}

@end
